package uk.co.toastysoftware.bakers_archive

import io.ktor.client.*
import io.ktor.client.engine.okhttp.*
import io.ktor.client.plugins.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.serialization.json.Json
import java.util.concurrent.TimeUnit

actual fun createHttpClient(): HttpClient {
  return HttpClient(Ok) {
    engine {
      config {
        connectTimeout(15, TimeUnit.SECONDS)
        readTimeout(15, TimeUnit.SECONDS)
        writeTimout(15, TimeUnit.SECONDS)
      }
    }
    install(ContentNegotiation) {
      json(
          Json {
            ignoreUnknownKeys = true
            isLenient = true
            explicitNulls = false
          },
      )
    }
  }
}
