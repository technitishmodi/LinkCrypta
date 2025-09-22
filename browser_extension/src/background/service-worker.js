// Background Service Worker for LinkCrypta Extension

// Configuration constants
const LINKCRYPTA_CONFIG = {
  EXTENSION: {
    AUTO_LOCK_TIMEOUT: 15 * 60 * 1000, // 15 minutes
    SYNC_INTERVAL: 5 * 60 * 1000 // 5 minutes
  },
  STORAGE_KEYS: {
    SYNC_TIMESTAMP: 'lastSyncTime',
    USER_DATA: 'userData',
    AUTH_STATE: 'authState'
  },
  AUTOFILL: {
    CONFIDENCE_THRESHOLD: 0.7,
    MAX_SUGGESTIONS: 5
  }
};

class BackgroundService {
  constructor() {
    this.isInitialized = false;
    this.autoLockTimer = null;
    this.syncInterval = null;
    this.currentUser = null;
    this.isAuthenticated = false;
  }

  async initialize() {
    if (this.isInitialized) return;

    try {
      // Load auth state
      await this.loadAuthState();
      
      // Setup context menus
      this.setupContextMenus();
      
      // Setup message listeners
      this.setupMessageListeners();
      
      // Setup auto-lock timer
      this.setupAutoLock();
      
      // Setup periodic sync
      this.setupPeriodicSync();
      
      // Setup command listeners
      this.setupCommandListeners();
      
      this.isInitialized = true;
      console.log('Background service initialized');
    } catch (error) {
      console.error('Background service initialization failed:', error);
    }
  }

  // Setup context menus
  setupContextMenus() {
    chrome.contextMenus.removeAll(() => {
      // Add context menu for password fields
      chrome.contextMenus.create({
        id: 'linkcrypta-fill-password',
        title: 'Fill with LinkCrypta',
        contexts: ['editable'],
        documentUrlPatterns: ['http://*/*', 'https://*/*']
      });

      // Add context menu for saving current page credentials
      chrome.contextMenus.create({
        id: 'linkcrypta-save-credentials',
        title: 'Save credentials to LinkCrypta',
        contexts: ['page'],
        documentUrlPatterns: ['http://*/*', 'https://*/*']
      });

      // Add context menu for generating password
      chrome.contextMenus.create({
        id: 'linkcrypta-generate-password',
        title: 'Generate password',
        contexts: ['editable'],
        documentUrlPatterns: ['http://*/*', 'https://*/*']
      });
    });

    // Handle context menu clicks
    chrome.contextMenus.onClicked.addListener((info, tab) => {
      this.handleContextMenuClick(info, tab);
    });
  }

  // Handle context menu clicks
  async handleContextMenuClick(info, tab) {
    switch (info.menuItemId) {
      case 'linkcrypta-fill-password':
        await this.handleFillPassword(tab);
        break;
      case 'linkcrypta-save-credentials':
        await this.handleSaveCredentials(tab);
        break;
      case 'linkcrypta-generate-password':
        await this.handleGeneratePassword(tab);
        break;
    }
  }

