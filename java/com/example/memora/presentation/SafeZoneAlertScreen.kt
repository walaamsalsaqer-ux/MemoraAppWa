package com.example.memora.presentation

import android.annotation.SuppressLint
import android.content.Context
import android.location.Location
import com.google.android.gms.location.*

class SafeZoneService(
    private val context: Context,
    private val onExit: () -> Unit
) {

    private val client = LocationServices.getFusedLocationProviderClient(context)

    // 📍 موقع المنطقة الآمنة (غيريه لو تبين)
    private val safeLat = 26.500000
    private val safeLng = 50.200000

    // 📏 نصف القطر (صغير عشان يظهر التنبيه بسرعة)
    private val radius = 50f // متر

    @SuppressLint("MissingPermission")
    fun startTracking() {

        val request = LocationRequest.Builder(
            Priority.PRIORITY_HIGH_ACCURACY, 2000
        ).build()

        client.requestLocationUpdates(
            request,
            object : LocationCallback() {
                override fun onLocationResult(result: LocationResult) {
                    val location = result.lastLocation ?: return

                    val distance = FloatArray(1)

                    Location.distanceBetween(
                        safeLat,
                        safeLng,
                        location.latitude,
                        location.longitude,
                        distance
                    )

                    println("📍 Distance = ${distance[0]}")

                    //////////////////////////////////////
                    // 🚨 إذا طلع برا
                    //////////////////////////////////////
                    if (distance[0] > radius) {
                        onExit()
                    }
                }
            },
            null
        )
    }
}