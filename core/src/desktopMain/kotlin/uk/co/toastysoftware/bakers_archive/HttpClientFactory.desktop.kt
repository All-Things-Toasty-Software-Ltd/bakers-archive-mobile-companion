package uk.co.toastysoftware.bakers_archive

import io.ktor.client.*
import io.ktor.client.engine.java.*
import io.ktor.client.plugins.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.serialization.json.Json

actual fun createHttpClient(): HttpClient {
  return HttpClient(Java) {
    install(ContentNegotiation) {
      json(
          Json {
            ignoreUnknownKeys = true
            isLenient = true
            explicitNulls = false
          },
      )
    }

    install(HttpTimeout) {
      connectTimeoutMillis = 15_000
      requestTimeoutMillis = 15_000
    }
  }
}
