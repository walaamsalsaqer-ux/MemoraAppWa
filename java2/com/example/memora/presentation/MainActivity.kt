package com.example.memora.presentation

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.runtime.*
import com.google.firebase.FirebaseApp

// 🔥 مهم: استيراد الصفحات
import com.example.memora.presentation.PairWatchScreen
import com.example.memora.presentation.SearchingScreen
import com.example.memora.presentation.PairingCompleteScreen
import com.example.memora.presentation.HomeScreen
import com.example.memora.presentation.WelcomeScreen

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        FirebaseApp.initializeApp(this)

        setContent {
            AppNavigator()
        }
    }
}

@Composable
fun AppNavigator() {

    var screen by remember { mutableStateOf("welcome") }

    when (screen) {

        "welcome" -> WelcomeScreen {
            screen = "pair"
        }

        "pair" -> PairWatchScreen {
            screen = "searching"
        }

        "searching" -> SearchingScreen {
            screen = "complete"
        }

        "complete" -> PairingCompleteScreen {
            screen = "home"
        }

        "home" -> HomeScreen()
    }
}