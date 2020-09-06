import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kcoreaddons 1.0 as KCoreAddons

ColumnLayout {
	id: widget

	Timer {
		id: tickTimer
		running: true
		repeat: true
		interval: plasmoid.configuration.updateInterval
		// MonitorGraph connects to this and calls MonitorGraph.tick()
	}

	PlasmaCore.DataSource {
		id: sysMonDataSource

		engine: "systemmonitor"
		interval: plasmoid.configuration.updateInterval
		onSourceAdded: {
			// console.log('onSourceAdded', source)
		}
		onSourceRemoved: {
			// console.log('onSourceRemoved', source)
			disconnectSource(source)
		}
	}

	NetworkListDetector {
		id: networkListDetector
		dataSource: sysMonDataSource
	}

	QtObject {
		id: config

		property string netInterfaceName: {
			var networkName = plasmoid.configuration.netInterfaceName
			if (networkName && networkListDetector.networkSensorList.indexOf(networkName) !== -1) {
				return networkName
			} else if (networkListDetector.networkModel.length >= 1) {
				return networkListDetector.networkModel[0].interfaceName
			} else {
				return ''
			}
		}
	}

	//--- layout
	width: 240 * units.devicePixelRatio // Default desktop widget width
	spacing: 10 * units.devicePixelRatio

	property int rows: children.length
	property string graphState: {
		var rowHeight = Math.floor((height - (rows-1)*spacing) / rows)
		if (rowHeight >= 150 * units.devicePixelRatio) {
			return "large"
		} else if (rowHeight >= 100 * units.devicePixelRatio) {
			return "medium"
		} else if (rowHeight >= 60 * units.devicePixelRatio) {
			return "small"
		} else {
			return "tiny"
		}
	}

	MonitorGraph {
		id: cpuGraph
		dataSource: sysMonDataSource
		state: graphState
		sensorNames: ['cpu/system/TotalLoad']
		label: i18n("CPU")
		sublabel: i18n("%1%", firstCurrentValue)
		accentColors: [plasmoid.configuration.cpuAccentColor]
	}

	MonitorGraph {
		id: memGraph
		dataSource: sysMonDataSource
		state: graphState
		sensorNames: ['mem/physical/application']
		label: i18n("Memory")
		shortLabel: i18n("RAM")
		accentColors: [plasmoid.configuration.memAccentColor]

		// sensor reports in KB, so *1024 to get Bytes
		property string humanValue: {
			var str = KCoreAddons.Format.formatByteSize(firstCurrentValue * 1024)
			str = str.split(' ')[0] // Grab value and strip units ' KiB'
			return str
		}
		property string humanMax: {
			var str = KCoreAddons.Format.formatByteSize(firstSensorMax * 1024)
			str.replace(' ', '') // Remove space between value and units
			return str
		}
		property int percent: {
			if (firstSensorMax > 0) {
				return firstCurrentValue / firstSensorMax * 100
			} else {
				return 0
			}
		}

		// 8.6/15.9GiB (54%)
		sublabel: i18n("%1/%2 (%3%)", humanValue, humanMax, percent)

	}

	MonitorGraph {
		id: diskGraph
		dataSource: sysMonDataSource
		state: graphState
		property string diskName: 'sda'
		property string diskIndex: '8:0'
		property string diskKey: '' + diskName + '_(' + diskIndex + ')' // sda_(8:0)
		sensorNames: [
			'disk/' + diskKey + '/Rate/rblk',
			'disk/' + diskKey + '/Rate/wblk',
		]
		accentColors: [
			plasmoid.configuration.diskReadColor,
			plasmoid.configuration.diskWriteColor,
		]
		label: i18n("Disk (%1)", diskName)
		shortLabel: i18n("Disk")
		function formatValue(value) {
			var str = KCoreAddons.Format.formatByteSize(value * 1024)
			// str = str.replace(' ', '')
			return str
		}
		sublabel: {
			var readSpeed = isNaN(currentValues[0]) ? 0 : currentValues[0]
			var writeSpeed = isNaN(currentValues[1]) ? 0 : currentValues[1]
			return i18n("<font color=\"%1\">R:</font> %2 <font color=\"%3\">W:</font> %4", 
				accentColors[0], formatValue(readSpeed),
				accentColors[1], formatValue(writeSpeed)
			)
		}
	}

	MonitorGraph {
		id: netGraph
		dataSource: sysMonDataSource
		state: graphState
		property string interfaceName: config.netInterfaceName
		sensorNames: [
			'network/interfaces/' + interfaceName + '/transmitter/data', // Upload
			'network/interfaces/' + interfaceName + '/receiver/data', // Download
		]
		accentColors: [
			plasmoid.configuration.netUploadColor,
			plasmoid.configuration.netDownloadColor,
		]


		label: i18n("Network")
		shortLabel: i18n("Net")
		function formatValue(value) {
			var str = KCoreAddons.Format.formatByteSize(value * 1024)
			// str = str.replace(' ', '')
			return str
		}
		sublabel: {
			var upSpeed = isNaN(currentValues[0]) ? 0 : currentValues[0]
			var downSpeed = isNaN(currentValues[1]) ? 0 : currentValues[1]
			return i18n("<font color=\"%1\">U:</font> %2 <font color=\"%3\">D:</font> %4", 
				accentColors[0], formatValue(upSpeed),
				accentColors[1], formatValue(downSpeed)
			)
		}
	}


}
