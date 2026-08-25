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

@Composable
fun ArchiveListScreen(
    odooService: OdooService,
    onArchiveClick: (Archive) -> Unit,
) {
  val scope = rememberCoroutineScope()

  var archives by remember {
    mutableStateOf<List<Archive>>(
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

  fun loadArchives() {
    scope.launch {
      isLoading = true
      errorMessage = null

      odooService
          .getArchives()
          .onSuccess { loadedArchives ->
            archives = loadedArchives
          }
          .onFailure { error ->
            errorMessage = error.message ?: "An unknown error occurred."
          }

      isLoading = false
    }
  }

  LaunchedEffect(Unit) {
    loadArchives()
  }

  Scaffold(
      topBar = {
        TopAppBar(
            title = {
              Text(
                  "Baker's Archive",
              )
            },
        )
      },
  ) { padding ->
    when {
      isLoading -> {
        ArchiveListLoadingContent(
            padding = padding,
        )
      }

      errorMessage != null -> {
        ArchiveListErrorContent(
            padding = padding,
            errorMessage = errorMessage!!,
            onRetry = {
              loadArchives()
            },
        )
      }

      archives.isEmpty() -> {
        ArchiveListEmptyContent(
            padding = padding,
        )
      }

      else -> {
        ArchiveList(
            padding = padding,
            archives = archives,
            onArchiveClick = onArchiveClick,
        )
      }
    }
  }
}

@Composable
private fun ArchiveList(
    padding: PaddingValues,
    archives: List<Archive>,
    onArchiveClick: (Archive) -> Unit,
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
    items(
        items = archives,
        key = { archive ->
          archive.id
        },
    ) { archive ->
      ArchiveCard(
          archive = archive,
          onClick = {
            onArchiveClick(
                archive,
            )
          },
      )
    }
  }
}

@Composable
private fun ArchiveCard(
    archive: Archive,
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
          text = archive.name,
          style = MaterialTheme.typography.titleLarge,
      )

      if (!archive.subtitle.isNullOrBlank()) {
        Spacer(
            modifier =
                Modifier.height(
                    6.dp,
                ),
        )

        Text(
            text = archive.subtitle,
            style = MaterialTheme.typography.bodyMedium,
        )
      }
    }
  }
}

@Composable
private fun ArchiveListLoadingContent(
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
private fun ArchiveListErrorContent(
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
          text = "Couldn't load the archives.",
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

@Composable
private fun ArchiveListEmptyContent(
    padding: PaddingValues,
) {
  Box(
      modifier = Modifier.fillMaxSize().padding(padding),
      contentAlignment = Alignment.Center,
  ) {
    Text(
        "No archives found.",
    )
  }
}
