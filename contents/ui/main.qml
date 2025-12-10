import QtQuick 6.5
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents

Item {
    width: 24
    height: 24

    PlasmaCore.IconItem {
        id: icon
        anchors.centerIn: parent
        source: caffeineEnabled ? "media-playback-pause" : "media-playback-start"
        color: caffeineEnabled ? PlasmaCore.ColorScope.textColor : PlasmaCore.ColorScope.disabledTextColor
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            caffeineEnabled = !caffeineEnabled
            Logic.toggleCaffeine(caffeineEnabled)
        }
    }

    property bool caffeineEnabled: false

    // connect to JS logic
    QtObject {
        id: Logic
        property var toggleCaffeine: Qt.binding(function() {})
    }
}
