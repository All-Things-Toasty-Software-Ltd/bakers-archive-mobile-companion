package uk.co.toastysoftware.bakers_archive

import androidx.compose.ui.res.painterResource
import androidx.compose.ui.window.Window
import androidx.compose.ui.window.application

fun main() {

  System.setProperty("java.net.preferIPv4Stack", "true")
  System.setProperty("javax.net.ssl.trustStoreType", "WINDOWS-ROOT")

  application {
    val odooService =
        OdooService(
            baseUrl = "https://www.austinatts.co.uk",
        )

    Window(
        onCloseRequest = ::exitApplication,
        title = "The Baker's Archive",
        icon = painterResource("icon.ico"),
    ) {
      App(
          odooService = odooService,
      )
    }
  }
}
