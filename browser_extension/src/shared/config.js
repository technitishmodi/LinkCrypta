// LinkCrypta Extension Configuration
const CONFIG = {
  // Firebase configuration (matches your Flutter app)
  FIREBASE_CONFIG: {
    apiKey: "your-api-key-here", // Replace with your Firebase config
    authDomain: "your-project.firebaseapp.com",
    projectId: "your-project-id",
    storageBucket: "your-project.appspot.com",
    messagingSenderId: "123456789",
    appId: "your-app-id"
  },
  
  // Extension settings
  EXTENSION: {
    NAME: "LinkCrypta",
    VERSION: "1.0.0",
    POPUP_WIDTH: 400,
    POPUP_HEIGHT: 600,
    AUTO_LOCK_TIMEOUT: 300000, // 5 minutes
    SYNC_INTERVAL: 30000 // 30 seconds
  },
  
  // Security settings
  SECURITY: {
    ENCRYPTION_ALGORITHM: "AES-GCM",
    KEY_LENGTH: 256,
    IV_LENGTH: 12,
    SALT_LENGTH: 16,
    ITERATIONS: 100000
  },
  
  // Auto-fill settings
  AUTOFILL: {
    CONFIDENCE_THRESHOLD: 0.7,
    MAX_SUGGESTIONS: 5,
    FORM_DETECTION_DELAY: 500,
    FILL_ANIMATION_DURATION: 300
  },
  
  // Storage keys
  STORAGE_KEYS: {
    USER_TOKEN: "linkcrypta_user_token",
    ENCRYPTED_DATA: "linkcrypta_encrypted_data",
    USER_SETTINGS: "linkcrypta_user_settings",
    SYNC_TIMESTAMP: "linkcrypta_sync_timestamp",
    MASTER_KEY_HASH: "linkcrypta_master_key_hash"
  },
  
  // Form field selectors for auto-detection
  FORM_SELECTORS: {
    USERNAME_FIELDS: [
      'input[type="email"]',
      'input[type="text"][name*="user"]',
      'input[type="text"][name*="email"]',
      'input[type="text"][id*="user"]',
      'input[type="text"][id*="email"]',
      'input[type="text"][placeholder*="email"]',
      'input[type="text"][placeholder*="username"]'
    ],
    PASSWORD_FIELDS: [
      'input[type="password"]',
      'input[name*="password"]',
      'input[id*="password"]',
      'input[placeholder*="password"]'
    ],
    LOGIN_FORMS: [
      'form[id*="login"]',
      'form[class*="login"]',
      'form[id*="signin"]',
      'form[class*="signin"]',
      'form[id*="auth"]',
      'form[class*="auth"]'
    ]
  }
};

// Make config available globally
if (typeof window !== 'undefined') {
  window.LINKCRYPTA_CONFIG = CONFIG;
} else if (typeof global !== 'undefined') {
  global.LINKCRYPTA_CONFIG = CONFIG;
}
