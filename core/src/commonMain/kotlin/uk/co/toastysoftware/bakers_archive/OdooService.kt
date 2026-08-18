package uk.co.toastysoftware.bakers_archive

import io.ktor.client.*
import io.ktor.client.engine.android.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import java.io.StringReader
import javax.xml.parsers.DocumentBuilderFactory
import org.w3c.dom.Element
import org.xml.sax.InputSource

class OdooService(private val baseUrl: String) {

  private val client = HttpClient(Android)

  private val archives =
      listOf(
          Archive(
              name = "The Sourdough Archives",
              url = "$baseUrl/archive/the-sourdough-archives-1/feed",
          ),
          Archive(
              name = "Secondary Archive",
              url = "$baseUrl/archive/secondary-archive-2/feed",
          ),
      )

  suspend fun getRecipes(): Result<List<ArchiveRecipe>> = runCatching {
    archives
        .flatMap { archive ->
          getArchiveRecipes(archive)
        }
        .sortedByDescending { it.updated }
  }

  private suspend fun getArchiveRecipes(archive: Archive): List<ArchiveRecipe> {

    val xml = client.get(archive.url).bodyAsText()

    return parseFeed(xml, archive.name)
  }

  private fun parseFeed(
      xml: String,
      archiveName: String,
  ): List<ArchiveRecipe> {

    val factory = DocumentBuilderFactory.newInstance()

    factory.isNamespaceAware = true

    val builder = factory.newDocumentBuilder()

    val document = builder.parse(InputSource(StringReader(xml)))

    val entries = document.getElementsByTagNameNS("*", "entry")

    val recipes = mutableListOf<ArchiveRecipe>()

    for (i in 0 until entries.length) {

      val entry = entries.item(i)

      if (entry !is Element) {
        continue
      }

      val title = childText(entry, "title") ?: continue

      val idUrl = childText(entry, "id") ?: continue

      val link = findLink(entry) ?: idUrl

      val summary = childText(entry, "summary") ?: ""

      val author = findAuthor(entry) ?: ""

      val updated = childText(entry, "updated") ?: ""

      val recipeId = extractRecipeId(idUrl)

      recipes +=
          ArchiveRecipe(
              id = recipeId,
              name = title,
              url = link,
              summary = summary,
              author = author,
              updated = updated,
              archive = archiveName,
          )
    }

    return recipes
  }

  private fun childText(
      element: Element,
      name: String,
  ): String? {

    val nodes = element.getElementsByTagNameNS("*", name)

    if (nodes.length == 0) {
      return null
    }

    return nodes.item(0)?.textContent?.trim()?.takeIf { it.isNotEmpty() }
  }

  private fun findLink(entry: Element): String? {

    val links = entry.getElementsByTagNameNS("*", "link")

    for (i in 0 until links.length) {

      val node = links.item(i)

      if (node is Element) {

        val href = node.getAttribute("href")

        if (href.isNotBlank()) {
          return href
        }
      }
    }

    return null
  }

  private fun findAuthor(entry: Element): String? {

    val authors = entry.getElementsByTagNameNS("*", "author")

    if (authors.length == 0) {
      return null
    }

    val author = authors.item(0)

    if (author !is Element) {
      return null
    }

    return childText(author, "name")
  }

  private fun extractRecipeId(url: String): Long {

    val match = Regex("""-(\d+)$""").find(url)

    return match?.groupValues?.getOrNull(1)?.toLongOrNull() ?: 0L
  }
}
