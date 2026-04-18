package com.example.memora.presentation

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.google.firebase.firestore.FirebaseFirestore
import kotlin.math.*

@Composable
fun HomeScreen() {

    val primaryColor = Color(0xFF7B1FA2)
    val cardColor = Color(0xFFF3E5F5)

    var medicineName by remember { mutableStateOf("لا يوجد دواء") }
    var medicineTime by remember { mutableStateOf("") }

    var zoneStatus by remember { mutableStateOf("جاري تحديد الموقع...") }

    val db = FirebaseFirestore.getInstance()
    val userId = "kWk50N1nyCYy1smS4BVthhOyN542"

    // ================= 🔔 الدواء (بدون حسابات) =================
    LaunchedEffect(Unit) {

        db.collection("users")
            .document(userId)
            .collection("config")
            .document("last_reminder")
            .addSnapshotListener { doc, _ ->

                if (doc != null && doc.exists()) {

                    val name = doc.getString("name")

                    if (name.isNullOrEmpty()) {
                        medicineName = "لا يوجد دواء"
                        medicineTime = ""
                        return@addSnapshotListener
                    }

                    val time = doc.getTimestamp("time")?.toDate()

                    if (time != null) {

                        medicineName = name

                        val calendar = java.util.Calendar.getInstance()
                        calendar.time = time

                        val hour = calendar.get(java.util.Calendar.HOUR)
                        val minute = calendar.get(java.util.Calendar.MINUTE)
                        val amPm =
                            if (calendar.get(java.util.Calendar.AM_PM) == 0) "ص"
                            else "م"

                        medicineTime =
                            String.format("%02d:%02d %s", hour, minute, amPm)
                    }
                }
            }
    }

    // ================= 📍 السيف زون =================
    LaunchedEffect(Unit) {

        db.collection("users")
            .document(userId)
            .collection("config")
            .document("safe_zone")
            .addSnapshotListener { doc, _ ->

                if (doc != null && doc.exists()) {

                    val lat = doc.getDouble("lat") ?: return@addSnapshotListener
                    val lng = doc.getDouble("lng") ?: return@addSnapshotListener
                    val radius = doc.getDouble("radius") ?: 200.0

                    val userLat = 26.4159
                    val userLng = 50.0836

                    val distance = calculateDistance(lat, lng, userLat, userLng)

                    zoneStatus =
                        if (distance <= radius) "داخل المنطقة الآمنة"
                        else "خارج المنطقة الآمنة"
                }
            }
    }

    // ================= UI =================
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(10.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {

        // ❤️ العنوان
        Text(
            "مرحباً، ميمورا هنا لرعايتك 💜",
            color = primaryColor,
            fontSize = 10.sp,
            fontWeight = FontWeight.Bold
        )

        // 👇 نزّلنا المحتوى تحت
        Spacer(Modifier.height(12.dp))

        // 💊 كرت الدواء
        Card(
            shape = RoundedCornerShape(14.dp),
            colors = CardDefaults.cardColors(containerColor = cardColor),
            modifier = Modifier
                .fillMaxWidth()
                .height(55.dp)
        ) {

            Column(Modifier.padding(8.dp)) {

                Text("💊 الدواء القادم", fontSize = 7.sp, color = Color.Gray)

                Spacer(Modifier.height(2.dp))

                if (medicineName == "لا يوجد دواء") {

                    Text(
                        "لا يوجد دواء",
                        fontSize = 8.sp,
                        color = primaryColor
                    )

                } else {

                    Text(
                        medicineName,
                        fontSize = 9.sp,
                        fontWeight = FontWeight.Medium
                    )

                    Text(
                        "⏰ $medicineTime",
                        fontSize = 8.sp,
                        color = Color.DarkGray
                    )
                }
            }
        }

        Spacer(Modifier.height(6.dp))

        // 📍 كرت السيف زون
        Card(
            shape = RoundedCornerShape(14.dp),
            colors = CardDefaults.cardColors(containerColor = cardColor),
            modifier = Modifier
                .fillMaxWidth()
                .height(55.dp)
        ) {

            Column(Modifier.padding(8.dp)) {

                Text("📍 المنطقة الآمنة", fontSize = 7.sp, color = Color.Gray)

                Spacer(Modifier.height(2.dp))

                Text(
                    zoneStatus,
                    fontSize = 8.sp,
                    fontWeight = FontWeight.Medium,
                    color = Color.Gray // 👈 صار رمادي
                )
            }
        }
    }
}

// ================= حساب المسافة =================
fun calculateDistance(
    lat1: Double, lon1: Double,
    lat2: Double, lon2: Double
): Double {

    val R = 6371e3
    val φ1 = Math.toRadians(lat1)
    val φ2 = Math.toRadians(lat2)
    val Δφ = Math.toRadians(lat2 - lat1)
    val Δλ = Math.toRadians(lon2 - lon1)

    val a = sin(Δφ / 2) * sin(Δφ / 2) +
            cos(φ1) * cos(φ2) *
            sin(Δλ / 2) * sin(Δλ / 2)

    val c = 2 * atan2(sqrt(a), sqrt(1 - a))

    return R * c
}