package uk.co.toastysoftware.bakers_archive

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.launch

@Composable
fun App(odooService: OdooService) {
  MaterialTheme {
    Surface(modifier = Modifier.fillMaxSize()) {
      RecipeListScreen(odooService = odooService)
    }
  }
}

@Composable
fun RecipeListScreen(odooService: OdooService) {
  val scope = rememberCoroutineScope()

  var recipes by remember {
    mutableStateOf<List<ArchiveRecipe>>(emptyList())
  }

  var isLoading by remember {
    mutableStateOf(true)
  }

  var errorMessage by remember {
    mutableStateOf<String?>(null)
  }

  fun loadRecipes() {
    scope.launch {
      isLoading = true
      errorMessage = null

      val result = odooService.getRecipes()

      result
          .onSuccess { loadedRecipes ->
            recipes = loadedRecipes
          }
          .onFailure { error ->
            errorMessage = error.message ?: "An unknown error occurred."
          }

      isLoading = false
    }
  }

  LaunchedEffect(Unit) {
    loadRecipes()
  }

  Scaffold(
      topBar = {
        TopAppBar(
            title = {
              Text("Baker's Archive")
            },
            actions = {
              IconButton(
                  onClick = {
                    loadRecipes()
                  }
              ) {
                Text("↻")
              }
            },
        )
      }
  ) { padding ->
    when {
      isLoading -> {
        LoadingContent(padding)
      }

      errorMessage != null -> {
        ErrorContent(
            padding = padding,
            errorMessage = errorMessage!!,
            onRetry = {
              loadRecipes()
            },
        )
      }

      recipes.isEmpty() -> {
        EmptyContent(padding)
      }

      else -> {
        RecipeList(
            padding = padding,
            recipes = recipes,
        )
      }
    }
  }
}

@Composable
private fun LoadingContent(padding: PaddingValues) {
  Box(
      modifier = Modifier.fillMaxSize().padding(padding),
      contentAlignment = Alignment.Center,
  ) {
    CircularProgressIndicator()
  }
}

@Composable
private fun ErrorContent(
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
          text = "Couldn't load the archive.",
          style = MaterialTheme.typography.titleMedium,
      )

      Spacer(modifier = Modifier.height(8.dp))

      Text(
          text = errorMessage,
          color = MaterialTheme.colorScheme.error,
          style = MaterialTheme.typography.bodyMedium,
      )

      Spacer(modifier = Modifier.height(16.dp))

      Button(onClick = onRetry) {
        Text("Try again")
      }
    }
  }
}

@Composable
private fun EmptyContent(padding: PaddingValues) {
  Box(
      modifier = Modifier.fillMaxSize().padding(padding),
      contentAlignment = Alignment.Center,
  ) {
    Text("No recipes found.")
  }
}

@Composable
private fun RecipeList(
    padding: PaddingValues,
    recipes: List<ArchiveRecipe>,
) {
  LazyColumn(
      modifier = Modifier.fillMaxSize().padding(padding),
      contentPadding = PaddingValues(16.dp),
  ) {
    items(
        items = recipes,
        key = { recipe ->
          recipe.url
        },
    ) { recipe ->
      RecipeCard(recipe)
    }
  }
}

@Composable
private fun RecipeCard(recipe: ArchiveRecipe) {
  Card(modifier = Modifier.fillMaxWidth().padding(bottom = 12.dp)) {
    Column(modifier = Modifier.padding(16.dp)) {
      Text(
          text = recipe.name,
          style = MaterialTheme.typography.titleLarge,
      )

      if (recipe.summary.isNotBlank()) {
        Spacer(modifier = Modifier.height(6.dp))

        Text(
            text = recipe.summary,
            style = MaterialTheme.typography.bodyMedium,
            maxLines = 4,
        )
      }

      Spacer(modifier = Modifier.height(12.dp))

      Row(
          modifier = Modifier.fillMaxWidth(),
          horizontalArrangement = Arrangement.SpaceBetween,
          verticalAlignment = Alignment.CenterVertically,
      ) {
        AssistChip(
            onClick = {},
            label = {
              Text(recipe.archive)
            },
        )

        if (recipe.author.isNotBlank()) {
          Text(
              text = recipe.author,
              style = MaterialTheme.typography.bodySmall,
          )
        }
      }
    }
  }
}
