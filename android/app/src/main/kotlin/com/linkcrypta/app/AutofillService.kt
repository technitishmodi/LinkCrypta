package com.linkcrypta.app

import android.app.assist.AssistStructure
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.os.CancellationSignal
import android.service.autofill.*
import android.util.Log
import android.view.autofill.AutofillId
import android.view.autofill.AutofillValue
import android.widget.RemoteViews
import androidx.annotation.RequiresApi
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*

@RequiresApi(Build.VERSION_CODES.O)
class LinkCryptaAutofillService : AutofillService() {
    
    companion object {
        private const val TAG = "LinkCryptaAutofill"
        private const val PREFS_NAME = "FlutterSecureStorage"
        private const val PASSWORDS_KEY = "passwords"
    }

    private lateinit var sharedPrefs: SharedPreferences

    override fun onCreate() {
        super.onCreate()
        sharedPrefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE)
        Log.d(TAG, "AutofillService created")
    }

    override fun onFillRequest(
        request: FillRequest,
        cancellationSignal: CancellationSignal,
        callback: FillCallback
    ) {
        Log.d(TAG, "onFillRequest called")
        
        val structure = request.fillContexts.lastOrNull()?.structure
        if (structure == null) {
            callback.onFailure("No structure found")
            return
        }

        val autofillFields = parseAutofillFields(structure)
        if (autofillFields.isEmpty()) {
            Log.d(TAG, "No autofill fields found")
            callback.onFailure("No autofill fields found")
            return
        }

        // Get current app package name for context
        val packageName = structure.activityComponent.packageName
        val url = extractUrl(structure) ?: packageName
        
        Log.d(TAG, "Processing autofill for: $url")

        // Get matching credentials from local storage
        val credentials = getStoredCredentials(url)
        
        if (credentials.isNotEmpty()) {
            val response = createFillResponse(autofillFields, credentials)
            callback.onSuccess(response)
        } else {
            Log.d(TAG, "No matching credentials found")
            callback.onFailure("No matching credentials found")
        }
    }

    override fun onSaveRequest(request: SaveRequest, callback: SaveCallback) {
        Log.d(TAG, "onSaveRequest called")
        
        val structure = request.fillContexts.lastOrNull()?.structure
        if (structure == null) {
            callback.onFailure("No structure found")
            return
        }

        val autofillFields = parseAutofillFields(structure)
        val packageName = structure.activityComponent.packageName
        val url = extractUrl(structure) ?: packageName

        // Extract filled values from the request
        val credentials = mutableMapOf<String, String>()
        
        for (field in autofillFields) {
            val value = extractValueFromRequest(request, field.autofillId)
            
            if (!value.isNullOrEmpty()) {
                when (field.type) {
                    AutofillFieldType.USERNAME, AutofillFieldType.EMAIL -> {
                        credentials["username"] = value
                    }
                    AutofillFieldType.PASSWORD -> {
                        credentials["password"] = value
                    }
                    AutofillFieldType.UNKNOWN -> {
                        // Try to determine if it's username or password based on context
                        if (value.length > 6 && !value.contains("@")) {
                            // Likely a password if longer than 6 chars and no @
                            if (!credentials.containsKey("password")) {
                                credentials["password"] = value
                            }
                        } else {
                            // Likely a username
                            if (!credentials.containsKey("username")) {
                                credentials["username"] = value
                            }
                        }
                    }
                }
            }
        }

        Log.d(TAG, "Extracted credentials: username=${credentials["username"]?.isNotEmpty()}, password=${credentials["password"]?.isNotEmpty()}")

        if (credentials.containsKey("username") && credentials.containsKey("password")) {
            // Save credentials directly to local storage
            val saved = saveCredentialsToStorage(url, credentials["username"]!!, credentials["password"]!!)
            
            if (saved) {
                Log.d(TAG, "Credentials saved successfully")
                callback.onSuccess()
            } else {
                Log.e(TAG, "Failed to save credentials")
                callback.onFailure("Failed to save credentials")
            }
        } else {
            Log.w(TAG, "Incomplete credentials - username: ${credentials.containsKey("username")}, password: ${credentials.containsKey("password")}")
            callback.onFailure("Incomplete credentials")
        }
    }

    private fun parseAutofillFields(structure: AssistStructure): List<AutofillField> {
        val fields = mutableListOf<AutofillField>()
        
        for (i in 0 until structure.windowNodeCount) {
            val windowNode = structure.getWindowNodeAt(i)
            parseNode(windowNode.rootViewNode, fields)
        }
        
        Log.d(TAG, "Found ${fields.size} autofill fields")
        return fields
    }

    private fun parseNode(node: AssistStructure.ViewNode, fields: MutableList<AutofillField>) {
        val autofillHints = node.autofillHints
        val inputType = node.inputType
        val hint = node.hint
        val text = node.text?.toString()
        
        // Determine field type based on hints and input type
        val fieldType = determineFieldType(autofillHints, inputType, hint, text)
        
        if (fieldType != AutofillFieldType.UNKNOWN && node.autofillId != null) {
            fields.add(
                AutofillField(
                    autofillId = node.autofillId!!,
                    type = fieldType,
                    hint = hint,
                    text = text
                )
            )
        }

        // Recursively parse child nodes
        for (i in 0 until node.childCount) {
            parseNode(node.getChildAt(i), fields)
        }
    }

    private fun determineFieldType(
        autofillHints: Array<String>?,
        inputType: Int,
        hint: String?,
        text: String?
    ): AutofillFieldType {
        // Check autofill hints first (most reliable)
        autofillHints?.let { hints ->
            for (hintValue in hints) {
                when (hintValue) {
                    "username", "emailAddress" -> return AutofillFieldType.USERNAME
                    "password" -> return AutofillFieldType.PASSWORD
                }
            }
        }

        // Check input type
        when (inputType and 0xfff) {
            0x81 -> return AutofillFieldType.PASSWORD // TYPE_TEXT_VARIATION_PASSWORD
            0x20 -> return AutofillFieldType.EMAIL    // TYPE_TEXT_VARIATION_EMAIL_ADDRESS
        }

        // Fallback to text analysis
        val allText = "${hint ?: ""} ${text ?: ""}".lowercase()
        return when {
            allText.contains("password") || allText.contains("pwd") -> AutofillFieldType.PASSWORD
            allText.contains("email") || allText.contains("e-mail") -> AutofillFieldType.EMAIL
            allText.contains("username") || allText.contains("user") -> AutofillFieldType.USERNAME
            else -> AutofillFieldType.UNKNOWN
        }
    }

    private fun extractUrl(structure: AssistStructure): String? {
        // Try to extract URL from web view or browser
        for (i in 0 until structure.windowNodeCount) {
            val windowNode = structure.getWindowNodeAt(i)
            val url = extractUrlFromNode(windowNode.rootViewNode)
            if (url != null) return url
        }
        return null
    }

    private fun extractUrlFromNode(node: AssistStructure.ViewNode): String? {
        // Check if this is a web view with URL
        if (node.webDomain != null) {
            return "https://${node.webDomain}"
        }
        
        // Check text content for URLs
        node.text?.toString()?.let { text ->
            if (text.startsWith("http://") || text.startsWith("https://")) {
                return text
            }
        }

        // Recursively check child nodes
        for (i in 0 until node.childCount) {
            val url = extractUrlFromNode(node.getChildAt(i))
            if (url != null) return url
        }
        
        return null
    }

    private fun getStoredCredentials(url: String): List<CredentialMatch> {
        return try {
            val passwordsJson = sharedPrefs.getString(PASSWORDS_KEY, null) ?: return emptyList()
            val passwordsArray = JSONArray(passwordsJson)
            val credentials = mutableListOf<CredentialMatch>()
            
            for (i in 0 until passwordsArray.length()) {
                val passwordObj = passwordsArray.getJSONObject(i)
                val storedUrl = passwordObj.optString("url", "")
                
                // Simple URL matching - check if URLs are related
                if (isUrlMatch(url, storedUrl)) {
                    credentials.add(CredentialMatch(
                        id = passwordObj.optString("id", ""),
                        name = passwordObj.optString("name", ""),
                        username = passwordObj.optString("username", ""),
                        password = passwordObj.optString("password", ""), // This would be encrypted in real app
                        url = storedUrl
                    ))
                }
            }
            
            Log.d(TAG, "Found ${credentials.size} matching credentials for $url")
            credentials
        } catch (e: Exception) {
            Log.e(TAG, "Error reading stored credentials", e)
            emptyList()
        }
    }

    private fun saveCredentialsToStorage(url: String, username: String, password: String): Boolean {
        return try {
            val passwordsJson = sharedPrefs.getString(PASSWORDS_KEY, "[]")
            val passwordsArray = JSONArray(passwordsJson)
            
            // Also get new credentials for importing to main app
            val newCredentialsJson = sharedPrefs.getString("new_credentials", "[]")
            val newCredentialsArray = JSONArray(newCredentialsJson)
            
            // Check if credential already exists
            var existingIndex = -1
            for (i in 0 until passwordsArray.length()) {
                val passwordObj = passwordsArray.getJSONObject(i)
                if (passwordObj.optString("username") == username && 
                    isUrlMatch(url, passwordObj.optString("url", ""))) {
                    existingIndex = i
                    break
                }
            }
            
            val credentialObj = JSONObject().apply {
                put("id", if (existingIndex >= 0) passwordsArray.getJSONObject(existingIndex).optString("id") else UUID.randomUUID().toString())
                put("name", generateFriendlyName(url))
                put("username", username)
                put("password", password) // In real app, this should be encrypted
                put("url", url)
                put("notes", "Auto-saved via Android Autofill")
                put("category", "General")
                put("createdAt", SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US).format(Date()))
                put("updatedAt", SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US).format(Date()))
                put("isFavorite", false)
            }
            
            if (existingIndex >= 0) {
                // Update existing credential
                passwordsArray.put(existingIndex, credentialObj)
                Log.d(TAG, "Updated existing credential for $username")
            } else {
                // Add new credential
                passwordsArray.put(credentialObj)
                // Also add to new credentials for importing to main app
                newCredentialsArray.put(credentialObj)
                Log.d(TAG, "Added new credential for $username")
            }
            
            // Save back to SharedPreferences
            sharedPrefs.edit()
                .putString(PASSWORDS_KEY, passwordsArray.toString())
                .putString("new_credentials", newCredentialsArray.toString())
                .apply()
            
            Log.d(TAG, "Successfully saved credentials to storage")
            true
        } catch (e: Exception) {
            Log.e(TAG, "Error saving credentials to storage", e)
            false
        }
    }

    private fun isUrlMatch(url1: String, url2: String): Boolean {
        if (url1 == url2) return true
        
        try {
            // Handle app package names
            if (!url1.startsWith("http") && !url2.startsWith("http")) {
                return url1 == url2
            }
            
            // Handle URLs - extract domain
            val domain1 = extractDomain(url1)
            val domain2 = extractDomain(url2)
            
            return domain1.isNotEmpty() && domain2.isNotEmpty() && 
                   (domain1 == domain2 || domain1.contains(domain2) || domain2.contains(domain1))
        } catch (e: Exception) {
            return false
        }
    }

    private fun extractDomain(url: String): String {
        return try {
            if (!url.startsWith("http")) return url
            val uri = java.net.URI(url)
            uri.host ?: ""
        } catch (e: Exception) {
            ""
        }
    }

    private fun generateFriendlyName(url: String): String {
        return try {
            // Handle app package names
            if (url.contains('.') && !url.startsWith("http") && !url.contains('/')) {
                val parts = url.split('.')
                if (parts.size >= 2) {
                    return parts.last().replaceFirstChar { if (it.isLowerCase()) it.titlecase() else it.toString() }
                }
            }
            
            // Handle URLs
            val domain = extractDomain(url)
            if (domain.isNotEmpty()) {
                return domain.removePrefix("www.").split('.').first()
                    .replaceFirstChar { if (it.isLowerCase()) it.titlecase() else it.toString() }
            }
            
            "New Account"
        } catch (e: Exception) {
            "New Account"
        }
    }

    private fun createFillResponse(
        fields: List<AutofillField>,
        credentials: List<CredentialMatch>
    ): FillResponse {
        val responseBuilder = FillResponse.Builder()

        // Create datasets for each credential match
        for ((index, credential) in credentials.withIndex()) {
            val datasetBuilder = Dataset.Builder()
            
            // Create presentation for the dataset
            val presentation = RemoteViews(this.packageName, android.R.layout.simple_list_item_1)
            presentation.setTextViewText(android.R.id.text1, "${credential.name} (${credential.username})")
            
            // Fill appropriate fields
            for (field in fields) {
                val value = when (field.type) {
                    AutofillFieldType.USERNAME, AutofillFieldType.EMAIL -> credential.username
                    AutofillFieldType.PASSWORD -> credential.password
                    else -> continue
                }
                
                datasetBuilder.setValue(
                    field.autofillId,
                    AutofillValue.forText(value),
                    presentation
                )
            }
            
            responseBuilder.addDataset(datasetBuilder.build())
        }

        // Add save info if we have username and password fields
        val usernameField = fields.find { 
            it.type == AutofillFieldType.USERNAME || it.type == AutofillFieldType.EMAIL 
        }
        val passwordField = fields.find { it.type == AutofillFieldType.PASSWORD }
        
        if (usernameField != null && passwordField != null) {
            val saveInfoBuilder = SaveInfo.Builder(
                SaveInfo.SAVE_DATA_TYPE_USERNAME or SaveInfo.SAVE_DATA_TYPE_PASSWORD,
                arrayOf(usernameField.autofillId, passwordField.autofillId)
            )
            responseBuilder.setSaveInfo(saveInfoBuilder.build())
        }

        return responseBuilder.build()
    }

    private fun extractValueFromRequest(request: SaveRequest, autofillId: AutofillId): String? {
        try {
            for (fillContext in request.fillContexts) {
                val structure = fillContext.structure
                for (i in 0 until structure.windowNodeCount) {
                    val windowNode = structure.getWindowNodeAt(i)
                    val value = findValueInNode(windowNode.rootViewNode, autofillId)
                    if (value != null) return value
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error extracting value from request", e)
        }
        return null
    }

    private fun findValueInNode(node: AssistStructure.ViewNode, targetId: AutofillId): String? {
        // Check if this is the target node
        if (node.autofillId == targetId) {
            // Return the text value if available
            node.text?.toString()?.let { text ->
                if (text.isNotEmpty()) return text
            }
            
            // Fallback to autofill value if text is empty
            node.autofillValue?.let { value ->
                if (value.isText) {
                    return value.textValue.toString()
                }
            }
        }
        
        // Recursively search child nodes
        for (i in 0 until node.childCount) {
            val value = findValueInNode(node.getChildAt(i), targetId)
            if (value != null) return value
        }
        
        return null
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "AutofillService destroyed")
    }
}

data class AutofillField(
    val autofillId: AutofillId,
    val type: AutofillFieldType,
    val hint: String?,
    val text: String?
)

enum class AutofillFieldType {
    USERNAME, EMAIL, PASSWORD, UNKNOWN
}

data class CredentialMatch(
    val id: String,
    val name: String,
    val username: String,
    val password: String,
    val url: String
)
