import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 릴리스 서명 정보. android/key.properties 에 keystore 경로·비밀번호를 두고
// 절대 커밋하지 않는다(.gitignore 처리됨). 파일이 없으면 debug 서명으로
// 폴백해 `flutter run --release` 는 계속 동작한다.
//
// key.properties 형식:
//   storeFile=upload-keystore.jks   (android/app/ 기준 상대 경로)
//   storePassword=...
//   keyAlias=upload
//   keyPassword=...
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

android {
    namespace = "com.mople.mobile"
    // flutter_secure_storage가 Android SDK 37로 컴파일되므로, 의존성의
    // 요구사항을 만족하는 최신 설치 SDK로 맞춘다.
    compileSdk = 37
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
        applicationId = "com.mople.mobile"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // 카카오 네이티브 앱 키. AndroidManifest 의 리다이렉트 scheme 에 주입된다.
        // 로컬에서는 gradle.properties(또는 ~/.gradle/gradle.properties)에
        // kakaoNativeAppKey=발급받은_키 를 넣어 두면 된다.
        manifestPlaceholders["KAKAO_NATIVE_APP_KEY"] =
            (project.findProperty("kakaoNativeAppKey") as String?) ?: ""
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // 스토어 업로드용 빌드는 반드시 key.properties 가 있어야 한다.
            // 없으면 debug 서명 폴백이라 Play Console 이 AAB 를 거부한다.
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
