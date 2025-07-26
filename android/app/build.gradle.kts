plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.vmrits.csc.scheme"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.vmrits.csc.scheme"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    applicationVariants.all { variant ->
        variant.outputs.all { output ->
            def flavor = variant.flavorName
                    def buildType = variant.buildType.name
                    def timestamp = new Date().format("yyyyMMdd_HHmmss")

            // Customize the APK name
            outputFileName = "CSC_Schem_kt_${flavor}_${buildType}_${timestamp}.apk"
        }
    }

    flavorDimensions "env"

    productFlavors {
        dev {
            dimension "env"
            applicationIdSuffix ".dev"
            versionName "1.0.4-dev"
            versionCode 5
        }
        prod {
            dimension "env"
            versionName "1.0.4"
            versionCode 4
        }
    }

    buildTypes {
        debug {
            // Debug-specific options
            applicationIdSuffix ".debug"
        }

        release {
            // Use real signingConfig in production!
            signingConfig signingConfigs.debug
                    minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile ('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}

flutter {
    source = "../.."
}
