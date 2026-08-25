package uk.co.toastysoftware.bakers_archive

import io.ktor.client.call.*
import io.ktor.client.request.*

class OdooService(
    private val baseUrl: String,
) {

  private val client = createHttpClient()

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
