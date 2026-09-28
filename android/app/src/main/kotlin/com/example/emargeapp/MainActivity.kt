package com.example.emargeapp

import android.content.Context
import android.net.wifi.WifiManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "emarge/wifi"
    private var multicastLock: WifiManager.MulticastLock? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // 持有组播锁后 App 才能接收 mDNS 组播包（Android 默认过滤）
                    "acquireMulticastLock" -> try {
                        val wifi =
                            applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
                        multicastLock = wifi.createMulticastLock("emarge_mdns_lock").apply {
                            setReferenceCounted(true)
                            acquire()
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("MCAST_ERROR", e.message, null)
                    }

                    "releaseMulticastLock" -> try {
                        multicastLock?.let { if (it.isHeld) it.release() }
                        multicastLock = null
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("MCAST_ERROR", e.message, null)
                    }

                    else -> result.notImplemented()
                }
            }
    }
}
