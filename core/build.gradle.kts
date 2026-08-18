plugins {
  alias(libs.plugins.kotlinMultiplatform)
  alias(libs.plugins.androidMultiplatformLibrary)
  alias(libs.plugins.composeMultiplatform)
  alias(libs.plugins.composeCompiler)
  alias(libs.plugins.kotlinSerialization)
}

kotlin {
  android {
    namespace = "uk.co.toastysoftware.bakers_archive.core"
    compileSdk = libs.versions.android.compileSdk.get().toInt()
    minSdk = libs.versions.android.minSdk.get().toInt()

    compilerOptions {
      jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
    androidResources {
      enable = true
    }
    withHostTest {
      isIncludeAndroidResources = true
    }
  }

  sourceSets {
    commonMain.dependencies {
      implementation(libs.compose.runtime)
      implementation(libs.compose.foundation)
      implementation(libs.compose.ui)
      implementation(libs.compose.material3)
      implementation(libs.compose.components.resources)

      implementation(libs.koin.core)
      implementation(libs.koin.compose)

      implementation(libs.ktor.client.core)
      implementation(libs.ktor.client.content.negotiation)
      implementation(libs.ktor.serialization.kotlinx.json)

      implementation(libs.kotlinx.coroutinesSwing)
      implementation(libs.kotlinx.serialization.json)
    }

    androidMain.dependencies {
      implementation(libs.compose.uiToolingPreview)
    }
  }
}
