/*
    SPDX-FileCopyrightText: 2013 Heena Mahour <heena393@gmail.com>
    SPDX-FileCopyrightText: 2015, 2016 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2023 Nate Graham <nate@kde.org>
    SPDX-FileCopyrightText: 2026 edmogeor (Custom icon support)

    SPDX-License-Identifier: GPL-2.0-or-later
*/
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.draganddrop as DragDrop
import org.kde.kirigami as Kirigami

import org.kde.kcmutils as KCM
import org.kde.config as KConfig

PlasmoidItem {
    id: root

    readonly property bool inPanel: (Plasmoid.location === PlasmaCore.Types.TopEdge
        || Plasmoid.location === PlasmaCore.Types.RightEdge
        || Plasmoid.location === PlasmaCore.Types.BottomEdge
        || Plasmoid.location === PlasmaCore.Types.LeftEdge)

    property int trashCount: 0
    readonly property bool hasContents: trashCount > 0
    property bool emptying: false

    property bool containsAcceptableDrag: false

    // Configurable icons
    readonly property string emptyIconName: Plasmoid.configuration.emptyIcon || "user-trash"
    readonly property string fullIconName: Plasmoid.configuration.fullIcon || "user-trash-full"
    readonly property bool useSymbolic: Plasmoid.configuration.useSymbolicInPanel

    Plasmoid.title: i18nc("@title the name of the Trash widget", "Trash")
    toolTipSubText: {
        if (emptying) {
            return i18nc("@info:status The trash is being emptied", "Emptying...");
        } else if (hasContents) {
            return i18ncp("@info:status The trash contains this many items in it", "One item", "%1 items", trashCount);
        } else {
            return i18nc("@info:status The trash is empty", "Empty");
        }
    }

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    Plasmoid.icon: {
        let iconName = (hasContents ? fullIconName : emptyIconName);

        if (inPanel && useSymbolic) {
            // Check if icon already has -symbolic suffix
            if (!iconName.endsWith("-symbolic")) {
                return iconName + "-symbolic";
            }
        }

        return iconName;
    }
    Plasmoid.status: hasContents ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.PassiveStatus
    Plasmoid.busy: emptying

    Plasmoid.onActivated: openTrash()

    // Data source for executing commands
    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []

        onNewData: (source, data) => {
            disconnectSource(source)

            if (source.includes("wc -l")) {
                // Trash count result
                root.trashCount = parseInt(data.stdout.trim()) || 0
            } else if (source.includes("gio trash --empty")) {
                // Empty trash finished
                root.emptying = false
                updateTrashCount()
            } else if (source.includes("gio trash")) {
                // File trashed
                updateTrashCount()
            }
        }
    }

    // Monitor trash directory
    Timer {
        id: trashMonitor
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: updateTrashCount()
    }

    function updateTrashCount() {
        executable.connectSource("ls -A ~/.local/share/Trash/files 2>/dev/null | wc -l")
    }

    function openTrash() {
        executable.connectSource("xdg-open trash:/")
    }

    function emptyTrash() {
        root.emptying = true
        executable.connectSource("gio trash --empty")
    }

    function trashUrls(urls) {
        for (let i = 0; i < urls.length; i++) {
            let url = urls[i].toString()
            // Convert file:// URL to path
            if (url.startsWith("file://")) {
                url = url.substring(7)
            }
            executable.connectSource("gio trash '" + url.replace(/'/g, "'\\''") + "'")
        }
    }

    function canBeTrashed(url) {
        return url && url.toString().startsWith("file://")
    }

    function trashableUrls(urls) {
        let valid = []
        for (let i = 0; i < urls.length; i++) {
            if (canBeTrashed(urls[i])) {
                valid.push(urls[i])
            }
        }
        return valid
    }

    Keys.onPressed: event => {
        switch (event.key) {
        case Qt.Key_Space:
        case Qt.Key_Enter:
        case Qt.Key_Return:
        case Qt.Key_Select:
            Plasmoid.activated();
            break;
        }
    }
    Accessible.name: Plasmoid.title
    Accessible.description: toolTipSubText
    Accessible.role: Accessible.Button

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18nc("@action:inmenu Open the trash", "Open")
            icon.name: "document-open-symbolic"
            onTriggered: Plasmoid.activated()
        },
        PlasmaCore.Action {
            text: i18nc("@action:inmenu Empty the trash", "Empty")
            icon.name: "trash-empty-symbolic"
            enabled: root.hasContents && !root.emptying
            onTriggered: emptyTrash()
        },
        PlasmaCore.Action {
            text: i18nc("@action:inmenu", "Trash Settings...")
            icon.name: "configure-symbolic"
            visible: KConfig.KAuthorized.authorizeControlModule("kcm_trash")
            onTriggered: KCM.KCMLauncher.open("kcm_trash")
        }
    ]

    preferredRepresentation: fullRepresentation
    fullRepresentation: MouseArea {
        id: mouseArea

        activeFocusOnTab: true
        hoverEnabled: true

        onClicked: Plasmoid.activated()

        DragDrop.DropArea {
            anchors.fill: parent
            preventStealing: true
            onDragEnter: event => root.containsAcceptableDrag = root.trashableUrls(event.mimeData.urls).length > 0
            onDragLeave: root.containsAcceptableDrag = false

            onDrop: event => {
                root.containsAcceptableDrag = false

                var validUrls = root.trashableUrls(event.mimeData.urls)
                if (validUrls.length > 0) {
                    root.trashUrls(validUrls)
                    event.accept(Qt.MoveAction)
                } else {
                    event.accept(Qt.IgnoreAction)
                }
            }
        }

        Kirigami.Icon {
            source: Plasmoid.icon
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                bottom: root.inPanel ? parent.bottom: text.top
            }
            active: mouseArea.containsMouse || root.containsAcceptableDrag
        }

        PlasmaExtras.ShadowedLabel {
            id: text
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
            }
            width: Math.round(text.implicitWidth + Kirigami.Units.smallSpacing)
            text: Plasmoid.title + "\n" + root.toolTipSubText
            horizontalAlignment: Text.AlignHCenter
            visible: !root.inPanel
        }

        PlasmaCore.ToolTipArea {
            anchors.fill: parent
            mainText: Plasmoid.title
            subText: root.toolTipSubText
        }
    }
}
