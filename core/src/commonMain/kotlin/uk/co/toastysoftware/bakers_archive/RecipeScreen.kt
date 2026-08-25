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
import kotlinx.serialization.json.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RecipeScreen(
    recipeId: Long,
    title: String,
    odooService: OdooService,
    onBack: () -> Unit,
) {
  val scope = rememberCoroutineScope()

  var recipe by remember {
    mutableStateOf<SerializedRecord?>(
        null,
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

  fun loadRecipe() {
    scope.launch {
      isLoading = true
      errorMessage = null

      odooService
          .getRecipe(
              recipeId = recipeId,
          )
          .onSuccess { loadedRecipe ->
            recipe = loadedRecipe
          }
          .onFailure { error ->
            errorMessage = error.message ?: "An unknown error occurred."
          }

      isLoading = false
    }
  }

  LaunchedEffect(
      recipeId,
  ) {
    loadRecipe()
  }

  Scaffold(
      topBar = {
        TopAppBar(
            title = {
              Text(
                  recipe?.displayName ?: title,
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
        RecipeLoadingContent(
            padding = padding,
        )
      }

      errorMessage != null -> {
        RecipeErrorContent(
            padding = padding,
            errorMessage = errorMessage!!,
            onRetry = {
              loadRecipe()
            },
        )
      }

      recipe != null -> {
        RecipeGenericContent(
            padding = padding,
            recipe = recipe!!,
        )
      }
    }
  }
}

@Composable
private fun RecipeGenericContent(
    padding: PaddingValues,
    recipe: SerializedRecord,
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
    item {
      Text(
          text = recipe.displayName,
          style = MaterialTheme.typography.headlineMedium,
      )
    }

    items(
        items = recipe.fields,
        key = { field ->
          field.name
        },
    ) { field ->
      SerializedFieldCard(
          field = field,
      )
    }
  }
}

@Composable
private fun SerializedFieldCard(
    field: SerializedField,
) {
  Card(
      modifier = Modifier.fillMaxWidth(),
  ) {
    Column(
        modifier =
            Modifier.padding(
                16.dp,
            ),
    ) {
      Text(
          text = field.label,
          style = MaterialTheme.typography.titleMedium,
      )

      Text(
          text =
              formatJsonValue(
                  field.value,
              ),
          style = MaterialTheme.typography.bodyMedium,
      )

      if (field.error != null) {
        Text(
            text = field.error,
            color = MaterialTheme.colorScheme.error,
            style = MaterialTheme.typography.bodySmall,
        )
      }
    }
  }
}

/**
 * Generic JSON formatter.
 *
 * This is the fallback for fields the application does not yet know how to render specifically.
 */
private fun formatJsonValue(
    value: JsonElement?,
): String {
  return when (value) {
    null,
    JsonNull -> {
      "Not set"
    }

    is JsonPrimitive -> {
      value.content
    }

    is JsonArray -> {
      if (value.isEmpty()) {
        "None"
      } else {
        value.joinToString(
            separator = "\n",
        ) { item ->
          formatJsonValue(
              item,
          )
        }
      }
    }

    is JsonObject -> {
      value.entries.joinToString(
          separator = "\n",
      ) { entry ->
        "${entry.key}: ${
                    formatJsonValue(
                        entry.value,
                    )
                }"
      }
    }

    else -> {
      value.toString()
    }
  }
}

@Composable
private fun RecipeLoadingContent(
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
private fun RecipeErrorContent(
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
          text = "Couldn't load this recipe.",
          style = MaterialTheme.typography.titleMedium,
      )

      Text(
          text = errorMessage,
          color = MaterialTheme.colorScheme.error,
          style = MaterialTheme.typography.bodyMedium,
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
