
package com.example.memora.presentation

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.runtime.*

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            AppNavigator()
        }
    }
}

@Composable
fun AppNavigator() {

    var screen by remember { mutableStateOf("welcome") }

    when (screen) {

        "welcome" -> WelcomeScreen { screen = "pair" }

        "pair" -> PairWatchScreen { screen = "searching" }

        "searching" -> SearchingScreen { screen = "complete" }

        "complete" -> PairingCompleteScreen { screen = "home" }

        "home" -> HomeScreen()
    }
}