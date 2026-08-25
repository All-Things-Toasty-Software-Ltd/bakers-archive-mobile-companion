package uk.co.toastysoftware.bakers_archive

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonElement

/** GET /archive/api/v1/archives */
@Serializable
data class ArchivesResponse(
    @SerialName("api_version") val apiVersion: String,
    val archives: List<ArchiveApi>,
)

/**
 * Raw archive returned by the discovery API.
 */
@Serializable
data class ArchiveApi(
    val id: Long,
    val name: String,
    val subtitle: JsonElement? = null,
    val url: String,
    @SerialName("feed_url") val feedUrl: String,
    @SerialName("api_url") val apiUrl: String,
)

/** GET /archive/api/v1/archive/<archive_id> */
@Serializable
data class ArchiveResponse(
    @SerialName("api_version") val apiVersion: String,
    val data: ArchiveData,
    val recipes: RecipePage,
)

/** Archive metadata returned by the archive endpoint. */
@Serializable
data class ArchiveData(
    val id: Long,
    val model: String,
    val name: String,
    val subtitle: JsonElement? = null,
)

/** Paginated collection of lightweight recipe summaries. */
@Serializable
data class RecipePage(
    val page: Int,
    val limit: Int,
    val total: Int,
    @SerialName("page_count") val pageCount: Int,
    val items: List<RecipeSummary>,
)

/**
 * Lightweight recipe data used for recipe cards.
 *
 * The complete recipe is fetched only when the user opens it.
 */
@Serializable
data class RecipeSummary(
    val id: Long,
    val name: String,
    val teaser: String? = null,
    @SerialName("published_date") val publishedDate: String? = null,
    @SerialName("api_url") val apiUrl: String,
)

/** GET /archive/api/v1/recipe/<recipe_id> */
@Serializable
data class RecipeResponse(
    @SerialName("api_version") val apiVersion: String,
    val data: SerializedRecord,
)

/**
 * Generic representation returned by the recipe API.
 *
 * Unknown future fields can be handled without immediately updating the mobile application's API
 * models.
 */
@Serializable
data class SerializedRecord(
    val model: String,
    @SerialName("model_label") val modelLabel: String,
    val id: Long,
    @SerialName("display_name") val displayName: String,
    val reference: Boolean = false,
    val fields: List<SerializedField> = emptyList(),
)

/** Generic field returned by the serializer. */
@Serializable
data class SerializedField(
    val name: String,
    val label: String,
    val type: String,
    val value: JsonElement? = null,
    val selection: List<SelectionOption>? = null,
    val error: String? = null,
)

@Serializable
data class SelectionOption(
    val value: JsonElement,
    val label: String,
)
