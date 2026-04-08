package com.example.memora.presentation

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.*
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.*
import androidx.core.content.ContextCompat
import com.google.firebase.firestore.FirebaseFirestore
import com.google.android.gms.location.LocationServices
import kotlinx.coroutines.delay
import java.util.*

@Composable
fun HomeScreen() {

    var reminderText by remember { mutableStateOf("...") }
    var userId by remember { mutableStateOf("") }
    var zoneStatus by remember { mutableStateOf("جارٍ التحقق...") }

    var zoneLat by remember { mutableStateOf<Double?>(null) }
    var zoneLng by remember { mutableStateOf<Double?>(null) }
    var zoneRadius by remember { mutableStateOf<Double?>(null) }

    val context = LocalContext.current
    val db = FirebaseFirestore.getInstance()
    val fusedLocationClient = LocationServices.getFusedLocationProviderClient(context)

    //////////////////////////////////////////////////////
    // 🔥 تحميل UID
    //////////////////////////////////////////////////////
    val prefs = context.getSharedPreferences("memora", Context.MODE_PRIVATE)

    LaunchedEffect(Unit) {
        val saved = prefs.getString("uid", null)
        if (saved != null) {
            userId = saved
        }
    }

    //////////////////////////////////////////////////////
    // 🔔 التذكير (نفس كودك)
    //////////////////////////////////////////////////////
    var nextTime by remember { mutableStateOf<Date?>(null) }
    var nextName by remember { mutableStateOf("") }

    LaunchedEffect(userId) {
        if (userId.isNotEmpty()) {
            db.collection("users")
                .document(userId)
                .collection("reminders")
                .addSnapshotListener { snapshot, _ ->

                    if (snapshot != null && !snapshot.isEmpty) {

                        val now = Date()
                        var closestTime: Date? = null
                        var closestName = ""

                        for (doc in snapshot.documents) {

                            val time = doc.getTimestamp("time")?.toDate()
                            val name = doc.getString("medicineName") ?: ""

                            if (time != null && time.after(now)) {

                                if (closestTime == null || time.before(closestTime)) {
                                    closestTime = time
                                    closestName = name
                                }
                            }
                        }

                        nextTime = closestTime
                        nextName = closestName
                    }
                }
        }
    }

    //////////////////////////////////////////////////////
    // 🔄 تحديث نص التذكير
    //////////////////////////////////////////////////////
    LaunchedEffect(nextTime) {
        while (true) {

            val now = Date()

            if (nextTime != null) {

                val diff = nextTime!!.time - now.time
                val hours = (diff / (1000 * 60 * 60)).toInt()
                val minutes = ((diff / (1000 * 60)) % 60).toInt()

                reminderText = when {
                    diff <= 0 -> "🔔 الآن"
                    hours > 0 -> "$nextName بعد $hours ساعة"
                    else -> "$nextName بعد $minutes دقيقة"
                }
            }

            delay(60000)
        }
    }

    //////////////////////////////////////////////////////
    // 🔥 قراءة السيف زون من Firebase
    //////////////////////////////////////////////////////
    LaunchedEffect(userId) {
        if (userId.isNotEmpty()) {

            db.collection("users")
                .document(userId)
                .collection("config")
                .document("safe_zone")
                .addSnapshotListener { snapshot, _ ->

                    if (snapshot != null && snapshot.exists()) {

                        zoneLat = snapshot.getDouble("lat")
                        zoneLng = snapshot.getDouble("lng")
                        zoneRadius = snapshot.getDouble("radius")
                    }
                }
        }
    }

    //////////////////////////////////////////////////////
    // 📍 تحديث الموقع كل 5 ثواني
    //////////////////////////////////////////////////////
    LaunchedEffect(zoneLat, zoneLng, zoneRadius) {

        if (zoneLat != null && zoneLng != null && zoneRadius != null) {

            while (true) {

                try {

                    // 🔐 تحقق من الإذن
                    val permission = ContextCompat.checkSelfPermission(
                        context,
                        Manifest.permission.ACCESS_FINE_LOCATION
                    )

                    if (permission == PackageManager.PERMISSION_GRANTED) {

                        fusedLocationClient.lastLocation
                            .addOnSuccessListener { location ->

                                if (location != null) {

                                    val results = FloatArray(1)

                                    Location.distanceBetween(
                                        location.latitude,
                                        location.longitude,
                                        zoneLat!!,
                                        zoneLng!!,
                                        results
                                    )

                                    val distance = results[0]

                                    zoneStatus = if (distance <= zoneRadius!!) {
                                        "📍 أنت داخل المنطقة الآمنة"
                                    } else {
                                        "⚠️ أنت خارج المنطقة الآن"
                                    }

                                } else {
                                    zoneStatus = "تعذر تحديد الموقع"
                                }
                            }

                    } else {
                        zoneStatus = "⚠️ لم يتم إعطاء إذن الموقع"
                    }

                } catch (e: Exception) {
                    zoneStatus = "خطأ في الموقع"
                }

                delay(5000)
            }
        }
    }

    //////////////////////////////////////////////////////
    // 🎨 UI (نفس تصميمك)
    //////////////////////////////////////////////////////
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFFF5F5F5))
            .padding(10.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {

        Spacer(modifier = Modifier.height(10.dp))

        Text(
            text = "مرحباً، ميمورا هنا لرعايتك",
            fontSize = 12.sp,
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.height(10.dp))

        Card(
            shape = RoundedCornerShape(12.dp),
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(modifier = Modifier.padding(10.dp)) {
                Text("🔔 التذكير القادم", fontSize = 10.sp)
                Text(reminderText, fontSize = 12.sp)
            }
        }

        Spacer(modifier = Modifier.height(10.dp))

        Card(
            shape = RoundedCornerShape(12.dp),
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(modifier = Modifier.padding(10.dp)) {

                Text(
                    text = zoneStatus,
                    fontSize = 10.sp,
                    color = if (zoneStatus.contains("داخل")) Color(0xFF4CAF50) else Color.Red
                )
            }
        }
    }
}