import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3

Item {
	id: monitorGraph

	//--- required
	property string sensorName
	property PlasmaCore.DataSource dataSource

	//--- settings
	property string label: 'Label'
	property string sublabel: currentValue
	property color accentColor: PlasmaCore.ColorScope.highlightColor
	property int numValues: 50
	property int maxValue: isNaN(sensorMax) ? 0 : Number(sensorMax)
	property real lineWidth: 1.5

	property int graphWidth: 80
	property int graphHeight: 60


	//--- private
	readonly property var sensorData: dataSource ? dataSource.data[sensorName] : null
	readonly property var sensorValue: sensorData ? sensorData.value : null
	readonly property var sensorMax: sensorData ? Number(sensorData.max) : NaN
	// property var sensorValue: sensorData ? sensorData.value : null
	property var values: []
	property int currentValue: 0

	//--- layout
	implicitWidth: graphLayout.implicitWidth
	implicitHeight: graphLayout.implicitHeight
	Layout.fillWidth: true

	//---
	Component.onCompleted: {
		// connectToSource()
		for (var i = 0; i < numValues; i++) {
			values.push(0)
		}
		canvas.requestPaint()
	}

	function connectToSource() {
		if (dataSource.connectedSources.indexOf(sensorName) == -1) {
			console.log('connectSource', sensorName)
			dataSource.connectSource(sensorName)
		}
	}

	Connections {
		target: dataSource
		onSourceAdded: {
			if (source == monitorGraph.sensorName) {
				monitorGraph.connectToSource()
			}
		}
	}

	function addValue(value) {
		values.shift()
		values.push(value)
		currentValue = value
		valuesChanged()
	}

	function tick() {
		// console.log(dataSource, sensorName, JSON.stringify(sensorData))
		if (typeof sensorValue !== 'undefined') {
			var value = Number(sensorValue)
			addValue(value)
		} else {
			addValue(0)
		}
		canvas.requestPaint()
	}

	RowLayout {
		id: graphLayout
		anchors.fill: parent
		spacing: units.smallSpacing

		Canvas {
			id: canvas
			implicitWidth: monitorGraph.graphWidth * units.devicePixelRatio
			implicitHeight: monitorGraph.graphHeight * units.devicePixelRatio
			Layout.fillHeight: true

			onPaint: {
				var ctx = getContext("2d")
				ctx.reset()

				ctx.strokeStyle = Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 1.0)
				ctx.fillStyle = Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.5)
				ctx.lineWidth = monitorGraph.lineWidth * units.devicePixelRatio

				function plotValue(index, numValues, value, yAxisMax) {
					var x = ((index+1)/numValues) * width
					var y = height - (value/yAxisMax) * height
					return Qt.point(x, y)
				}
				var yAxisMax = maxValue
				if (maxValue == 0) {
					yAxisMax = Math.max.apply(null, values)
				}
				// console.log('values', JSON.stringify(values))
				// console.log('maxValue', maxValue, 'yAxisMax', yAxisMax)
				ctx.beginPath()
				ctx.moveTo(0, height) // bottom left
				for (var i = 0; i < values.length; i++) {
					var value = values[i]
					var p = plotValue(i, values.length, value, yAxisMax)
					ctx.lineTo(p.x, p.y)
				}
				ctx.stroke()

				ctx.lineTo(width, height) // bottom right
				ctx.lineTo(0, height) // bottom left
				ctx.fill()

				ctx.strokeRect(
					0 + ctx.lineWidth/2,
					0 + ctx.lineWidth/2,
					width - ctx.lineWidth/2*2,
					height - ctx.lineWidth/2*2
				)
			}
		}

		ColumnLayout {
			spacing: 0
			Layout.alignment: Qt.AlignTop | Qt.AlignLeft

			PlasmaComponents3.Label {
				text: monitorGraph.label
				font.pointSize: -1
				font.pixelSize: 16 * units.devicePixelRatio
				font.weight: Font.Bold
				Layout.fillWidth: true
				Layout.preferredHeight: paintedHeight
			}

			PlasmaComponents3.Label {

				text: monitorGraph.sublabel
				font.pointSize: -1
				font.pixelSize: 12 * units.devicePixelRatio
				horizontalAlignment: Text.AlignLeft
				opacity: 0.8
				Layout.fillWidth: true
				Layout.alignment: Qt.AlignTop | Qt.AlignLeft
				Layout.preferredHeight: paintedHeight
			}

		}
	}
}
