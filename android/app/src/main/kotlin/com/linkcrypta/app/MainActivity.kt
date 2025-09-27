package com.linkcrypta.app

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterFragmentActivity() {
    
    private lateinit var autofillMethodChannel: AutofillMethodChannel
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Setup autofill method channel
        autofillMethodChannel = AutofillMethodChannel(this, this)
        autofillMethodChannel.setupChannel(flutterEngine)
    }
}
