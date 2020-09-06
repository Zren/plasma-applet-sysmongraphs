import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0

import org.kde.kirigami 2.3 as Kirigami

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
	}
}
