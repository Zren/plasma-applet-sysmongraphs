// Version 5

import QtQuick 2.0
import QtQuick.Controls 2.0

/*
** Example:
**
ConfigComboBox {
	configKey: "appDescription"
	model: [
		{ value: "a", text: i18n("A") },
		{ value: "b", text: i18n("B") },
		{ value: "c", text: i18n("C") },
	]
}
ConfigComboBox {
	configKey: "appDescription"
	populated: false
	onPopulate: {
		model = [
			{ value: "a", text: i18n("A") },
			{ value: "b", text: i18n("B") },
			{ value: "c", text: i18n("C") },
		]
	}
}
*/
ComboBox {
	id: configComboBox

	textRole: "text" // Doesn't autodeduce from model if we manually populate it
	// valueRole: "value" // Requires Qt 5.14
	property string valueRole2: "value"

	property string configKey: ''
	readonly property var currentItem: model[currentIndex]
	readonly property string value: currentItem ? currentItem[valueRole2] : ""
	readonly property string configValue: configKey ? plasmoid.configuration[configKey] : ""
	onConfigValueChanged: {
		if (!focus && value != configValue) {
			selectValue(configValue)
		}
	}

	signal populate()
	property bool populated: true

	Component.onCompleted: {
		populate()
		selectValue(configValue)
	}

	model: []

	onCurrentIndexChanged: {
		if (typeof model !== 'number' && 0 <= currentIndex && currentIndex < count) {
			var item = model[currentIndex]
			if (typeof item !== "undefined") {
				var val = item[valueRole2]
				if (configKey && (typeof val !== "undefined") && populated) {
					plasmoid.configuration[configKey] = val
					console.log('plasmoid.configuration', configKey, val)
				}
			}
		}
	}

	function size() {
		if (typeof model === "number") {
			return model
		} else if (typeof model.count === "number") {
			return model.count
		} else if (typeof model.length === "number") {
			return model.length
		} else {
			return 0
		}
	}

	function findValue(val) {
		for (var i = 0; i < size(); i++) {
			if (model[i][valueRole2] == val) {
				return i
			}
		}
		return -1
	}

	function selectValue(val) {
		var index = findValue(val)
		if (index >= 0) {
			currentIndex = index
		}
	}
}
