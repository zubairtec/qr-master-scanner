plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.qrcode_scanner"
    compileSdk = 35
    ndkVersion = "27.0.12077973"
 
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

        sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.zbtech.qr_master_scanner"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
        multiDexEnabled = true 

    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("debug")
        }
        getByName("debug") {
            isDebuggable = true
            applicationIdSuffix = ".debug"
        }
    }
    buildFeatures {
        compose = false
        // Set to true if using Jetpack Compose
        buildConfig = true
        viewBinding = true
    }
}

flutter {
    source = "../.."
}
dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.8.22")
    implementation("com.google.android.gms:play-services-ads:22.6.0") 
    
    // AndroidX Core
    implementation("androidx.core:core-ktx:1.13.0")
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("androidx.constraintlayout:constraintlayout:2.2.0")
    
    // Material Design
    implementation("com.google.android.material:material:1.11.0") 
}
