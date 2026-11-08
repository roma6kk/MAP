package com.example.lab_06

import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.net.Uri
import android.os.BatteryManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        MethodChannel(messenger, "lab06/sensors").setMethodCallHandler { call, result ->
            when (call.method) {
                "getLightLevel" -> readLightLevel(result)
                else -> result.notImplemented()
            }
        }

        MethodChannel(messenger, "lab06/battery").setMethodCallHandler { call, result ->
            when (call.method) {
                "getBatteryLevel" -> {
                    val manager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
                    result.success(
                        mapOf(
                            "level" to manager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY),
                            "platform" to "Android",
                            "api" to "BatteryManager.BATTERY_PROPERTY_CAPACITY"
                        )
                    )
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(messenger, "lab06/apps").setMethodCallHandler { call, result ->
            when (call.method) {
                "openMail" -> {
                    val subject = call.argument<String>("subject").orEmpty()
                    val intent = Intent(Intent.ACTION_SENDTO, Uri.parse("mailto:"))
                        .putExtra(Intent.EXTRA_SUBJECT, subject)
                    try {
                        startActivity(intent)
                        result.success(true)
                    } catch (e: ActivityNotFoundException) {
                        result.error("NO_MAIL_APP", "На устройстве нет приложения почты", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun readLightLevel(result: MethodChannel.Result) {
        val sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        val light = sensorManager.getDefaultSensor(Sensor.TYPE_LIGHT)
        if (light == null) {
            result.error("NO_SENSOR", "Датчик освещённости отсутствует на устройстве", null)
            return
        }
        var replied = false
        val listener = object : SensorEventListener {
            override fun onSensorChanged(event: SensorEvent) {
                if (replied) return
                replied = true
                sensorManager.unregisterListener(this)
                result.success(event.values[0].toDouble())
            }

            override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) = Unit
        }
        sensorManager.registerListener(listener, light, SensorManager.SENSOR_DELAY_NORMAL)
    }
}
