package com.example.memora.presentation
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.*
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.*
import com.example.memora.R

@Composable
fun PairingCompleteScreen(onNext: () -> Unit) {

    val mainColor = Color(0xFF7B1FA2)

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.White),
        contentAlignment = Alignment.Center
    ) {

        Column(
            horizontalAlignment = Alignment.CenterHorizontally
        ) {

            //////////////////////////////////////
            // 📱 —— ✔ —— ⌚
            //////////////////////////////////////
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.Center
            ) {

                // 📱 الجوال
                Image(
                    painter = painterResource(id = R.drawable.phone),
                    contentDescription = null,
                    modifier = Modifier.size(30.dp)
                )

                Spacer(modifier = Modifier.width(6.dp))

                // ➖ خط
                Box(
                    modifier = Modifier
                        .width(25.dp)
                        .height(2.dp)
                        .background(mainColor)
                )

                Spacer(modifier = Modifier.width(6.dp))

                // ✔ صح
                Text(
                    text = "✓",
                    fontSize = 16.sp,
                    color = mainColor
                )

                Spacer(modifier = Modifier.width(6.dp))

                // ➖ خط
                Box(
                    modifier = Modifier
                        .width(25.dp)
                        .height(2.dp)
                        .background(mainColor)
                )

                Spacer(modifier = Modifier.width(6.dp))

                // ⌚ الساعة
                Image(
                    painter = painterResource(id = R.drawable.watch),
                    contentDescription = null,
                    modifier = Modifier.size(30.dp)
                )
            }

            Spacer(modifier = Modifier.height(14.dp))

            //////////////////////////////////////
            // النص
            //////////////////////////////////////
            Text(
                text = "تم الربط بنجاح",
                fontSize = 14.sp
            )

            Spacer(modifier = Modifier.height(6.dp))

            Text(
                text = "ساعة ميمورا جاهزة",
                fontSize = 10.sp,
                color = Color.Gray
            )

            Spacer(modifier = Modifier.height(18.dp))

            //////////////////////////////////////
            // الزر
            //////////////////////////////////////
            Button(
                onClick = onNext,
                colors = ButtonDefaults.buttonColors(containerColor = mainColor),
                shape = RoundedCornerShape(20.dp),
                modifier = Modifier.width(120.dp)
            ) {
                Text("ابدأ الآن")
            }
        }
    }
}