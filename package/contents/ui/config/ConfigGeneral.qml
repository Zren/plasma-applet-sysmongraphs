import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0

import org.kde.kirigami 2.3 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore

import ".."
import "../lib"

ConfigPage {
	id: page
	showAppletVersion: true

	Kirigami.FormLayout {
		id: formLayout
		Layout.fillWidth: true

		ConfigSpinBox2 {
			id: updateInterval
			Kirigami.FormData.label: i18n("Update interval:")
			configKey: 'updateInterval'
			stepSize: 100
			validator: DoubleValidator {
				bottom: updateInterval.from
				top: updateInterval.to
			}
			textFromValue: function(value) {
				return i18n("%1ms", value)
			}
			valueFromText: function(text) {
				return parseFloat(text)
			}
		}

		Kirigami.Separator {
			Kirigami.FormData.isSection: true
		}

		ConfigColor2 {
			Kirigami.FormData.label: i18n("CPU") + ':'
			configKey: 'cpuAccentColor'
		}

		ConfigColor2 {
			Kirigami.FormData.label: i18n("Memory") + ':'
			configKey: 'memAccentColor'
		}

		ConfigColor2 {
			Kirigami.FormData.label: i18n("Disk Read") + ':'
			configKey: 'diskReadColor'
		}

		ConfigColor2 {
			Kirigami.FormData.label: i18n("Disk Write") + ':'
			configKey: 'diskWriteColor'
		}

		ConfigColor2 {
			Kirigami.FormData.label: i18n("Network Upload") + ':'
			configKey: 'netUploadColor'
		}

		ConfigColor2 {
			Kirigami.FormData.label: i18n("Network Download") + ':'
			configKey: 'netDownloadColor'
		}

		ComboBox {
			id: netInterfaceName
			Kirigami.FormData.label: i18n("Network") + ':'

			PlasmaCore.DataSource {
				id: sysMonDataSource
				engine: "systemmonitor"
				onSourceAdded: {
					console.log('onSourceAdded', source)
				}
			}
			NetworkListDetector {
				id: networkListDetector
				dataSource: sysMonDataSource
				onNetworkModelChanged: netInterfaceName.updateModel()
			}
			Component.onCompleted: netInterfaceName.updateModel()

			model: []
			textRole: "label"

			function updateModel() {
				var list = []

				// Add Default entry
				// An empty string value represents the default network.
				if (networkListDetector.networkModel.length >= 1) {
					var defaultNetwork = networkListDetector.networkModel[0]
					var defaultInterfaceName = defaultNetwork.interfaceName
					list.push({
						"label": i18n("Default (%1)", defaultNetwork.interfaceName),
						"icon": defaultNetwork.icon,
						"interfaceName": "",
					})
				} else {
					list.push({
						"label": i18n("Default"),
						"icon": "",
						"interfaceName": "",
					})
				}

				for (var i = 0; i < networkListDetector.networkModel.length; i++) {
					var network = networkListDetector.networkModel[i]
					network.label = i18nc("NetworkLabel (InterfaceId)", "%1 (%2)", network.label, network.interfaceName)
					list.push(network)
				}

				netInterfaceName.model = list
				// console.log('NetworkSelector.model', JSON.stringify(netInterfaceName.model, null, '  '))
			}
		}
	}
}
