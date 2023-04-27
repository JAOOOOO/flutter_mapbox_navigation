package com.eopeter.flutter_mapbox_navigation.activity

import android.app.Activity
import android.content.Intent
import com.mapbox.geojson.Point
import java.io.Serializable

object NavigationLauncher {
    const val KEY_ADD_WAYPOINTS = "com.my.mapbox.broadcast.ADD_WAYPOINTS"
    const val KEY_STOP_NAVIGATION = "com.my.mapbox.broadcast.STOP_NAVIGATION"
    fun startNavigation(activity: Activity, wayPoints: List<Point?>?) {
        val navigationIntent = Intent(activity, NavigationActivity::class.java)
        navigationIntent.putExtra("waypoints", wayPoints as Serializable?)
        activity.startActivity(navigationIntent)
    }

    fun addWayPoints(activity: Activity, wayPoints: List<Point?>?) {
        val navigationIntent = Intent(activity, NavigationActivity::class.java)
        navigationIntent.action = KEY_ADD_WAYPOINTS
        navigationIntent.putExtra("isAddingWayPoints", true)
        navigationIntent.putExtra("waypoints", wayPoints as Serializable?)
        activity.sendBroadcast(navigationIntent)
    }

    fun stopNavigation(activity: Activity) {
        val stopIntent = Intent()
        stopIntent.action = KEY_STOP_NAVIGATION
        activity.sendBroadcast(stopIntent)
    }
}