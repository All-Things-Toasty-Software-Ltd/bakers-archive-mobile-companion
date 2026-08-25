package uk.co.toastysoftware.bakers_archive

/** Internal representation of an archive. */
data class Archive(
    val id: Long,
    val name: String,
    val subtitle: String?,
    val url: String,
    val feedUrl: String,
    val apiUrl: String,
)
