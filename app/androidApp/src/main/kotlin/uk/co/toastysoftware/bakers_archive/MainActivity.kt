package uk.co.toastysoftware.bakers_archive

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent

class MainActivity : ComponentActivity() {

  private val odooService =
      OdooService(
          baseUrl = "https://www.austinatts.co.uk",
      )

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    setContent {
      App(odooService = odooService)
    }
  }

  override fun onDestroy() {
    odooService.close()
    super.onDestroy()
  }
}
