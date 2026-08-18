package uk.co.toastysoftware.bakers_archive

import kotlinx.serialization.Serializable

@Serializable
data class ArchiveRecipe(
    val id: Long,
    val name: String,
    val url: String,
    val summary: String,
    val author: String,
    val updated: String,
    val archive: String,
)
