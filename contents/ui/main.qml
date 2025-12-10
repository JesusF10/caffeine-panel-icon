import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as P5Support

PlasmoidItem {
    id: root
    
    property bool caffeineEnabled: false
    
    preferredRepresentation: compactRepresentation
    
    // DataSource for executing commands
    P5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        
        onNewData: function(sourceName, data) {
            console.log("Command executed:", sourceName, "Exit code:", data["exit code"]);
            disconnectSource(sourceName);
        }
        
        function exec(cmd) {
            console.log("Executing:", cmd);
            connectSource(cmd);
        }
    }
    
    // Connect to logic when caffeine state changes
    onCaffeineEnabledChanged: {
        console.log("Caffeine state changed to:", caffeineEnabled);
        
        if (caffeineEnabled) {
            enableCaffeine();
        } else {
            disableCaffeine();
        }
    }
    
    function enableCaffeine() {
        console.log("Enabling caffeine...");
        
        // Method 1: Try caffeine command
        executable.exec("which caffeine && caffeine &");
        
        // Method 2: Use xset to disable screen saver and DPMS
        executable.exec("xset s off");
        executable.exec("xset -dpms");
        
        // Method 3: Create a simple keep-alive process
        executable.exec("sh -c 'while true; do echo > /dev/null; sleep 30; done' &");
        
        showNotification("Caffeine Enabled", "System sleep/suspend prevented");
    }
    
    function disableCaffeine() {
        console.log("Disabling caffeine...");
        
        // Kill caffeine processes
        executable.exec("pkill -f caffeine");
        executable.exec("pkill -f 'while true; do echo'");
        
        // Re-enable screen saver and DPMS
        executable.exec("xset s on");
        executable.exec("xset +dpms");
        
        showNotification("Caffeine Disabled", "System can sleep/suspend normally");
    }
    
    function showNotification(title, message) {
        console.log("NOTIFICATION:", title, "-", message);
        // Use Plasma's notification system
        executable.exec(`notify-send "${title}" "${message}" -i caffeine`);
    }
    
    compactRepresentation: Rectangle {
        id: compactRoot
        
        implicitWidth: 24
        implicitHeight: 24
        
        Layout.minimumWidth: 22
        Layout.minimumHeight: 22
        Layout.preferredWidth: 24
        Layout.preferredHeight: 24
        
        color: "transparent"
        
        // Custom SVG icon
        Image {
            id: customIcon
            anchors.fill: parent
            anchors.margins: 1
            source: root.caffeineEnabled 
                ? Qt.resolvedUrl("../icons/coffee-steam.svg")
                : Qt.resolvedUrl("../icons/coffee.svg")
            sourceSize: Qt.size(width, height)
            fillMode: Image.PreserveAspectFit
            
            onStatusChanged: {
                if (status === Image.Error) {
                    visible = false
                    fallbackIcon.visible = true
                } else if (status === Image.Ready) {
                    visible = true
                    fallbackIcon.visible = false
                }
            }
        }
        
        // Fallback - texto simple
        Rectangle {
            id: fallbackIcon
            anchors.fill: parent
            color: root.caffeineEnabled ? "#ff6b35" : "#6c757d"
            radius: 3
            border.color: "white"
            border.width: 1
            visible: false
            
            Text {
                anchors.centerIn: parent
                text: root.caffeineEnabled ? "☕" : "💤"
                font.pixelSize: 12
                color: "white"
            }
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.caffeineEnabled = !root.caffeineEnabled
                console.log("Caffeine clicked, state:", root.caffeineEnabled)
            }
            
            hoverEnabled: true
            onEntered: parent.scale = 1.1
            onExited: parent.scale = 1.0
        }
        
        Behavior on scale {
            NumberAnimation { duration: 100 }
        }
    }
    
    fullRepresentation: Rectangle {
        Layout.minimumWidth: 200
        Layout.minimumHeight: 100
        color: "lightgray"
        
        Text {
            anchors.centerIn: parent
            text: "Caffeine Panel Icon\nClick to toggle: " + (root.caffeineEnabled ? "ON" : "OFF")
            horizontalAlignment: Text.AlignHCenter
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: root.caffeineEnabled = !root.caffeineEnabled
        }
    }
}
