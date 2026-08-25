package uk.co.toastysoftware.bakers_archive

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ArchiveScreen(
    archive: Archive,
    odooService: OdooService,
    onBack: () -> Unit,
    onRecipeClick: (RecipeSummary) -> Unit,
) {
  val scope = rememberCoroutineScope()

  var archiveData by remember {
    mutableStateOf<ArchiveData?>(
        null,
    )
  }

  var recipes by remember {
    mutableStateOf<List<RecipeSummary>>(
        emptyList(),
    )
  }

  var isLoading by remember {
    mutableStateOf(true)
  }

  var errorMessage by remember {
    mutableStateOf<String?>(
        null,
    )
  }

  fun loadArchive() {
    scope.launch {
      isLoading = true
      errorMessage = null

      odooService
          .getArchive(
              archiveId = archive.id,
          )
          .onSuccess { response ->
            archiveData = response.data
            recipes = response.recipes.items
          }
          .onFailure { error ->
            errorMessage = error.message ?: "An unknown error occurred."
          }

      isLoading = false
    }
  }

  LaunchedEffect(
      archive.id,
  ) {
    loadArchive()
  }

  Scaffold(
      topBar = {
        TopAppBar(
            title = {
              Text(
                  archiveData?.name ?: archive.name,
              )
            },
            navigationIcon = {
              IconButton(
                  onClick = onBack,
              ) {
                Text(
                    "←",
                )
              }
            },
        )
      },
  ) { padding ->
    when {
      isLoading -> {
        ArchiveLoadingContent(
            padding = padding,
        )
      }

      errorMessage != null -> {
        ArchiveErrorContent(
            padding = padding,
            errorMessage = errorMessage!!,
            onRetry = {
              loadArchive()
            },
        )
      }

      else -> {
        ArchiveContent(
            padding = padding,
            archiveData = archiveData,
            recipes = recipes,
            onRecipeClick = onRecipeClick,
        )
      }
    }
  }
}

@Composable
private fun ArchiveContent(
    padding: PaddingValues,
    archiveData: ArchiveData?,
    recipes: List<RecipeSummary>,
    onRecipeClick: (RecipeSummary) -> Unit,
) {
  LazyColumn(
      modifier = Modifier.fillMaxSize().padding(padding),
      contentPadding =
          PaddingValues(
              16.dp,
          ),
      verticalArrangement =
          Arrangement.spacedBy(
              12.dp,
          ),
  ) {
    val subtitle = archiveData?.subtitleText()

    if (!subtitle.isNullOrBlank()) {
      item {
        Text(
            text = subtitle,
            style = MaterialTheme.typography.bodyLarge,
        )
      }
    }

    if (recipes.isEmpty()) {
      item {
        Box(
            modifier = Modifier.fillMaxWidth().padding(32.dp),
            contentAlignment = Alignment.Center,
        ) {
          Text(
              "No recipes found in this archive.",
          )
        }
      }
    } else {
      items(
          items = recipes,
          key = { recipe ->
            recipe.id
          },
      ) { recipe ->
        RecipeSummaryCard(
            recipe = recipe,
            onClick = {
              onRecipeClick(
                  recipe,
              )
            },
        )
      }
    }
  }
}

@Composable
private fun RecipeSummaryCard(
    recipe: RecipeSummary,
    onClick: () -> Unit,
) {
  Card(
      modifier =
          Modifier.fillMaxWidth()
              .clickable(
                  onClick = onClick,
              ),
  ) {
    Column(
        modifier =
            Modifier.padding(
                16.dp,
            ),
    ) {
      Text(
          text = recipe.name,
          style = MaterialTheme.typography.titleLarge,
      )

      if (!recipe.teaser.isNullOrBlank()) {
        Spacer(
            modifier =
                Modifier.height(
                    8.dp,
                ),
        )

        Text(
            text = recipe.teaser,
            style = MaterialTheme.typography.bodyMedium,
            maxLines = 4,
        )
      }

      if (!recipe.publishedDate.isNullOrBlank()) {
        Spacer(
            modifier =
                Modifier.height(
                    12.dp,
                ),
        )

        Text(
            text = recipe.publishedDate,
            style = MaterialTheme.typography.bodySmall,
        )
      }
    }
  }
}

@Composable
private fun ArchiveLoadingContent(
    padding: PaddingValues,
) {
  Box(
      modifier = Modifier.fillMaxSize().padding(padding),
      contentAlignment = Alignment.Center,
  ) {
    CircularProgressIndicator()
  }
}

@Composable
private fun ArchiveErrorContent(
    padding: PaddingValues,
    errorMessage: String,
    onRetry: () -> Unit,
) {
  Box(
      modifier = Modifier.fillMaxSize().padding(padding).padding(24.dp),
      contentAlignment = Alignment.Center,
  ) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
      Text(
          text = "Couldn't load this archive.",
          style = MaterialTheme.typography.titleMedium,
      )

      Spacer(
          modifier =
              Modifier.height(
                  8.dp,
              ),
      )

      Text(
          text = errorMessage,
          color = MaterialTheme.colorScheme.error,
          style = MaterialTheme.typography.bodyMedium,
      )

      Spacer(
          modifier =
              Modifier.height(
                  16.dp,
              ),
      )

      Button(
          onClick = onRetry,
      ) {
        Text(
            "Try again",
        )
      }
    }
  }
}
