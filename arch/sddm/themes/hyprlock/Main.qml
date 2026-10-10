import QtQuick 2.15

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: config.background

    readonly property real u: Math.min(width, height) / 100
    property int sessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    property bool busy: false

    function login() {
        if (busy || password.text.length === 0)
            return
        busy = true
        message.text = ""
        sddm.login(username.text, password.text, sessionIndex)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            busy = false
            password.text = ""
            message.text = "wrong password"
            shake.start()
            password.forceActiveFocus()
        }
        function onLoginSucceeded() {
            field.border.color = config.success
        }
    }

    // Session names, read by index for the cycler below
    Repeater {
        id: sessions
        model: sessionModel
        delegate: Item { property string sessionName: model.name }
    }

    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            const now = new Date()
            clock.text = Qt.formatTime(now, "HH:mm")
            date.text = Qt.formatDate(now, "dddd, d MMMM")
        }
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: field.top
        anchors.bottomMargin: u * 10
        spacing: u * 0.5

        Text {
            id: clock
            anchors.horizontalCenter: parent.horizontalCenter
            color: config.foreground
            font.family: config.font
            font.weight: Font.Light
            font.pixelSize: u * 16
        }
        Text {
            id: date
            anchors.horizontalCenter: parent.horizontalCenter
            color: config.muted
            font.family: config.font
            font.pixelSize: u * 2.2
        }
    }

    TextInput {
        id: username
        anchors.left: field.left
        anchors.bottom: field.top
        anchors.bottomMargin: u * 1.2
        text: userModel.lastUser
        color: config.muted
        font.family: config.font
        font.pixelSize: u * 1.8
        selectByMouse: true
        KeyNavigation.tab: password
        onAccepted: password.forceActiveFocus()
    }

    Rectangle {
        id: field
        anchors.centerIn: parent
        anchors.verticalCenterOffset: u * 8
        width: Math.min(root.width - u * 8, u * 50)
        height: u * 6.5
        color: "transparent"
        border.width: Math.max(2, u * 0.25)
        border.color: message.text ? config.error
                    : password.activeFocus ? config.accent : config.muted

        Behavior on border.color { ColorAnimation { duration: 150 } }

        SequentialAnimation {
            id: shake
            NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: -u; duration: 50 }
            NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: u; duration: 50 }
            NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: -u / 2; duration: 50 }
            NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: 0; duration: 50 }
        }

        TextInput {
            id: password
            anchors.fill: parent
            anchors.leftMargin: u * 2
            anchors.rightMargin: u * 2
            verticalAlignment: TextInput.AlignVCenter
            horizontalAlignment: TextInput.AlignHCenter
            echoMode: TextInput.Password
            passwordCharacter: "•"
            color: config.foreground
            font.family: config.font
            font.pixelSize: u * 2.4
            font.letterSpacing: u * 0.3
            focus: true
            enabled: !root.busy
            clip: true
            KeyNavigation.backtab: username
            onTextEdited: message.text = ""
            onAccepted: root.login()

            Text {
                anchors.centerIn: parent
                visible: !password.text
                text: "password"
                color: config.muted
                font: password.font
            }
        }
    }

    Text {
        id: message
        anchors.top: field.bottom
        anchors.topMargin: u * 1.2
        anchors.left: field.left
        color: config.error
        font.family: config.font
        font.pixelSize: u * 1.6
    }

    // Caps lock and keyboard layout, under the right edge of the field
    Row {
        anchors.top: field.bottom
        anchors.topMargin: u * 1.2
        anchors.right: field.right
        spacing: u * 2

        Text {
            visible: keyboard.capsLock
            text: "caps lock"
            color: config.accent
            font.family: config.font
            font.pixelSize: u * 1.6
        }
        BarButton {
            visible: keyboard.layouts.length > 1
            text: visible ? keyboard.layouts[keyboard.currentLayout].shortName : ""
            onClicked: keyboard.currentLayout = (keyboard.currentLayout + 1) % keyboard.layouts.length
        }
    }

    // Bottom bar: session on the left, power on the right
    component BarButton: Text {
        signal clicked()
        color: mouse.containsMouse ? config.foreground : config.muted
        font.family: config.font
        font.pixelSize: u * 1.6
        MouseArea {
            id: mouse
            anchors.fill: parent
            anchors.margins: -u
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }

    BarButton {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: u * 3
        visible: sessions.count > 1
        text: (sessions.itemAt(root.sessionIndex) ? sessions.itemAt(root.sessionIndex).sessionName : "")
              .toLowerCase()
        onClicked: root.sessionIndex = (root.sessionIndex + 1) % sessions.count
    }

    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: u * 3
        spacing: u * 3

        BarButton { text: "suspend"; visible: sddm.canSuspend; onClicked: sddm.suspend() }
        BarButton { text: "reboot"; visible: sddm.canReboot; onClicked: sddm.reboot() }
        BarButton { text: "shutdown"; visible: sddm.canPowerOff; onClicked: sddm.powerOff() }
    }
}
