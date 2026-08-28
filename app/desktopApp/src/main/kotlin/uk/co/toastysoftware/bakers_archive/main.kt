package uk.co.toastysoftware.bakers_archive

import androidx.compose.ui.res.painterResource
import androidx.compose.ui.window.Window
import androidx.compose.ui.window.application

fun main() {

  System.setProperty("java.net.preferIPv4Stack", "true")
  System.setProperty("jdk.net.usePlainSocketImpl", "true")

  System.setProperty("org.newsclub.net.unix.disable-native", "true")

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
