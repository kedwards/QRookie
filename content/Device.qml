/*
 Copyright (c) 2024 glaumar <glaumar@geekgo.tech>

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

import DeviceManager
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import VrpManager
import org.kde.kirigami as Kirigami

RowLayout {
    Item {
        id: device_info

        Layout.fillHeight: true
        Layout.bottomMargin: 10
        Layout.rightMargin: 5
        width: 310

        Kirigami.Card {
            anchors.fill: parent

            Connections {
                function onSpaceUsageChanged(total_space, free_space) {
                    if (!isNaN(total_space) && !isNaN(free_space) && free_space > 0 && free_space <= total_space) {
                        space_usage_text.text = ((total_space - free_space) / 1024 / 1024).toFixed(2) + " GB / " + (total_space / 1024 / 1024).toFixed(2) + " GB";
                        space_usage_bar.value = (total_space - free_space) / total_space;
                    } else {
                        space_usage_text.text = "0.00 GB / 0.00 GB";
                        space_usage_bar.value = 0;
                    }
                }

                function onDeviceNameChanged(name) {
                    device_name.text = name === "" ? "No device connected" : name;
                }

                target: app.deviceManager
            }

            contentItem: Column {
                spacing: 10

                Label {
                    id: space_usage_text

                    width: parent.width
                    text: "0.00 GB / 0.00 GB"
                }

                ProgressBar {
                    id: space_usage_bar

                    width: parent.width
                    value: 0
                }

                ComboBox {
                    id: device_selector

                    width: parent.width
                    model: app.deviceManager.devicesList
                    onActivated: (index) => {
                        app.deviceManager.connectToDevice(textAt(index));
                    }
                }

            }

            header: Label {
                id: device_name

                text: "No device connected"
                font.bold: true
                font.pointSize: Qt.application.font.pointSize * 2
            }

        }

    }

    GridView {
        id: apps_info

        Layout.fillHeight: true
        Layout.fillWidth: true
        snapMode: GridView.SnapToRow
        clip: true
        cellWidth: 310
        cellHeight: 220
        model: app.deviceManager.appListModel()

        ScrollBar.vertical: ScrollBar {
            visible: true
        }

        delegate: ApplicationDelegate {
            width: apps_info.cellWidth - 10
            height: apps_info.cellHeight - 10
            name: model.package_name
            thumbnailPath: {
                let path = app.vrp.getGameThumbnailPath(model.package_name);
                if (path === "")
                    return "qrc:/qt/qml/content/Image/matrix.png";
                else
                    return "file://" + path;
            }
            onUninstallButtonClicked: {
                let package_name = model.package_name;
                apps_info.model.remove(index);
                app.deviceManager.uninstallApkQml(package_name);
            }
        }

    }

}
