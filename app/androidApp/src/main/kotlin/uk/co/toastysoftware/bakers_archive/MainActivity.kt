package uk.co.toastysoftware.bakers_archive

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent

class MainActivity : ComponentActivity() {

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    val odooService = OdooService(baseUrl = "https://www.austinatts.co.uk")

    setContent {
      App(odooService = odooService)
    }
  }
}
