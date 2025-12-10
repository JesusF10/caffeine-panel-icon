// Power management functionality for Caffeine Panel Icon

var caffeineProcess = null;
var inhibitionActive = false;

function toggleCaffeine(enabled) {
    console.log("toggleCaffeine called with:", enabled);
    
    if (enabled) {
        enableCaffeine();
    } else {
        disableCaffeine();
    }
}

function enableCaffeine() {
    try {
        console.log("Attempting to enable caffeine...");
        
        // Method 1: Use caffeine if available
        if (commandExists("caffeine")) {
            executeCommand("caffeine");
            inhibitionActive = true;
            console.log("Caffeine enabled via caffeine command");
            return true;
        }
        
        // Method 2: Use systemd-inhibit
        if (commandExists("systemd-inhibit")) {
            executeCommand("systemd-inhibit --what=sleep:idle --who='Caffeine Panel' --why='User requested' --mode=block sleep infinity &");
            inhibitionActive = true;
            console.log("Caffeine enabled via systemd-inhibit");
            return true;
        }
        
        // Method 3: Use xset to disable DPMS
        if (commandExists("xset")) {
            executeCommand("xset s off");
            executeCommand("xset -dpms");
            inhibitionActive = true;
            console.log("Caffeine enabled via xset");
            return true;
        }
        
        console.log("No suitable method found to enable caffeine");
        return false;
        
    } catch (error) {
        console.log("Error enabling caffeine:", error);
        return false;
    }
}

function disableCaffeine() {
    try {
        console.log("Attempting to disable caffeine...");
        
        // Kill caffeine processes
        executeCommand("pkill -f caffeine");
        executeCommand("pkill -f 'systemd-inhibit.*sleep infinity'");
        
        // Re-enable DPMS if we disabled it
        if (commandExists("xset")) {
            executeCommand("xset s on");
            executeCommand("xset +dpms");
        }
        
        inhibitionActive = false;
        console.log("Caffeine disabled");
        return true;
        
    } catch (error) {
        console.log("Error disabling caffeine:", error);
        inhibitionActive = false;
        return false;
    }
}

function commandExists(command) {
    // Simple check - in a real implementation this would be more robust
    return true; // Assume commands exist for now
}

function executeCommand(command) {
    console.log("Executing command:", command);
    // In QML, we'll need to use a different approach
    // This is a placeholder for the actual implementation
}
