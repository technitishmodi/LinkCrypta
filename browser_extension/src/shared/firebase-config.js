// Firebase configuration and authentication for LinkCrypta Extension
class FirebaseManager {
  constructor() {
    this.app = null;
    this.auth = null;
    this.firestore = null;
    this.currentUser = null;
    this.initialized = false;
  }

  // Initialize Firebase
  async initialize() {
    if (this.initialized) return;

    try {
      // Import Firebase modules
      const { initializeApp } = await import('https://www.gstatic.com/firebasejs/10.0.0/firebase-app.js');
      const { getAuth, signInWithPopup, GoogleAuthProvider, onAuthStateChanged } = await import('https://www.gstatic.com/firebasejs/10.0.0/firebase-auth.js');
      const { getFirestore, doc, getDoc, setDoc, onSnapshot } = await import('https://www.gstatic.com/firebasejs/10.0.0/firebase-firestore.js');

      // Initialize Firebase app
      this.app = initializeApp(LINKCRYPTA_CONFIG.FIREBASE_CONFIG);
      this.auth = getAuth(this.app);
      this.firestore = getFirestore(this.app);

      // Store Firebase functions for later use
      this.signInWithPopup = signInWithPopup;
      this.GoogleAuthProvider = GoogleAuthProvider;
      this.onAuthStateChanged = onAuthStateChanged;
      this.doc = doc;
      this.getDoc = getDoc;
      this.setDoc = setDoc;
      this.onSnapshot = onSnapshot;

      // Listen for auth state changes
      this.onAuthStateChanged(this.auth, (user) => {
        this.currentUser = user;
        this.handleAuthStateChange(user);
      });

      this.initialized = true;
      console.log('Firebase initialized successfully');
    } catch (error) {
      console.error('Firebase initialization failed:', error);
      throw error;
    }
  }

  // Handle authentication state changes
  async handleAuthStateChange(user) {
    if (user) {
      // User is signed in
      console.log('User signed in:', user.email);
      
      // Store user token securely
      const token = await user.getIdToken();
      await this.storeUserToken(token);
      
      // Start data sync
      this.startDataSync(user);
      
      // Notify extension components
      this.notifyAuthChange(true, user);
    } else {
      // User is signed out
      console.log('User signed out');
      
      // Clear stored data
      await this.clearUserData();
      
      // Notify extension components
      this.notifyAuthChange(false, null);
    }
  }

  // Sign in with Google
  async signInWithGoogle() {
    try {
      const provider = new this.GoogleAuthProvider();
      provider.addScope('email');
      provider.addScope('profile');

      const result = await this.signInWithPopup(this.auth, provider);
      return {
        success: true,
        user: result.user,
        message: 'Successfully signed in'
      };
    } catch (error) {
      console.error('Google sign-in failed:', error);
      return {
        success: false,
        message: error.message || 'Sign-in failed'
      };
    }
  }

  // Sign out
  async signOut() {
    try {
      await this.auth.signOut();
      return {
        success: true,
        message: 'Successfully signed out'
      };
    } catch (error) {
      console.error('Sign-out failed:', error);
      return {
        success: false,
        message: error.message || 'Sign-out failed'
      };
    }
  }

  // Get current user
  getCurrentUser() {
    return this.currentUser;
  }

  // Check if user is authenticated
  isAuthenticated() {
    return this.currentUser !== null;
  }

  // Store user token securely
  async storeUserToken(token) {
    await chrome.storage.local.set({
      [LINKCRYPTA_CONFIG.STORAGE_KEYS.USER_TOKEN]: token
    });
  }

  // Get stored user token
  async getStoredUserToken() {
    const result = await chrome.storage.local.get([LINKCRYPTA_CONFIG.STORAGE_KEYS.USER_TOKEN]);
    return result[LINKCRYPTA_CONFIG.STORAGE_KEYS.USER_TOKEN];
  }

  // Clear user data
  async clearUserData() {
    await chrome.storage.local.clear();
  }