  // Setup message listeners
  setupMessageListeners() {
    chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
      this.handleMessage(request, sender, sendResponse);
      return true; // Keep message channel open for async response
    });
  }

  // Handle messages from content scripts and popup
  async handleMessage(request, sender, sendResponse) {
    try {
      switch (request.action) {
        case 'authenticate':
          const authResult = await this.authenticateUser();
          sendResponse(authResult);
          break;

        case 'signOut':
          const signOutResult = await this.signOutUser();
          sendResponse(signOutResult);
          break;

        case 'getPasswords':
          const passwords = await this.getStoredPasswords();
          sendResponse({ success: true, passwords });
          break;

        case 'addPassword':
          const saveResult = await this.savePassword(request.password);
          sendResponse(saveResult);
          break;

        case 'syncData':
          const syncResult = await this.performSync();
          sendResponse(syncResult);
          break;

        case 'logActivity':
          await this.logUserActivity(request.activity);
          sendResponse({ success: true });
          break;

        default:
          sendResponse({ success: false, error: 'Unknown action: ' + request.action });
      }
    } catch (error) {
      console.error('Error handling message:', error);
      sendResponse({ success: false, error: error.message });
    }
  }

  // Setup keyboard command listeners
  setupCommandListeners() {
    chrome.commands.onCommand.addListener((command) => {
      this.handleCommand(command);
    });
  }

  // Handle keyboard commands
  async handleCommand(command) {
    const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
    
    switch (command) {
      case 'open-quick-search':
        chrome.action.openPopup();
        break;
      case 'auto-fill-password':
        await this.handleFillPassword(tab);
        break;
    }
  }

  // Setup auto-lock functionality
  setupAutoLock() {
    this.resetAutoLockTimer();

    // Listen for user activity
    chrome.tabs.onActivated.addListener(() => this.resetAutoLockTimer());
    chrome.tabs.onUpdated.addListener(() => this.resetAutoLockTimer());
  }

  // Reset auto-lock timer
  resetAutoLockTimer() {
    if (this.autoLockTimer) {
      clearTimeout(this.autoLockTimer);
    }

    this.autoLockTimer = setTimeout(() => {
      this.lockExtension();
    }, LINKCRYPTA_CONFIG.EXTENSION.AUTO_LOCK_TIMEOUT);
  }

  // Update auto-lock timer (called when user interacts with extension)
  updateAutoLock() {
    this.resetAutoLockTimer();
  }

  // Lock extension
  async lockExtension() {
    // Clear sensitive data from memory
    await chrome.storage.session.clear();
    
    // Notify all components to lock
    chrome.runtime.sendMessage({
      type: 'EXTENSION_LOCKED'
    }).catch(() => {});

    console.log('Extension locked due to inactivity');
  }

  // Setup periodic data synchronization
  setupPeriodicSync() {
    this.syncInterval = setInterval(() => {
      this.performPeriodicSync();
    }, LINKCRYPTA_CONFIG.EXTENSION.SYNC_INTERVAL);
  }

  // Perform periodic synchronization
  async performPeriodicSync() {
    if (!this.isAuthenticated) return;

    try {
      console.log('Performing periodic sync...');
      // Add actual sync logic here when Firebase/Supabase is configured
    } catch (error) {
      console.error('Periodic sync failed:', error);
    }
  }

  // Get last sync timestamp
  async getLastSyncTime() {
    const result = await chrome.storage.local.get([LINKCRYPTA_CONFIG.STORAGE_KEYS.SYNC_TIMESTAMP]);
    return result[LINKCRYPTA_CONFIG.STORAGE_KEYS.SYNC_TIMESTAMP] || 0;
  }

  // Handle password filling
  async handleFillPassword(tab) {
    if (!this.isAuthenticated) {
      this.showNotification('Please sign in to LinkCrypta first');
      return;
    }

    try {
      // Get passwords for current URL
      const passwords = await this.getMatchingPasswords(tab.url);
      
      if (passwords.length === 0) {
        this.showNotification('No passwords found for this site');
        return;
      }

      // If only one password, fill it directly
      if (passwords.length === 1) {
        await chrome.tabs.sendMessage(tab.id, {
          action: 'fillPassword',
          password: passwords[0]
        });
      } else {
        // Show selection popup
        await chrome.tabs.sendMessage(tab.id, {
          action: 'showPasswordSelector',
          passwords: passwords
        });
      }
    } catch (error) {
      console.error('Error filling password:', error);
      this.showNotification('Failed to fill password');
    }
  }

  // Handle saving credentials
  async handleSaveCredentials(tab) {
    if (!this.isAuthenticated) {
      this.showNotification('Please sign in to LinkCrypta first');
      return;
    }

    try {
      await chrome.tabs.sendMessage(tab.id, {
        action: 'extractCredentials'
      });
    } catch (error) {
      console.error('Error saving credentials:', error);
      this.showNotification('Failed to save credentials');
    }
  }

  // Handle password generation
  async handleGeneratePassword(tab) {
    try {
      const password = this.generateRandomPassword();
      
      await chrome.tabs.sendMessage(tab.id, {
        action: 'fillGeneratedPassword',
        password
      });

      this.showNotification('Password generated and filled');
    } catch (error) {
      console.error('Error generating password:', error);
      this.showNotification('Failed to generate password');
    }
  }

  // Generate random password
  generateRandomPassword(options = {}) {
    const {
      length = 16,
      uppercase = true,
      lowercase = true,
      numbers = true,
      symbols = true
    } = options;

    let charset = '';
    if (lowercase) charset += 'abcdefghijklmnopqrstuvwxyz';
    if (uppercase) charset += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    if (numbers) charset += '0123456789';
    if (symbols) charset += '!@#$%^&*()_+-=[]{}|;:,.<>?';

    if (!charset) charset = 'abcdefghijklmnopqrstuvwxyz';

    let password = '';
    for (let i = 0; i < length; i++) {
      password += charset.charAt(Math.floor(Math.random() * charset.length));
    }

    return password;
  }

  // Get matching passwords for URL
  async getMatchingPasswords(url) {
    try {
      const passwords = await this.getStoredPasswords();
      const domain = this.extractDomain(url);
      
      return passwords.filter(password => {
        if (!password.url) return false;
        const passwordDomain = this.extractDomain(password.url);
        return this.calculateDomainMatch(domain, passwordDomain) > LINKCRYPTA_CONFIG.AUTOFILL.CONFIDENCE_THRESHOLD;
      });
    } catch (error) {
      console.error('Error getting matching passwords:', error);
      return [];
    }
  }

  // Load authentication state
  async loadAuthState() {
    try {
      const result = await chrome.storage.local.get(['isAuthenticated', 'currentUser']);
      this.isAuthenticated = result.isAuthenticated || false;
      this.currentUser = result.currentUser || null;
    } catch (error) {
      console.error('Failed to load auth state:', error);
      this.isAuthenticated = false;
      this.currentUser = null;
    }
  }

  // Authenticate user
  async authenticateUser() {
    try {
      // Simulate authentication - replace with actual Firebase/Supabase auth
      const user = {
        uid: 'demo-user-' + Date.now(),
        email: 'demo@linkcrypta.com',
        displayName: 'Demo User'
      };
      
      this.currentUser = user;
      this.isAuthenticated = true;
      
      await chrome.storage.local.set({
        isAuthenticated: true,
        currentUser: user
      });
      
      return { success: true, user };
    } catch (error) {
      console.error('Authentication failed:', error);
      return { success: false, error: error.message };
    }
  }

  // Sign out user
  async signOutUser() {
    try {
      this.currentUser = null;
      this.isAuthenticated = false;
      
      await chrome.storage.local.clear();
      
      return { success: true };
    } catch (error) {
      console.error('Sign out failed:', error);
      return { success: false, error: error.message };
    }
  }

  // Get stored passwords
  async getStoredPasswords() {
    try {
      const result = await chrome.storage.local.get(['passwords']);
      return result.passwords || [];
    } catch (error) {
      console.error('Failed to get passwords:', error);
      return [];
    }
  }

  // Search passwords by query and URL
  async searchPasswords(query = '', url = '') {
    const passwords = await this.getDecryptedPasswords();
    
    if (!passwords.length) return [];

    let filtered = passwords;

    // Filter by URL if provided
    if (url) {
      const domain = this.extractDomain(url);
      filtered = passwords.filter(password => {
        const passwordDomain = this.extractDomain(password.url);
        return this.calculateDomainMatch(domain, passwordDomain) > LINKCRYPTA_CONFIG.AUTOFILL.CONFIDENCE_THRESHOLD;
      });
    }

    // Filter by query if provided
    if (query) {
      const lowercaseQuery = query.toLowerCase();
      filtered = filtered.filter(password => 
        password.name.toLowerCase().includes(lowercaseQuery) ||
        password.username.toLowerCase().includes(lowercaseQuery) ||
        password.url.toLowerCase().includes(lowercaseQuery)
      );
    }

    return filtered.slice(0, LINKCRYPTA_CONFIG.AUTOFILL.MAX_SUGGESTIONS);
  }

  // Save new password
  async savePassword(passwordData) {
    try {
      const result = await chrome.storage.local.get(['passwords']);
      const passwords = result.passwords || [];
      
      // Add new password
      const newPassword = {
        id: this.generateId(),
        ...passwordData,
        createdAt: Date.now(),
        updatedAt: Date.now()
      };

      passwords.push(newPassword);
      
      await chrome.storage.local.set({ passwords });

      return { success: true, message: 'Password saved successfully' };
    } catch (error) {
      console.error('Error saving password:', error);
      return { success: false, error: 'Failed to save password' };
    }
  }

  // Perform data sync
  async performSync() {
    try {
      // Simulate sync - replace with actual Firebase/Supabase sync
      console.log('Syncing data...');
      return { success: true, message: 'Sync completed' };
    } catch (error) {
      console.error('Sync failed:', error);
      return { success: false, error: 'Sync failed' };
    }
  }

  // Log user activity
  async logUserActivity(activity) {
    try {
      const result = await chrome.storage.local.get(['activities']);
      const activities = result.activities || [];
      
      activities.push({
        ...activity,
        timestamp: Date.now()
      });
      
      // Keep only last 100 activities
      if (activities.length > 100) {
        activities.splice(0, activities.length - 100);
      }
      
      await chrome.storage.local.set({ activities });
    } catch (error) {
      console.error('Failed to log activity:', error);
    }
  }

  // Extract domain from URL
  extractDomain(url) {
    try {
      return new URL(url).hostname.replace('www.', '');
    } catch {
      return url;
    }
  }

  // Calculate domain matching confidence
  calculateDomainMatch(domain1, domain2) {
    if (domain1 === domain2) return 1.0;
    
    const parts1 = domain1.split('.');
    const parts2 = domain2.split('.');
    
    // Check if one is subdomain of other
    if (parts1.length > 1 && parts2.length > 1) {
      const baseDomain1 = parts1.slice(-2).join('.');
      const baseDomain2 = parts2.slice(-2).join('.');
      
      if (baseDomain1 === baseDomain2) return 0.8;
    }
    
    return 0.0;
  }

  // Generate unique ID
  generateId() {
    return Date.now().toString(36) + Math.random().toString(36).substr(2);
  }

  // Show notification
  showNotification(message) {
    chrome.notifications.create({
      type: 'basic',
      iconUrl: '/icons/icon-48.png',
      title: 'LinkCrypta',
      message: message
    });
  }

  // Detect forms on current page
  async detectFormsOnPage(tab) {
    try {
      await chrome.tabs.sendMessage(tab.id, {
        type: 'DETECT_FORMS'
      });
    } catch (error) {
      console.error('Error detecting forms:', error);
    }
  }
}

// Initialize background service
const backgroundService = new BackgroundService();

// Chrome extension lifecycle events
chrome.runtime.onStartup.addListener(() => {
  backgroundService.initialize();
});

chrome.runtime.onInstalled.addListener(() => {
  backgroundService.initialize();
});

// Handle tab updates for form detection
chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
  if (changeInfo.status === 'complete' && tab.url && !tab.url.startsWith('chrome://')) {
    backgroundService.detectFormsOnPage(tab);
  }
});
