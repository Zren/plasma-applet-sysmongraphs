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

		ConfigComboBox2 {
			id: netInterfaceName
			Kirigami.FormData.label: i18n("Network") + ':'
			configKey: 'netInterfaceName'

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
				onNetworkModelChanged: netInterfaceName.populate()
			}
			Component.onCompleted: netInterfaceName.populate()

			populated: false
			model: []
			textRole: "labelWithId"
			valueRole2: "interfaceName"

			onPopulate: {
				var list = []

				// Add Default entry
				// An empty string value represents the default network.
				var defaultNetworkEntry = {
					"label": i18n("Default"),
					"icon": "",
					"interfaceName": "",
					"labelWithId": i18n("Default"),
				}
				if (networkListDetector.networkModel.length >= 1) {
					var defaultNetwork = networkListDetector.networkModel[0]
					defaultNetworkEntry.icon = defaultNetwork.icon
					defaultNetworkEntry.labelWithId = i18nc("NetworkLabel (InterfaceId)", "%1 (%2)", defaultNetworkEntry.label, defaultNetwork.interfaceName)
				}
				list.push(defaultNetworkEntry)

				for (var i = 0; i < networkListDetector.networkModel.length; i++) {
					var network = networkListDetector.networkModel[i]
					network.labelWithId = i18nc("NetworkLabel (InterfaceId)", "%1 (%2)", network.label, network.interfaceName)
					list.push(network)
				}

				netInterfaceName.model = list
				populated = true
				// console.log('NetworkSelector.model', JSON.stringify(netInterfaceName.model, null, '  '))
			}
		}
	}
}
