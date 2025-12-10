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
        executable.exec(Qt.resolvedUrl("../code/caffeine-toggle.sh") + " on");
        showNotification("Caffeine Enabled", "System suspension blocked");
    }
    
    function disableCaffeine() {
        console.log("Disabling caffeine...");
        executable.exec(Qt.resolvedUrl("../code/caffeine-toggle.sh") + " off");
        showNotification("Caffeine Disabled", "System can suspend normally");
    }
    
    function showNotification(title, message) {
        console.log("NOTIFICATION:", title, "-", message);
        // Use Plasma's notification system
        executable.exec(`notify-send "${title}" "${message}" -i caffeine`);
    }
    
    // Verification function to check if caffeine is working
    function verifyCaffeineStatus() {
        if (caffeineEnabled) {
            executable.exec("pgrep -f 'systemd-inhibit.*sleep infinity' && echo 'Inhibition active' || echo 'Inhibition not found'");
            executable.exec("pgrep -f caffeine && echo 'Caffeine process active' || echo 'Caffeine process not found'");
        }
    }
    
    // Timer to keep checking and refreshing inhibition
    Timer {
        id: keepAliveTimer
        interval: 30000 // 30 seconds
        running: caffeineEnabled
        repeat: true
        onTriggered: {
            if (caffeineEnabled) {
                // Refresh the inhibition to make sure it's still active
                executable.exec("pgrep -f 'systemd-inhibit.*sleep infinity' || systemd-inhibit --what=sleep:idle:handle-power-key:handle-suspend-key:handle-hibernate-key:handle-lid-switch --who='Caffeine Panel' --why='User requested prevent sleep' --mode=block sleep infinity &");
                console.log("Refreshed caffeine inhibition");
            }
        }
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
