plugins {
    alias(libs.plugins.kotlinJvm)
    alias(libs.plugins.composeMultiplatform)
    alias(libs.plugins.composeCompiler)
    id("de.stefan-oltmann.gradle-msix-plugin") version "0.2.1"
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
            packageVersion = "0.3.8"
            description = "Companion app for The Baker's Archive"
            copyright = "© 2026 All Things Toasty Software Ltd. All rights reserved."
            vendor = "All Things Toasty Software Ltd"

            targetFormats(
                org.jetbrains.compose.desktop.application.dsl.TargetFormat.Msi,
                org.jetbrains.compose.desktop.application.dsl.TargetFormat.Exe
            )

            windows {
                upgradeUuid = "c35b8d97-f8e8-4168-a1d1-ca300cc84017"
                menuGroup = "Baker's Archive"
                iconFile.set(project.file("src/main/resources/icon.ico"))
                dirChooser = true
            }
        }
    }
}

msix {
    val envPfxPath = System.getenv("MSIX_PFX_PATH")
    val envPfxPassword = System.getenv("MSIX_PFX_PASSWORD")

    if (!envPfxPath.isNullOrEmpty() && !envPfxPassword.isNullOrEmpty()) {
        signingPfx.set(file(envPfxPath))
        signingPassword.set(envPfxPassword)
    }
    svgIcon.set(layout.projectDirectory.file("src/main/resources/icon.svg"))
    manifest {
        appId.set("TheBakersArchive")
        displayName.set("The Baker's Archive")
        description.set("Companion app for The Baker's Archive")
        identityName.set("ToastySoftware.TheBakersArchive")
        publisher.set("CN=85C6607D-F08D-4FDB-ACC4-DAD6918EECFC")
        publisherDisplayName.set("Toasty Software")
        version.set("0.3.8.0")
        processorArchitecture.set("x64")
        appExecutable.set("bakers-archive.exe")
    }
}