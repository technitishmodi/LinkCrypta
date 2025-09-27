package com.linkcrypta.app

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.view.autofill.AutofillManager
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONArray
import org.json.JSONObject

class AutofillMethodChannel(
    private val context: Context,
    private val activity: Activity?
) : MethodCallHandler {

    companion object {
        private const val CHANNEL_NAME = "com.linkcrypta.app/autofill"
    }

    private var methodChannel: MethodChannel? = null

    fun setupChannel(flutterEngine: FlutterEngine) {
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
        methodChannel?.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "isAutofillServiceEnabled" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    result.success(isAutofillServiceEnabled())
                } else {
                    result.success(false)
                }
            }
            "openAutofillSettings" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    openAutofillSettings()
                    result.success(null)
                } else {
                    result.error("UNSUPPORTED", "Autofill not supported on this Android version", null)
                }
            }
            "triggerAutofill" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    val packageName = call.argument<String>("packageName")
                    triggerAutofill(packageName)
                    result.success(null)
                } else {
                    result.error("UNSUPPORTED", "Autofill not supported on this Android version", null)
                }
            }
            "getAutofillStats" -> {
                result.success(getAutofillStats())
            }
            "setAppAutofillEnabled" -> {
                val packageName = call.argument<String>("packageName") ?: ""
                val enabled = call.argument<Boolean>("enabled") ?: false
                setAppAutofillEnabled(packageName, enabled)
                result.success(null)
            }
            "getAutofillApps" -> {
                result.success(getAutofillApps())
            }
            "syncPasswordsToStorage" -> {
                syncPasswordsToStorage(call, result)
            }
            "getNewCredentialsFromAutofill" -> {
                getNewCredentialsFromAutofill(result)
            }
            "clearNewCredentials" -> {
                clearNewCredentials(result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun isAutofillServiceEnabled(): Boolean {
        val autofillManager = context.getSystemService(AutofillManager::class.java)
        return autofillManager?.hasEnabledAutofillServices() == true &&
                autofillManager.isAutofillSupported
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun openAutofillSettings() {
        val intent = Intent(Settings.ACTION_REQUEST_SET_AUTOFILL_SERVICE).apply {
            data = android.net.Uri.parse("package:${context.packageName}")
        }
        
        try {
            activity?.startActivity(intent)
        } catch (e: Exception) {
            // Fallback to general autofill settings
            val fallbackIntent = Intent(Settings.ACTION_SETTINGS)
            activity?.startActivity(fallbackIntent)
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun triggerAutofill(packageName: String?) {
        // This is mainly for testing purposes
        // In practice, autofill is triggered automatically by the system
        val autofillManager = context.getSystemService(AutofillManager::class.java)
        // Note: There's no direct way to trigger autofill programmatically
        // This method exists for future enhancements or testing
    }

    private fun getAutofillStats(): Map<String, Any> {
        // Return basic statistics about autofill usage
        // This would be enhanced with actual usage tracking
        return mapOf(
            "isSupported" to (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O),
            "isEnabled" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                isAutofillServiceEnabled()
            } else false,
            "androidVersion" to Build.VERSION.SDK_INT,
            "packageName" to context.packageName
        )
    }

    private fun setAppAutofillEnabled(packageName: String, enabled: Boolean) {
        // Store app-specific autofill preferences
        val prefs = context.getSharedPreferences("autofill_prefs", Context.MODE_PRIVATE)
        prefs.edit().putBoolean("autofill_$packageName", enabled).apply()
    }

    private fun getAutofillApps(): List<Map<String, Any>> {
        // Return list of apps with autofill data
        // This would be enhanced with actual app detection and usage data
        val prefs = context.getSharedPreferences("autofill_prefs", Context.MODE_PRIVATE)
        val apps = mutableListOf<Map<String, Any>>()
        
        // Get all stored app preferences
        for ((key, value) in prefs.all) {
            if (key.startsWith("autofill_")) {
                val packageName = key.removePrefix("autofill_")
                apps.add(mapOf(
                    "packageName" to packageName,
                    "enabled" to (value as? Boolean ?: false),
                    "name" to getAppName(packageName)
                ))
            }
        }
        
        return apps
    }

    // Method to handle incoming autofill actions
    private fun syncPasswordsToStorage(call: MethodCall, result: MethodChannel.Result) {
        try {
            val passwordsJson = call.arguments as String
            val sharedPrefs = context.getSharedPreferences("FlutterSecureStorage", Context.MODE_PRIVATE)
            
            // Preserve any existing new_credentials when updating passwords
            val existingNewCredentials = sharedPrefs.getString("new_credentials", "[]")
            
            sharedPrefs.edit()
                .putString("passwords", passwordsJson)
                .putString("new_credentials", existingNewCredentials) // Preserve new credentials
                .apply()
                
            android.util.Log.d("AutofillMethodChannel", "Synced passwords and preserved new_credentials: $existingNewCredentials")
            result.success(true)
        } catch (e: Exception) {
            result.error("SYNC_ERROR", "Failed to sync passwords: ${e.message}", null)
        }
    }

    // Method to get new credentials saved by autofill service
    private fun getNewCredentialsFromAutofill(result: MethodChannel.Result) {
        try {
            val sharedPrefs = context.getSharedPreferences("FlutterSecureStorage", Context.MODE_PRIVATE)
            val newCredentialsJson = sharedPrefs.getString("new_credentials", "[]")
            
            android.util.Log.d("AutofillMethodChannel", "Raw new_credentials JSON: $newCredentialsJson")
            
            // Also check what's in the main passwords key for debugging
            val passwordsJson = sharedPrefs.getString("passwords", "[]")
            android.util.Log.d("AutofillMethodChannel", "Raw passwords JSON length: ${passwordsJson?.length ?: 0}")
            
            val newCredentials = JSONArray(newCredentialsJson)
            val credentialsList = mutableListOf<Map<String, Any>>()
            
            for (i in 0 until newCredentials.length()) {
                val credential = newCredentials.getJSONObject(i)
                val credMap = mutableMapOf<String, Any>()
                credMap["name"] = credential.optString("name", "")
                credMap["username"] = credential.optString("username", "")
                credMap["password"] = credential.optString("password", "")
                credMap["url"] = credential.optString("url", "")
                credMap["category"] = credential.optString("category", "General")
                credMap["notes"] = credential.optString("notes", "")
                credMap["createdAt"] = credential.optString("createdAt", "")
                credMap["updatedAt"] = credential.optString("updatedAt", "")
                credMap["isFavorite"] = credential.optBoolean("isFavorite", false)
                credentialsList.add(credMap)
            }
            
            android.util.Log.d("AutofillMethodChannel", "Found ${credentialsList.size} new credentials to import")
            result.success(credentialsList)
        } catch (e: Exception) {
            android.util.Log.e("AutofillMethodChannel", "Failed to get new credentials", e)
            result.error("GET_NEW_CREDENTIALS_ERROR", "Failed to get new credentials: ${e.message}", null)
        }
    }

    // Method to clear new credentials after importing
    private fun clearNewCredentials(result: MethodChannel.Result) {
        try {
            val sharedPrefs = context.getSharedPreferences("FlutterSecureStorage", Context.MODE_PRIVATE)
            sharedPrefs.edit().putString("new_credentials", "[]").apply()
            android.util.Log.d("AutofillMethodChannel", "Cleared new credentials after import")
            result.success(true)
        } catch (e: Exception) {
            result.error("CLEAR_CREDENTIALS_ERROR", "Failed to clear new credentials: ${e.message}", null)
        }
    }

    private fun getAppName(packageName: String): String {
        return try {
            val packageManager = context.packageManager
            val applicationInfo = packageManager.getApplicationInfo(packageName, 0)
            packageManager.getApplicationLabel(applicationInfo).toString()
        } catch (e: Exception) {
            packageName
        }
    }
}
