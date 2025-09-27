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
    private lateinit var encryptionHelper: EncryptionHelper

    override fun onCreate() {
        super.onCreate()
        sharedPrefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE)
        encryptionHelper = EncryptionHelper(this)
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
            Log.d(TAG, "No structure found in fill request")
            callback.onFailure("No structure found")
            return
        }

        // Get current app package name for context
        val packageName = structure.activityComponent.packageName
        Log.d(TAG, "Fill request from package: $packageName")
        
        // Check if this is a supported browser or app
        if (!isSupportedApp(packageName)) {
            Log.d(TAG, "App $packageName not in supported list, but proceeding anyway")
        }

        val autofillFields = parseAutofillFields(structure)
        if (autofillFields.isEmpty()) {
            Log.d(TAG, "No autofill fields found")
            callback.onFailure("No autofill fields found")
            return
        }

        val url = extractUrl(structure) ?: packageName
        Log.d(TAG, "Processing autofill for: $url (from package: $packageName)")

        // Get matching credentials from local storage
        val credentials = getStoredCredentials(url)
        
        if (credentials.isNotEmpty()) {
            Log.d(TAG, "Found ${credentials.size} matching credentials")
            val response = createFillResponse(autofillFields, credentials)
            callback.onSuccess(response)
        } else {
            Log.d(TAG, "No matching credentials found for: $url")
            // Still provide a response with save info for new credentials
            val response = createEmptyFillResponse(autofillFields)
            if (response != null) {
                callback.onSuccess(response)
            } else {
                callback.onFailure("No matching credentials found")
            }
        }
    }

    private fun isSupportedApp(packageName: String): Boolean {
        val supportedApps = listOf(
            "com.android.chrome",
            "com.chrome.beta",
            "com.chrome.dev",
            "com.chrome.canary",
            "org.mozilla.firefox",
            "org.mozilla.firefox_beta",
            "com.opera.browser",
            "com.opera.browser.beta",
            "com.microsoft.emmx",
            "com.brave.browser",
            "com.duckduckgo.mobile.android"
        )
        return supportedApps.contains(packageName)
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
        val className = node.className
        
        // Log detailed information for debugging
        if (node.autofillId != null && (inputType != 0 || !hint.isNullOrEmpty() || className?.contains("EditText") == true)) {
            Log.d(TAG, "Found potential field - Class: $className, InputType: $inputType, Hint: $hint, AutofillHints: ${autofillHints?.joinToString()}")
        }
        
        // Determine field type based on hints and input type
        val fieldType = determineFieldType(autofillHints, inputType, hint, text)
        
        // Be more aggressive in including fields - include UNKNOWN types if they look like input fields
        val shouldInclude = when {
            fieldType != AutofillFieldType.UNKNOWN -> true
            node.autofillId != null && (
                inputType != 0 || 
                className?.contains("EditText") == true ||
                className?.contains("TextInputEditText") == true ||
                !hint.isNullOrEmpty()
            ) -> true
            else -> false
        }
        
        if (shouldInclude && node.autofillId != null) {
            val finalFieldType = if (fieldType == AutofillFieldType.UNKNOWN) {
                // Try to make a better guess for unknown fields
                if (className?.contains("password", ignoreCase = true) == true) {
                    AutofillFieldType.PASSWORD
                } else {
                    AutofillFieldType.USERNAME // Default assumption
                }
            } else {
                fieldType
            }
            
            fields.add(
                AutofillField(
                    autofillId = node.autofillId!!,
                    type = finalFieldType,
                    hint = hint,
                    text = text
                )
            )
            
            Log.d(TAG, "Added autofill field: type=$finalFieldType, hint=$hint")
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
                when (hintValue.lowercase()) {
                    "username", "emailaddress", "email", "login" -> return AutofillFieldType.USERNAME
                    "password", "current-password", "new-password" -> return AutofillFieldType.PASSWORD
                }
            }
        }

        // Check input type more comprehensively
        val inputTypeVariation = inputType and 0xfff
        when (inputTypeVariation) {
            0x81, 0x91, 0xe1 -> return AutofillFieldType.PASSWORD // Various password input types
            0x20 -> return AutofillFieldType.EMAIL    // TYPE_TEXT_VARIATION_EMAIL_ADDRESS
        }

        // Check if it's a password field by input type class
        if ((inputType and 0x00000080) != 0) { // InputType.TYPE_TEXT_VARIATION_PASSWORD
            return AutofillFieldType.PASSWORD
        }

        // Enhanced text analysis for Chrome and other browsers
        val allText = "${hint ?: ""} ${text ?: ""}".lowercase()
        return when {
            allText.contains("password") || allText.contains("pwd") || allText.contains("pass") -> AutofillFieldType.PASSWORD
            allText.contains("email") || allText.contains("e-mail") || allText.contains("mail") -> AutofillFieldType.EMAIL
            allText.contains("username") || allText.contains("user") || allText.contains("login") -> AutofillFieldType.USERNAME
            // Additional patterns for Chrome
            allText.contains("identifier") || allText.contains("account") -> AutofillFieldType.USERNAME
            else -> {
                // If we still don't know, check if it looks like a password field
                // by checking if it's likely to be obscured
                if ((inputType and 0x00000080) != 0 || (inputType and 0x00000010) != 0) {
                    AutofillFieldType.PASSWORD
                } else {
                    AutofillFieldType.USERNAME // Default to username for unknown text fields
                }
            }
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
            
            Log.d(TAG, "Checking ${passwordsArray.length()} stored credentials for URL: $url")
            Log.d(TAG, "Encryption keys available: ${encryptionHelper.areKeysAvailable()}")
            
            for (i in 0 until passwordsArray.length()) {
                val passwordObj = passwordsArray.getJSONObject(i)
                val storedUrl = passwordObj.optString("url", "")
                
                // Simple URL matching - check if URLs are related
                if (isUrlMatch(url, storedUrl)) {
                    val encryptedPassword = passwordObj.optString("password", "")
                    val decryptedPassword = encryptionHelper.getDecryptedPassword(encryptedPassword)
                    
                    Log.d(TAG, "Found matching credential for $storedUrl - password decrypted: ${decryptedPassword != encryptedPassword}")
                    
                    credentials.add(CredentialMatch(
                        id = passwordObj.optString("id", ""),
                        name = passwordObj.optString("name", ""),
                        username = passwordObj.optString("username", ""),
                        password = decryptedPassword, // Now properly decrypted
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
            
            // For new passwords saved via autofill, we'll store them encrypted if encryption is available
            val passwordToStore = if (encryptionHelper.areKeysAvailable()) {
                // Note: We can't encrypt here without implementing the full encryption logic
                // For now, store as plain text and let the Flutter app handle encryption
                password
            } else {
                password
            }
            
            val credentialObj = JSONObject().apply {
                put("id", if (existingIndex >= 0) passwordsArray.getJSONObject(existingIndex).optString("id") else UUID.randomUUID().toString())
                put("name", generateFriendlyName(url))
                put("username", username)
                put("password", passwordToStore) // Store password (will be encrypted by Flutter app later)
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

    private fun createEmptyFillResponse(fields: List<AutofillField>): FillResponse? {
        // Create a response with just save info, no datasets
        val usernameField = fields.find { 
            it.type == AutofillFieldType.USERNAME || it.type == AutofillFieldType.EMAIL 
        }
        val passwordField = fields.find { it.type == AutofillFieldType.PASSWORD }
        
        if (usernameField != null && passwordField != null) {
            val responseBuilder = FillResponse.Builder()
            val saveInfoBuilder = SaveInfo.Builder(
                SaveInfo.SAVE_DATA_TYPE_USERNAME or SaveInfo.SAVE_DATA_TYPE_PASSWORD,
                arrayOf(usernameField.autofillId, passwordField.autofillId)
            )
            responseBuilder.setSaveInfo(saveInfoBuilder.build())
            return responseBuilder.build()
        }
        
        return null
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
