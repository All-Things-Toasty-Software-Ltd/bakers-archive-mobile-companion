package uk.co.toastysoftware.bakers_archive

import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.engine.android.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.request.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.serialization.json.Json

class OdooService(
    private val baseUrl: String,
) {

  private val client =
      HttpClient(Android) {
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

  /**
   * Discover all public archives.
   *
   * GET /archive/api/v1/archives
   */
  suspend fun getArchives(): Result<List<Archive>> = runCatching {
    val response =
        client
            .get(
                "$baseUrl/archive/api/v1/archives",
            )
            .body<ArchivesResponse>()

    response.archives.map { archive ->
      archive.toArchive()
    }
  }

  /**
   * Get one archive and a page of lightweight recipe cards.
   *
   * GET /archive/api/v1/archive/<id>?page=1&limit=20
   */
  suspend fun getArchive(
      archiveId: Long,
      page: Int = 1,
      limit: Int = 20,
  ): Result<ArchiveResponse> = runCatching {
    client
        .get(
            "$baseUrl/archive/api/v1/archive/$archiveId?page=$page&limit=$limit",
        )
        .body<ArchiveResponse>()
  }

  /**
   * Fetch the full generic representation of a recipe.
   *
   * This is only called when the user actually opens a recipe.
   *
   * GET /archive/api/v1/recipe/<id>
   */
  suspend fun getRecipe(
      recipeId: Long,
  ): Result<SerializedRecord> = runCatching {
    client
        .get(
            "$baseUrl/archive/api/v1/recipe/$recipeId",
        )
        .body<RecipeResponse>()
        .data
  }

  fun close() {
    client.close()
  }
}