  // Start real-time data synchronization
  startDataSync(user) {
    if (!user) return;

    const userDocRef = this.doc(this.firestore, 'users', user.email);
    
    // Listen for real-time updates
    this.unsubscribeDataSync = this.onSnapshot(userDocRef, 
      (doc) => {
        if (doc.exists()) {
          const data = doc.data();
          this.handleDataUpdate(data);
        }
      },
      (error) => {
        console.error('Data sync error:', error);
      }
    );
  }

  // Stop data synchronization
  stopDataSync() {
    if (this.unsubscribeDataSync) {
      this.unsubscribeDataSync();
      this.unsubscribeDataSync = null;
    }
  }

  // Handle data updates from Firestore
  async handleDataUpdate(data) {
    try {
      // Store updated data locally (encrypted)
      await this.storeEncryptedData(data);
      
      // Notify extension components of data update
      this.notifyDataUpdate(data);
    } catch (error) {
      console.error('Error handling data update:', error);
    }
  }

  // Store encrypted data locally
  async storeEncryptedData(data) {
    const crypto = new CryptoUtils();
    
    // Get or generate encryption key
    const masterKey = await this.getMasterKey();
    if (!masterKey) return;

    // Encrypt data
    const encrypted = await crypto.encrypt(data, masterKey);
    
    // Store encrypted data
    await chrome.storage.local.set({
      [LINKCRYPTA_CONFIG.STORAGE_KEYS.ENCRYPTED_DATA]: encrypted,
      [LINKCRYPTA_CONFIG.STORAGE_KEYS.SYNC_TIMESTAMP]: Date.now()
    });
  }

  // Get decrypted data from local storage
  async getDecryptedData() {
    try {
      const result = await chrome.storage.local.get([LINKCRYPTA_CONFIG.STORAGE_KEYS.ENCRYPTED_DATA]);
      const encryptedData = result[LINKCRYPTA_CONFIG.STORAGE_KEYS.ENCRYPTED_DATA];
      
      if (!encryptedData) return null;

      const crypto = new CryptoUtils();
      const masterKey = await this.getMasterKey();
      
      if (!masterKey) return null;

      return await crypto.decrypt(encryptedData, masterKey);
    } catch (error) {
      console.error('Error decrypting data:', error);
      return null;
    }
  }

  // Get or prompt for master key
  async getMasterKey() {
    // In a real implementation, this would either:
    // 1. Retrieve cached key (if user chose to stay logged in)
    // 2. Prompt user for master password
    // 3. Use biometric authentication if available
    
    // For now, we'll derive from user UID (simplified)
    if (!this.currentUser) return null;
    
    const crypto = new CryptoUtils();
    const salt = crypto.encoder.encode(this.currentUser.uid);
    
    // In production, use actual master password here
    const masterPassword = this.currentUser.uid; // Simplified for demo
    
    return await crypto.deriveKey(masterPassword, salt);
  }

  // Notify extension components of auth changes
  notifyAuthChange(isAuthenticated, user) {
    chrome.runtime.sendMessage({
      type: 'AUTH_STATE_CHANGED',
      isAuthenticated,
      user: user ? {
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoURL: user.photoURL
      } : null
    }).catch(() => {}); // Ignore errors if no listeners
  }

  // Notify extension components of data updates
  notifyDataUpdate(data) {
    chrome.runtime.sendMessage({
      type: 'DATA_UPDATED',
      data
    }).catch(() => {}); // Ignore errors if no listeners
  }

  // Sync local data to Firestore
  async syncDataToFirestore(data) {
    if (!this.currentUser) return false;

    try {
      const userDocRef = this.doc(this.firestore, 'users', this.currentUser.email);
      await this.setDoc(userDocRef, {
        ...data,
        lastUpdated: new Date(),
        updatedBy: 'browser_extension'
      }, { merge: true });
      
      return true;
    } catch (error) {
      console.error('Error syncing to Firestore:', error);
      return false;
    }
  }
}

// Make FirebaseManager available globally
if (typeof window !== 'undefined') {
  window.FirebaseManager = FirebaseManager;
} else if (typeof global !== 'undefined') {
  global.FirebaseManager = FirebaseManager;
}
