// Version 1

import QtQuick 2.0
import QtQuick.Controls 2.0

SpinBox {
	id: configSpinBox

	property string configKey: 'updateInterval'
	readonly property var configValue: plasmoid.configuration[configKey]

	to: 2147483647
	editable: true

	valueFromText: function(text) {
		return parseFloat(text)
	}

	value: configValue
	onValueModified: serializeTimer.start()

	Timer { // throttle
		id: serializeTimer
		interval: 300
		onTriggered: plasmoid.configuration[configKey] = value
	}
}
