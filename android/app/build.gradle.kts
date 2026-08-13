plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // No version here — it's inherited from the root plugins block above.
    id("com.google.gms.google-services")
}
 
android {
    namespace = "com.example.huddle"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
 
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
 
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }
 
    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.huddle"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
 
    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}
 
flutter {
    source = "../.."
}
 
dependencies {
    // Import the Firebase BoM — this pins compatible versions for you,
    // so don't specify versions on individual Firebase libraries below.
    implementation(platform("com.google.firebase:firebase-bom:34.17.0"))
 
    // Add the Firebase products you actually use, no version numbers needed:
    implementation("com.google.firebase:firebase-analytics")
    // implementation("com.google.firebase:firebase-auth")
    // implementation("com.google.firebase:firebase-firestore")
    // implementation("com.google.firebase:firebase-messaging")
    // https://firebase.google.com/docs/android/setup#available-libraries
}
 
