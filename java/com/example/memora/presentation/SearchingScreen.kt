package com.example.memora.presentation

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.*
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.*
import kotlinx.coroutines.delay

@Composable
fun SearchingScreen(onNext: () -> Unit) {

    LaunchedEffect(Unit) {
        delay(2000)
        onNext()
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.White),
        contentAlignment = Alignment.Center
    ) {

        Column(horizontalAlignment = Alignment.CenterHorizontally) {

            CircularProgressIndicator(color = Color(0xFF6A1B9A))

            Spacer(modifier = Modifier.height(12.dp))

            Text("جاري البحث عن الهاتف...", fontSize = 12.sp)

            Spacer(modifier = Modifier.height(4.dp))

            Text("جاري الاتصال...", fontSize = 10.sp, color = Color.Gray)
        }
    }
}