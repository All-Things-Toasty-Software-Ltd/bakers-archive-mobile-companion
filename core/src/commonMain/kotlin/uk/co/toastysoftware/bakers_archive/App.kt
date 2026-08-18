package uk.co.toastysoftware.bakers_archive

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun App(odooService: OdooService) {
    MaterialTheme {
        Surface(modifier = Modifier.fillMaxSize()) {
            RecipeListScreen(odooService = odooService)
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RecipeListScreen(odooService: OdooService) {
    
}