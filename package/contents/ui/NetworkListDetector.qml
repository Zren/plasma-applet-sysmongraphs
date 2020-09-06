import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

QtObject {
	id: networkListDetector

	property PlasmaCore.DataSource dataSource
	property var networkModel: []

	property var networkSensorList: []
	onNetworkSensorListChanged: {
		updateNetworkModel()
	}

	readonly property var ignoredNetworks: []
	onIgnoredNetworksChanged: {
		updateNetworkModel()
	}

	property Connections sensorConnection: Connections {
		target: dataSource
		onSourceAdded: {
			// console.log('onSourceAdded', source)
			var match = source.match(/^network\/interfaces\/(\w+)\//)
			if (match) {
				var networkName = match[1]
				if (networkListDetector.networkSensorList.indexOf(networkName) === -1) {
					// Add if not seen before
					networkListDetector.networkSensorList.push(networkName)
					networkListDetector.networkSensorListChanged()
				}
			}
		}
		onSourceRemoved: {
			// console.log('onSourceRemoved', source)
			var match = source.match(/^network\/interfaces\/(\w+)\//)
			if (match) {
				var networkName = match[1]
				var index = networkListDetector.networkSensorList.indexOf(networkName)
				if (index !== -1) {
					// Remove network from list
					networkListDetector.networkSensorList.splice(index, 1)
					networkListDetector.networkSensorListChanged()
				}
			}
		}
	}

	Component.onCompleted: {
		if (dataSource) {
			var changed = false
			for (var i = 0; i < dataSource.sources.length; i++) {
				var source = dataSource.sources[i]
				var match = source.match(/^network\/interfaces\/(\w+)\//)
				if (match) {
					var networkName = match[1]
					if (networkListDetector.networkSensorList.indexOf(networkName) === -1) {
						// Add if not seen before
						networkListDetector.networkSensorList.push(networkName)
						changed = true
					}
				}
			}
			if (changed) {
				networkListDetector.networkSensorListChanged()
			}
		}
	}

	function updateNetworkModel() {
		// [
		// 	{
		// 		"label": "Network",
		// 		"icon": "network-wired",
		// 		"interfaceName": "enp1s0"
		// 	},
		// 	{
		// 		"label": "WiFi",
		// 		"icon": "network-wireless",
		// 		"interfaceName": "wlp1s0"
		// 	}
		// ]
		var newNetworkModel = []
		for (var i = 0; i < networkSensorList.length; i++) {
			var networkName = networkSensorList[i]

			// SystemD network naming scheme:
			// https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/
			// Eg: wlp5s6
			// First two letters are the hardware type.
			// p5 = Port 5
			// s6 = Slot 6

			// Keep this in sync with ConfigNetworks.qml
			if (networkName == 'lo' // Ignore loopback device
			  || networkName.match(/^docker(\d+)/) // Ignore docker networks
			  || networkName.match(/^(tun|tap)(\d+)/) // Ingore tun/tap interfaces
			) { 
				continue
			}

			if (ignoredNetworks.indexOf(networkName) >= 0) {
				continue
			}

			var newNetwork = {}
			newNetwork.interfaceName = networkName

			// First two letters are 
			if (networkName.match(/^wl/)) { // Wireless
				newNetwork.label = i18n("Wi-Fi")
				newNetwork.icon = "network-wireless"
			} else { // Eg: en (Ethernet)
				newNetwork.label = i18n("Network")
				newNetwork.icon = "network-wired"
			}
			newNetworkModel.push(newNetwork)
		}

		networkModel = newNetworkModel

		// console.log(JSON.stringify(networkModel, null, '  '))
	}
}

