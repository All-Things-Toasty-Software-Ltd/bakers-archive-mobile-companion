package uk.co.toastysoftware.bakers_archive

import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.contentOrNull

/** Convert the raw API archive into the application's clean Archive model. */
fun ArchiveApi.toArchive(): Archive {
  return Archive(
      id = id,
      name = name,
      subtitle = subtitle.asTextOrNull(),
      url = url,
      feedUrl = feedUrl,
      apiUrl = apiUrl,
  )
}

/** Get the archive subtitle as clean nullable text. */
fun ArchiveData.subtitleText(): String? {
  return subtitle.asTextOrNull()
}

/**
 * The Odoo API currently returns false for an empty Char field.
 */
private fun JsonElement?.asTextOrNull(): String? {
  val primitive = this as? JsonPrimitive ?: return null

  if (!primitive.isString) {
    return null
  }

  return primitive.contentOrNull?.trim()?.takeIf { it.isNotEmpty() }
}
