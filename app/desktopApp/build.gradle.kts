plugins {
    alias(libs.plugins.kotlinJvm)
    alias(libs.plugins.composeMultiplatform)
    alias(libs.plugins.composeCompiler)
}

kotlin {
    jvmToolchain(17)
}

dependencies {
    implementation(projects.core)

    implementation(compose.desktop.currentOs)
    implementation(libs.compose.material3)
}

compose.desktop {
    application {
        mainClass = "uk.co.toastysoftware.bakers_archive.MainKt"

        nativeDistributions {
            packageName = "bakers-archive"
            packageVersion = "0.3.4"
        }
    }
}