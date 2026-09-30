plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 从 local.properties 读取高德 API Key（local.properties 已加入 .gitignore，不会上传）
import java.util.Properties
val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(localPropertiesFile.inputStream())
}
val amapApiKey = localProperties.getProperty("amap.api.key", "")

android {
    namespace = "com.example.emergeapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // 显式声明 Kotlin 源集，确保 src/main/kotlin 被编译进 APK
    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    // 显式声明 debug 签名，确保使用 ~/.android/debug.keystore
    signingConfigs {
        getByName("debug") {
            storeFile = file("${System.getProperty("user.home")}/.android/debug.keystore")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
    }

    defaultConfig {
        applicationId = "com.example.emergeapp"
        // 高德地图 Key 通过 manifestPlaceholders 注入 AndroidManifest.xml
        manifestPlaceholders["amapApiKey"] = amapApiKey
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // 高德 SDK 仅提供 arm64-v8a / armeabi-v7a，不打包 x86_64 以避免模拟器找不到 .so 黑屏
        ndk {
            abiFilters += listOf("arm64-v8a", "armeabi-v7a")
        }
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
