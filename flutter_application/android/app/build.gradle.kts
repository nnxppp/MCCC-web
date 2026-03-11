plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ⬇️ ⬇️ ⬇️ เราเพิ่มส่วนนี้เข้ามา (สำหรับ Multidex) ⬇️ ⬇️ ⬇️
dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
// ⬆️ ⬆️ ⬆️ ---------------------------------------- ⬆️ ⬆️ ⬆️

android {
    // นี่คือชื่อ Package ของโปรเจกต์ใหม่คุณ (ถูกต้องแล้ว)
    namespace = "com.example.mccc_app" 
    
    // ⬇️ ⬇️ ⬇️ เราแก้ไขส่วนนี้ ⬇️ ⬇️ ⬇️
    // เรา "บังคับ" ใช้ SDK 36 (ตามที่ package ใหม่ๆ ต้องการ)
    // เราจะไม่ใช้ค่าจาก flutter.compileSdkVersion
    compileSdk = 36
    // ⬆️ ⬆️ ⬆️ -------------------- ⬆️ ⬆️ ⬆️

    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.mccc_app"
        
        // ⬇️ ⬇️ ⬇️ เราแก้ไข 3 บรรทัดนี้ทั้งหมด ⬇️ ⬇️ ⬇️
        // บังคับ minSdk 24 (สำหรับ Multidex และ Package ใหม่ๆ)
        minSdk = 24 
        // บังคับ targetSdk 36 (ให้ตรงกับ compileSdk)
        targetSdk = 36 
        // เปิดใช้งาน Multidex (นี่คือตัวแก้ปัญหาของเรา)
        multiDexEnabled = true 
        // ⬆️ ⬆️ ⬆️ --------------------------------- ⬆️ ⬆️ ⬆️

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}