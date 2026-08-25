package uk.co.toastysoftware.bakers_archive

import androidx.compose.ui.window.Window
import androidx.compose.ui.window.application

fun main() = application {
    val odooService = OdooService(
        baseUrl = "https://www.austinatts.co.uk",
    )

    Window(
        onCloseRequest = ::exitApplication,
        title = "The Baker's Archive",
    ) {
        App(
            odooService = odooService,
        )
    }
}