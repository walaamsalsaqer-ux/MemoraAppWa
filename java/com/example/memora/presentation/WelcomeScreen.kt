package com.example.memora.presentation
import com.example.memora.R
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.*
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.*

@Composable
fun WelcomeScreen(onNext: () -> Unit) {

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.White),
        contentAlignment = Alignment.Center
    ) {

        Column(horizontalAlignment = Alignment.CenterHorizontally) {

            Image(
                painter = painterResource(id = R.drawable.memora_logo),
                contentDescription = null,
                modifier = Modifier.size(75.dp)
            )

            Spacer(modifier = Modifier.height(14.dp))

            Text(
                text = "مرحباً، دع ميمورا تعتني بك",
                fontSize = 12.sp,
                color = Color.Gray,
                textAlign = TextAlign.Center
            )

            Spacer(modifier = Modifier.height(16.dp))

            Row {
                Dot(true)
                Dot(false)
                Dot(false)
                Dot(false)
            }

            Spacer(modifier = Modifier.height(20.dp))

            Button(
                onClick = onNext,
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF6A1B9A)),
                shape = RoundedCornerShape(50)
            ) {
                Text("ابدأ", fontSize = 10.sp)
            }
        }
    }
}

@Composable
fun Dot(active: Boolean) {
    Box(
        modifier = Modifier
            .padding(3.dp)
            .size(if (active) 7.dp else 5.dp)
            .background(
                if (active) Color(0xFF6A1B9A) else Color.LightGray,
                shape = CircleShape
            )
    )
}