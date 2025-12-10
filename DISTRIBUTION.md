# Caffeine Panel Icon - Distribution Guide

## For Package Maintainers

### Creating Distribution Packages

#### Arch Linux (AUR)
```bash
# Create PKGBUILD
pkgname=plasma6-caffeine-panel-icon
pkgver=1.0.0
pkgrel=1
pkgdesc="Caffeine-style panel widget for KDE Plasma 6"
arch=('any')
url="https://github.com/JesusF10/caffeine-panel-icon"
license=('MIT')
depends=('plasma-workspace' 'xorg-xset')
source=("$pkgname-$pkgver.tar.gz")

package() {
    cd "$srcdir/$pkgname-$pkgver"
    install -Dm644 metadata.json "$pkgdir/usr/share/plasma/plasmoids/caffeine-panel-icon/metadata.json"
    cp -r contents "$pkgdir/usr/share/plasma/plasmoids/caffeine-panel-icon/"
    install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
```

#### Debian/Ubuntu (.deb)
```bash
# Control file dependencies
Depends: plasma-workspace (>= 6.0), x11-xserver-utils
```

#### Fedora (.rpm)
```bash
# Spec file dependencies
Requires: plasma-workspace >= 6.0, xorg-x11-server-utils
```

### Installation Locations

- **System-wide**: `/usr/share/plasma/plasmoids/caffeine-panel-icon/`
- **User-local**: `~/.local/share/plasma/plasmoids/caffeine-panel-icon/`

### Required Permissions

The `caffeine-toggle.sh` script needs execute permissions:
```bash
chmod +x contents/code/caffeine-toggle.sh
```

## For Users Without Package Managers

### Method 1: Direct Download
1. Download latest release: https://github.com/JesusF10/caffeine-panel-icon/releases
2. Extract to temporary directory
3. Run `./install.sh`

### Method 2: Git Clone
```bash
git clone https://github.com/JesusF10/caffeine-panel-icon.git
cd caffeine-panel-icon
./install.sh
```

### Method 3: One-liner Install
```bash
curl -fsSL https://raw.githubusercontent.com/JesusF10/caffeine-panel-icon/main/install.sh | bash
```

## Manual Installation Steps

If automatic installer fails:

1. **Install dependencies:**
   ```bash
   # Arch Linux
   sudo pacman -S plasma-workspace xorg-xset
   
   # Ubuntu/Debian
   sudo apt install plasma-workspace x11-xserver-utils
   
   # Fedora
   sudo dnf install plasma-workspace xorg-x11-server-utils
   ```

2. **Install widget:**
   ```bash
   kpackagetool6 --install . --type Plasma/Applet
   ```

3. **Set permissions:**
   ```bash
   chmod +x ~/.local/share/plasma/plasmoids/caffeine-panel-icon/contents/code/caffeine-toggle.sh
   ```

4. **Restart Plasma:**
   ```bash
   killall plasmashell && kstart plasmashell
   ```

## For Developers

### Building from Source
1. Clone repository
2. Modify as needed
3. Test with: `kpackagetool6 --install . --type Plasma/Applet`
4. Package with: `tar -czf caffeine-panel-icon-1.0.0.tar.gz *`

### Development Dependencies
- Qt 6.0+
- KDE Frameworks 6.0+
- Plasma 6.0+
- CMake 3.16+ (for building from source)

## Verification

After installation, verify with:
```bash
kpackagetool6 --list | grep caffeine-panel-icon
ls -la ~/.local/share/plasma/plasmoids/caffeine-panel-icon/
```

The widget should appear in "Add or Manage Widgets" dialog.