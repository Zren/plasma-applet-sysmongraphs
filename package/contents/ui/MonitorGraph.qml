import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3

Item {
	id: monitorGraph

	//--- required
	property var sensorNames
	property PlasmaCore.DataSource dataSource

	//--- settings
	property string label: 'Label'
	property string sublabel: currentValue
	property var accentColors: [PlasmaCore.ColorScope.highlightColor]
	property color borderColor: accentColors[accentColors.length - 1]
	property int numValues: 50
	property int maxValue: 0
	property real lineWidth: 1.5

	property int graphWidth: 80
	property int graphHeight: 44

	property bool drawFill: sensorNames.length == 1


	//--- private
	property var firstCurrentValue: 0
	property var firstSensorMax: 0
	property var currentValues: []
	Repeater {
		id: sensorObjRepeater
		model: sensorNames.length
		Item {
			id: sensorObj
			readonly property string sensorName: monitorGraph.sensorNames[index]
			readonly property var sensorData: monitorGraph.dataSource ? monitorGraph.dataSource.data[sensorName] : null
			readonly property var sensorValue: sensorData ? sensorData.value : null
			readonly property var sensorMax: sensorData ? Number(sensorData.max) : NaN
			readonly property color sensorColor: monitorGraph.accentColors[index % monitorGraph.accentColors.length]

			property var values: []
			property int currentValue: 0

			function addValue(value) {
				values.shift()
				values.push(value)
				currentValue = value
				valuesChanged()
			}

			Component.onCompleted: {
				monitorGraph.connectSensor(sensorName)
				for (var i = 0; i < numValues; i++) {
					values.push(0)
				}
				canvas.requestPaint()
				// console.log('sensorObj.completed', sensorObj, sensorName)
			}
		}
	}

	//--- layout
	implicitWidth: graphLayout.implicitWidth
	implicitHeight: graphLayout.implicitHeight
	Layout.fillWidth: true
	Layout.fillHeight: true

	//---
	Component.onCompleted: {

	}

	Connections {
		target: dataSource
		onSourceAdded: {
			for (var i = 0; i < sensorNames; i++) {
				var sensorName = sensorNames[sensorIndex]
				monitorGraph.connectSensor(sensorName)
			}
		}
	}

	Connections {
		target: tickTimer
		onTriggered: monitorGraph.tick()
	}

	function connectSensor(sensorName) {
		if (dataSource.connectedSources.indexOf(sensorName) == -1) {
			console.log('connectSource', sensorName)
			dataSource.connectSource(sensorName)
		}
	}

	function tick() {
		var _currentValues = []
		for (var i = 0; i < sensorObjRepeater.count; i++) {
			var sensorObj = sensorObjRepeater.itemAt(i)
			// console.log(sensorObj.sensorName, JSON.stringify(sensorObj.sensorData))
			if (typeof sensorObj.sensorValue !== 'undefined') {
				var value = Number(sensorObj.sensorValue)
				sensorObj.addValue(value)
			} else {
				sensorObj.addValue(0)
			}
			_currentValues.push(sensorObj.currentValue)
			if (i == 0) {
				if (typeof sensorObj.sensorMax !== 'undefined') {
					monitorGraph.firstSensorMax = sensorObj.sensorMax
				}
				monitorGraph.firstCurrentValue = sensorObj.currentValue
			}
		}
		monitorGraph.currentValues = _currentValues
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

				var yAxisMax = maxValue
				if (maxValue == 0) {
					for (var i = 0; i < sensorObjRepeater.count; i++) {
						var sensorObj = sensorObjRepeater.itemAt(i)
						var sensorMax = sensorObj.sensorMax
						var dataMax = Math.max.apply(null, sensorObj.values)
						yAxisMax = Math.max(yAxisMax, sensorMax, dataMax)
					}
				}
				// console.log('yAxisMax', yAxisMax)


				function plotValue(index, numValues, value, yAxisMax) {
					var x = ((index+1)/numValues) * width
					var y = height - (value/yAxisMax) * height
					return Qt.point(x, y)
				}
				
				// console.log('sensorObjRepeater.count', sensorObjRepeater.count)
				for (var sensorIndex = 0; sensorIndex < sensorObjRepeater.count; sensorIndex++) {
					var sensorObj = sensorObjRepeater.itemAt(sensorIndex)
					var sColor = sensorObj.sensorColor
					// console.log(sensorIndex, 'sensorObj', sensorObj)
					// console.log(sensorIndex, 'sensorObj.sensorColor', sColor)
					

					ctx.strokeStyle = Qt.rgba(sColor.r, sColor.g, sColor.b, 1.0)
					ctx.fillStyle = Qt.rgba(sColor.r, sColor.g, sColor.b, 0.5)
					ctx.lineWidth = monitorGraph.lineWidth * units.devicePixelRatio

					ctx.beginPath()
					ctx.moveTo(0, height) // bottom left
					for (var i = 0; i < sensorObj.values.length; i++) {
						var value = sensorObj.values[i]
						var p = plotValue(i, sensorObj.values.length, value, yAxisMax)
						// console.log(p.x, p.y)
						ctx.lineTo(p.x, p.y)
					}
					ctx.stroke()

					if (monitorGraph.drawFill) {
						ctx.lineTo(width, height) // bottom right
						ctx.lineTo(0, height) // bottom left
						ctx.fill()
					}
				}

				ctx.strokeStyle = Qt.rgba(borderColor.r, borderColor.g, borderColor.b, 1.0)
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
				elide: Text.ElideRight
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
				elide: Text.ElideRight
			}

		}
	}
}
