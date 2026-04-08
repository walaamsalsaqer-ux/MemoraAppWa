package com.example.memora.presentation

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.*
import com.google.firebase.firestore.FirebaseFirestore

@Composable
fun PairWatchScreen(onNext: () -> Unit) {

    val mainColor = Color(0xFF7B1FA2)

    var pairingCode by remember { mutableStateOf("") }
    var isPaired by remember { mutableStateOf(false) }

    val db = FirebaseFirestore.getInstance()

    //////////////////////////////////////////////////////
    // 🔥 توليد الكود مرة وحدة
    //////////////////////////////////////////////////////
    LaunchedEffect(Unit) {

        val code = (100000..999999).random().toString()
        pairingCode = code

        db.collection("pairing_codes")
            .document(code)
            .set(
                mapOf(
                    "paired" to false,
                    "createdAt" to System.currentTimeMillis()
                )
            )
    }

    //////////////////////////////////////////////////////
    // 🔥 مراقبة الربط
    //////////////////////////////////////////////////////
    LaunchedEffect(pairingCode) {

        if (pairingCode.isNotEmpty()) {

            db.collection("pairing_codes")
                .document(pairingCode)
                .addSnapshotListener { snapshot, _ ->

                    val paired = snapshot?.getBoolean("paired") ?: false

                    if (paired && !isPaired) {
                        isPaired = true
                        onNext()
                    }
                }
        }
    }

    //////////////////////////////////////////////////////
    // UI
    //////////////////////////////////////////////////////
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black),
        contentAlignment = Alignment.Center
    ) {

        Box(
            modifier = Modifier
                .size(200.dp)
                .background(Color.White, RoundedCornerShape(100.dp)),
            contentAlignment = Alignment.Center
        ) {

            Column(
                horizontalAlignment = Alignment.CenterHorizontally
            ) {

                Text(
                    text = "اربط الساعة",
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold
                )

                Spacer(modifier = Modifier.height(6.dp))

                Text(
                    text = "أدخل هذا الكود في التطبيق",
                    fontSize = 10.sp,
                    color = Color.Gray
                )

                Spacer(modifier = Modifier.height(12.dp))

                Box(
                    modifier = Modifier
                        .width(120.dp)
                        .height(50.dp)
                        .background(mainColor, RoundedCornerShape(20.dp)),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = pairingCode,
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                }
            }
        }
    }
}