/*
    SPDX-FileCopyrightText: 2026 edmogeor
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.iconthemes as KIconThemes
import org.kde.plasma.plasmoid
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: configPage

    property alias cfg_emptyIcon: emptyIconButton.icon.name
    property alias cfg_fullIcon: fullIconButton.icon.name
    property alias cfg_useSymbolicInPanel: useSymbolicCheckbox.checked

    Kirigami.FormLayout {
        anchors.fill: parent

        QQC2.Button {
            id: emptyIconButton
            Kirigami.FormData.label: i18n("Empty icon:")

            implicitWidth: Kirigami.Units.iconSizes.large + Kirigami.Units.largeSpacing * 2
            implicitHeight: implicitWidth

            icon.width: Kirigami.Units.iconSizes.large
            icon.height: Kirigami.Units.iconSizes.large

            onClicked: emptyIconDialog.open()

            KIconThemes.IconDialog {
                id: emptyIconDialog
                title: i18n("Select Empty Trash Icon")
                onIconNameChanged: (iconName) => {
                    if (iconName) {
                        emptyIconButton.icon.name = iconName
                    }
                }
            }
        }

        QQC2.Button {
            id: fullIconButton
            Kirigami.FormData.label: i18n("Full icon:")

            implicitWidth: Kirigami.Units.iconSizes.large + Kirigami.Units.largeSpacing * 2
            implicitHeight: implicitWidth

            icon.width: Kirigami.Units.iconSizes.large
            icon.height: Kirigami.Units.iconSizes.large

            onClicked: fullIconDialog.open()

            KIconThemes.IconDialog {
                id: fullIconDialog
                title: i18n("Select Full Trash Icon")
                onIconNameChanged: (iconName) => {
                    if (iconName) {
                        fullIconButton.icon.name = iconName
                    }
                }
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.CheckBox {
            id: useSymbolicCheckbox
            Kirigami.FormData.label: i18n("Panel behavior:")
            text: i18n("Use symbolic icons when in panel")
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Preview:")
            spacing: Kirigami.Units.largeSpacing

            ColumnLayout {
                spacing: Kirigami.Units.smallSpacing
                Kirigami.Icon {
                    source: emptyIconButton.icon.name
                    Layout.preferredWidth: Kirigami.Units.iconSizes.huge
                    Layout.preferredHeight: Kirigami.Units.iconSizes.huge
                    Layout.alignment: Qt.AlignHCenter
                }
                QQC2.Label {
                    text: i18n("Empty")
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            ColumnLayout {
                spacing: Kirigami.Units.smallSpacing
                Kirigami.Icon {
                    source: fullIconButton.icon.name
                    Layout.preferredWidth: Kirigami.Units.iconSizes.huge
                    Layout.preferredHeight: Kirigami.Units.iconSizes.huge
                    Layout.alignment: Qt.AlignHCenter
                }
                QQC2.Label {
                    text: i18n("Full")
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.Button {
            text: i18n("Reset to Defaults")
            icon.name: "edit-undo"
            onClicked: {
                emptyIconButton.icon.name = "user-trash"
                fullIconButton.icon.name = "user-trash-full"
                useSymbolicCheckbox.checked = true
            }
        }
    }
}
