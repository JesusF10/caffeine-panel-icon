#!/bin/bash

# Caffeine Panel Icon - Automatic Installer
# Compatible with KDE Plasma 6.0+

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_requirements() {
    print_info "Checking system requirements..."
    
    # Check if we're on a Linux system
    if [[ "$OSTYPE" != "linux-gnu"* ]]; then
        print_error "This installer only works on Linux systems."
        exit 1
    fi
    
    # Check for KDE Plasma
    if ! command -v plasmashell &> /dev/null; then
        print_error "KDE Plasma is not installed or not in PATH."
        exit 1
    fi
    
    # Check Plasma version
    PLASMA_VERSION=$(plasmashell --version 2>/dev/null | grep -oP '\d+\.\d+' | head -1)
    if [[ -n "$PLASMA_VERSION" ]]; then
        MAJOR_VERSION=$(echo "$PLASMA_VERSION" | cut -d. -f1)
        if [[ "$MAJOR_VERSION" -lt 6 ]]; then
            print_warning "Plasma version $PLASMA_VERSION detected. This widget is designed for Plasma 6.0+."
            read -p "Continue anyway? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
    fi
    
    # Check for kpackagetool6
    if ! command -v kpackagetool6 &> /dev/null; then
        print_error "kpackagetool6 is not installed. Please install Plasma development tools."
        exit 1
    fi
    
    # Check for xset
    if ! command -v xset &> /dev/null; then
        print_warning "xset is not installed. Installing..."
        if command -v pacman &> /dev/null; then
            sudo pacman -S --needed xorg-xset
        elif command -v apt &> /dev/null; then
            sudo apt update && sudo apt install -y x11-xserver-utils
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y xorg-x11-server-utils
        else
            print_error "Could not install xset automatically. Please install it manually."
            exit 1
        fi
    fi
    
    print_success "All requirements satisfied!"
}

install_widget() {
    print_info "Installing Caffeine Panel Icon widget..."
    
    # Remove existing installation if present
    if kpackagetool6 --list 2>/dev/null | grep -q "caffeine-panel-icon"; then
        print_info "Found existing installation. Removing..."
        if kpackagetool6 --remove caffeine-panel-icon --type Plasma/Applet 2>/dev/null; then
            print_success "Existing installation removed."
        else
            print_warning "Could not remove existing installation, continuing anyway..."
        fi
        sleep 1
    fi
    
    # Install the widget
    print_info "Installing widget..."
    if kpackagetool6 --install . --type Plasma/Applet 2>/dev/null; then
        print_success "Widget installed successfully!"
    else
        print_error "Failed to install widget. Trying force installation..."
        # Try removing any leftover directory and reinstalling
        rm -rf "$HOME/.local/share/plasma/plasmoids/caffeine-panel-icon" 2>/dev/null
        if kpackagetool6 --install . --type Plasma/Applet 2>/dev/null; then
            print_success "Widget installed successfully (after cleanup)!"
        else
            print_error "Installation failed. Please try manual installation."
            exit 1
        fi
    fi
}

setup_script_permissions() {
    print_info "Setting up script permissions..."
    
    INSTALL_PATH="$HOME/.local/share/plasma/plasmoids/caffeine-panel-icon"
    SCRIPT_PATH="$INSTALL_PATH/contents/code/caffeine-toggle.sh"
    
    if [[ -f "$SCRIPT_PATH" ]]; then
        chmod +x "$SCRIPT_PATH"
        print_success "Script permissions set correctly."
    else
        print_warning "Could not find installed script at $SCRIPT_PATH"
    fi
}

restart_plasma() {
    print_info "Restarting Plasma Shell to load the new widget..."
    
    # Try to restart plasma gracefully
    if command -v kquitapp6 &> /dev/null; then
        kquitapp6 plasmashell && sleep 2 && kstart plasmashell
    else
        killall plasmashell && sleep 2 && kstart plasmashell
    fi
    
    print_success "Plasma Shell restarted!"
}

show_completion_message() {
    echo
    echo -e "${GREEN}🎉 Installation completed successfully!${NC}"
    echo
    echo "📋 Next steps:"
    echo "1. Right-click on your panel"
    echo "2. Select 'Add or Manage Widgets...'"
    echo "3. Search for 'Caffeine Panel Icon'"
    echo "4. Drag it to your panel"
    echo
    echo -e "${BLUE}💡 Usage:${NC}"
    echo "• Click the coffee cup to toggle suspension prevention"
    echo "• Icon shows steam when active (suspension blocked)"
    echo "• No steam means system can suspend normally"
    echo
    echo -e "${YELLOW}🔧 Troubleshooting:${NC}"
    echo "• If widget doesn't appear, restart Plasma: killall plasmashell && kstart plasmashell"
    echo "• Check logs with: journalctl --user -f | grep caffeine"
    echo
    echo -e "${GREEN}Thank you for using Caffeine Panel Icon! ☕${NC}"
}

main() {
    echo -e "${BLUE}"
    echo "☕ Caffeine Panel Icon Installer"
    echo "================================="
    echo -e "${NC}"
    
    # Check if we're in the right directory
    if [[ ! -f "metadata.json" ]] || [[ ! -d "contents" ]]; then
        print_error "Please run this script from the caffeine-panel-icon directory."
        print_info "Expected files: metadata.json, contents/"
        exit 1
    fi
    
    check_requirements
    install_widget
    setup_script_permissions
    restart_plasma
    show_completion_message
}

# Run main function
main "$@"