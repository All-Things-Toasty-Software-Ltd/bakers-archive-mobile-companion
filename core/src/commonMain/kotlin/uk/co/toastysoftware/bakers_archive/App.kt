package uk.co.toastysoftware.bakers_archive

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier

private sealed interface AppPage {

  data object Archives : AppPage

  data class ArchiveDetails(
      val archive: Archive,
  ) : AppPage

  data class RecipeDetails(
      val recipeId: Long,
      val title: String,
  ) : AppPage
}

@Composable
fun App(
    odooService: OdooService,
) {
  val navigationStack = remember {
    mutableStateListOf<AppPage>(
        AppPage.Archives,
    )
  }

  val currentPage = navigationStack.last()

  fun navigateTo(page: AppPage) {
    navigationStack.add(page)
  }

  fun goBack() {
    if (navigationStack.size > 1) {
      navigationStack.removeAt(
          navigationStack.lastIndex,
      )
    }
  }

  MaterialTheme {
    Surface(
        modifier = Modifier.fillMaxSize(),
    ) {
      when (currentPage) {
        AppPage.Archives -> {
          ArchiveListScreen(
              odooService = odooService,
              onArchiveClick = { archive ->
                navigateTo(
                    AppPage.ArchiveDetails(
                        archive = archive,
                    ),
                )
              },
          )
        }

        is AppPage.ArchiveDetails -> {
          ArchiveScreen(
              archive = currentPage.archive,
              odooService = odooService,
              onBack = {
                goBack()
              },
              onRecipeClick = { recipe ->
                navigateTo(
                    AppPage.RecipeDetails(
                        recipeId = recipe.id,
                        title = recipe.name,
                    ),
                )
              },
          )
        }

        is AppPage.RecipeDetails -> {
          RecipeScreen(
              recipeId = currentPage.recipeId,
              title = currentPage.title,
              odooService = odooService,
              onBack = {
                goBack()
              },
          )
        }
      }
    }
  }
}
