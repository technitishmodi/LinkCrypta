import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import '../models/password_entry.dart';
import '../models/link_entry.dart';
import '../models/password_activity_log.dart';
import '../services/storage_service.dart';
import '../services/sync_service.dart';
import '../services/activity_log_service.dart';
import '../services/encryption_service.dart';
import '../services/autofill_framework_service.dart';

class DataProvider extends ChangeNotifier {
  List<PasswordEntry> _passwords = [];
  List<LinkEntry> _links = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedLinkCategory = 'All';

  // Performance optimization: Add caching
  List<PasswordEntry>? _cachedFilteredPasswords;
  List<LinkEntry>? _cachedFilteredLinks;
  List<String>? _cachedPasswordCategories;
  List<String>? _cachedLinkCategories;
  
  // Cache validity flags
  bool _passwordFilterCacheValid = false;
  bool _linkFilterCacheValid = false;
  bool _passwordCategoryCacheValid = false;
  bool _linkCategoryCacheValid = false;
  
  // Debounce timer for search
  Timer? _debounceTimer;

  // Cached getters for performance
  List<PasswordEntry> get passwords {
    if (!_passwordFilterCacheValid || _cachedFilteredPasswords == null) {
      _cachedFilteredPasswords = _getFilteredPasswords();
      _passwordFilterCacheValid = true;
    }
    return _cachedFilteredPasswords!;
  }

  List<LinkEntry> get links {
    if (!_linkFilterCacheValid || _cachedFilteredLinks == null) {
      _cachedFilteredLinks = _getFilteredLinks();
      _linkFilterCacheValid = true;
    }
    return _cachedFilteredLinks!;
  }
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedLinkCategory => _selectedLinkCategory;

  List<PasswordEntry> get favoritePasswords =>
      _passwords.where((p) => p.isFavorite).toList();

  List<LinkEntry> get favoriteLinks =>
      _links.where((l) => l.isFavorite).toList();

  List<LinkEntry> get bookmarkedLinks =>
      _links.where((l) => l.isBookmarked).toList();

  List<String> get passwordCategories {
    if (!_passwordCategoryCacheValid || _cachedPasswordCategories == null) {
      final categories = _passwords.map((p) => p.category).toSet().toList();
      categories.sort();
      _cachedPasswordCategories = ['All', ...categories];
      _passwordCategoryCacheValid = true;
    }
    return _cachedPasswordCategories!;
  }

  // Static predefined categories to avoid recreating the list
  static const List<String> _predefinedLinkCategories = [
    'General',
    'Work',
    'Personal', 
    'Social',
    'Learning',
    'Entertainment',
    'News',
    'Shopping',
    'Finance',
    'Health',
    'Travel',
    'Technology',
    'Sports',
    'Food',
    'Music',
    'Gaming',
    'Photography',
    'Art & Design',
    'Business',
    'Education',
    'Science',
    'Reference',
    'Tools',
    'Productivity',
    'Communication'
  ];

  List<String> get linkCategories {
    if (!_linkCategoryCacheValid || _cachedLinkCategories == null) {
      // Get categories from existing links
      final existingCategories = _links.map((l) => l.category).toSet();
      
      // Combine predefined and existing categories, remove duplicates
      final allCategories = {..._predefinedLinkCategories, ...existingCategories}.toList();
      allCategories.sort();
      
      _cachedLinkCategories = ['All', ...allCategories];
      _linkCategoryCacheValid = true;
    }
    return _cachedLinkCategories!;
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return; // Avoid unnecessary updates
    
    _searchQuery = query;
    _invalidateFilterCaches();
    
    // Debounce to reduce frequent updates during typing
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      notifyListeners();
    });
  }

  void setSelectedCategory(String category) {
    if (_selectedCategory == category) return; // Avoid unnecessary updates
    
    _selectedCategory = category;
    _passwordFilterCacheValid = false;
    notifyListeners();
  }

  void setSelectedPasswordCategory(String category) {
    if (_selectedCategory == category) return; // Avoid unnecessary updates
    
    _selectedCategory = category;
    _passwordFilterCacheValid = false;
    notifyListeners();
  }

  void setSelectedLinkCategory(String category) {
    if (_selectedLinkCategory == category) return; // Avoid unnecessary updates
    
    _selectedLinkCategory = category;
    _linkFilterCacheValid = false;
    notifyListeners();
  }

  void clearFilters() {
    bool hasChanges = false;
    
    if (_searchQuery.isNotEmpty) {
      _searchQuery = '';
      hasChanges = true;
    }
    
    if (_selectedCategory != 'All') {
      _selectedCategory = 'All';
      hasChanges = true;
    }
    
    if (_selectedLinkCategory != 'All') {
      _selectedLinkCategory = 'All';
      hasChanges = true;
    }
    
    if (hasChanges) {
      _invalidateFilterCaches();
      notifyListeners();
    }
  }

  // Cache invalidation methods
  void _invalidateFilterCaches() {
    _passwordFilterCacheValid = false;
    _linkFilterCacheValid = false;
  }

  void _invalidateAllCaches() {
    _passwordFilterCacheValid = false;
    _linkFilterCacheValid = false;
    _passwordCategoryCacheValid = false;
    _linkCategoryCacheValid = false;
  }

  List<LinkEntry> get allLinks => _links;
  List<PasswordEntry> get allPasswords => _passwords;


  List<PasswordEntry> _getFilteredPasswords() {
    List<PasswordEntry> filtered = _passwords;

    // Filter by category first (faster)
    if (_selectedCategory != 'All') {
      filtered = filtered.where((p) => p.category == _selectedCategory).toList();
    }

    // Optimize search filtering
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((p) {
        // Pre-compute combined search text once per item
        final searchText = '${p.name} ${p.username} ${p.url}'.toLowerCase();
        return searchText.contains(query);
      }).toList();
    }

    return filtered;
  }

  List<LinkEntry> _getFilteredLinks() {
    List<LinkEntry> filtered = _links;

    // Filter by category first (faster)
    if (_selectedLinkCategory != 'All') {
      filtered = filtered.where((l) => l.category == _selectedLinkCategory).toList();
    }

    // Optimize search filtering
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((l) {
        // Pre-compute combined search text once per item
        final searchText = '${l.title} ${l.description} ${l.url}'.toLowerCase();
        return searchText.contains(query);
      }).toList();
    }

    return filtered;
  }

  Future<void> loadData() async {
    _setLoading(true);
    _clearError();

    try {
      _passwords = StorageService.getAllPasswords();
      _links = StorageService.getAllLinks();
      _invalidateAllCaches(); // Invalidate all caches when data reloads
      
      // Initialize autofill framework service with this data provider
      await AutofillFrameworkService.instance.initialize(this);
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Password Management
  Future<void> addPassword({
    required String name,
    required String username,
    required String password,
    required String url,
    String notes = '',
    String category = 'General',
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final entry = await StorageService.addPassword(
        name: name,
        username: username,
        password: password,
        url: url,
        notes: notes,
        category: category,
      );
      _passwords.add(entry);
      
      // Log the password creation activity
      await ActivityLogService.logPasswordCreated(entry);
      
      // Invalidate caches when data changes
      _invalidateAllCaches();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updatePassword(PasswordEntry entry) async {
    _setLoading(true);
    _clearError();

    try {
      // Get the old entry for logging
      final index = _passwords.indexWhere((p) => p.id == entry.id);
      final oldEntry = index != -1 ? _passwords[index] : null;
      
      await StorageService.updatePassword(entry);
      if (index != -1) {
        _passwords[index] = entry;
        
        // Log the password update activity
        if (oldEntry != null) {
          await ActivityLogService.logPasswordUpdated(entry, oldEntry.password);
        }
        
        _invalidateAllCaches(); // Invalidate caches when data changes
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deletePassword(PasswordEntry entry) async {
    _setLoading(true);
    _clearError();

    try {
      // Log the password deletion activity before deleting
      await ActivityLogService.logPasswordDeleted(entry);
      
      await StorageService.deletePassword(entry);
      _passwords.removeWhere((p) => p.id == entry.id);
      _invalidateAllCaches(); // Invalidate caches when data changes
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> togglePasswordFavorite(PasswordEntry entry) async {
    final box = Hive.box<PasswordEntry>('passwords');
    final index = _passwords.indexWhere((e) => e.id == entry.id);
    if (index == -1) return;

    final updatedEntry = entry.copyWith(isFavorite: !entry.isFavorite);

    await box.putAt(index, updatedEntry); // Update Hive
    _passwords[index] = updatedEntry; // Update local list
    notifyListeners(); // Notify UI
  }

  String generatePassword({
    int length = 16,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSymbols = true,
  }) {
    return EncryptionService.generateStrongPassword(
      length: length,
      includeUppercase: includeUppercase,
      includeLowercase: includeLowercase,
      includeNumbers: includeNumbers,
      includeSymbols: includeSymbols,
    );
  }

  // Link Management
  Future<void> addLink({
    required String title,
    required String description,
    required String url,
    String category = 'General',
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final entry = await StorageService.addLink(
        title: title,
        description: description,
        url: url,
        category: category,
      );
      _links.add(entry);
      _invalidateAllCaches(); // Invalidate caches when data changes
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateLink(LinkEntry entry) async {
    _setLoading(true);
    _clearError();

    try {
      await StorageService.updateLink(entry);
      final index = _links.indexWhere((l) => l.id == entry.id);
      if (index != -1) {
        _links[index] = entry;
        _invalidateAllCaches(); // Invalidate caches when data changes
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteLink(LinkEntry entry) async {
    _setLoading(true);
    _clearError();

    try {
      await StorageService.deleteLink(entry);
      _links.removeWhere((l) => l.id == entry.id);
      _invalidateAllCaches(); // Invalidate caches when data changes
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleLinkFavorite(LinkEntry entry) async {
    final box = Hive.box<LinkEntry>('links');
    
    // Find the entry in the Hive box by ID
    LinkEntry? foundEntry;
    int hiveIndex = -1;
    
    for (int i = 0; i < box.length; i++) {
      final boxEntry = box.getAt(i);
      if (boxEntry?.id == entry.id) {
        foundEntry = boxEntry;
        hiveIndex = i;
        break;
      }
    }
    
    if (foundEntry == null || hiveIndex == -1) return;

    final updatedEntry = foundEntry.copyWith(isFavorite: !foundEntry.isFavorite);

    // Update in Hive using the correct index
    await box.putAt(hiveIndex, updatedEntry);
    
    // Update in memory list
    final memoryIndex = _links.indexWhere((e) => e.id == entry.id);
    if (memoryIndex != -1) {
      _links[memoryIndex] = updatedEntry;
    }
    
    notifyListeners(); // Update UI
  }

  Future<void> toggleLinkBookmark(LinkEntry entry) async {
    final updatedEntry = entry.copyWith(isBookmarked: !entry.isBookmarked);
    await updateLink(updatedEntry);
  }

  // Data Export/Import
  Map<String, dynamic> exportData() {
    return StorageService.exportData();
  }

  Future<void> importData(Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();

    try {
      await StorageService.importData(data);
      await loadData(); // Reload data after import
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> clearAllData() async {
    _setLoading(true);
    _clearError();

    try {
      await StorageService.clearAllData();
      _passwords.clear();
      _links.clear();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // Password decryption
  String getDecryptedPassword(PasswordEntry entry) {
    return StorageService.decryptPassword(entry.password);
  }

  // Log password view activity
  Future<void> logPasswordViewed(PasswordEntry entry) async {
    try {
      await ActivityLogService.logPasswordViewed(entry);
    } catch (e) {
      print('DataProvider: Failed to log password view: $e');
    }
  }

  // Activity log methods
  List<PasswordActivityLog> getAllPasswordLogs() {
    try {
      return ActivityLogService.getAllLogs();
    } catch (e) {
      print('DataProvider: Failed to get all logs: $e');
      return [];
    }
  }

  List<PasswordActivityLog> getPasswordLogsForPassword(String passwordId) {
    try {
      return ActivityLogService.getLogsForPassword(passwordId);
    } catch (e) {
      print('DataProvider: Failed to get logs for password: $e');
      return [];
    }
  }

  List<PasswordActivityLog> getPasswordLogsInDateRange(DateTime startDate, DateTime endDate) {
    try {
      return ActivityLogService.getLogsInDateRange(startDate, endDate);
    } catch (e) {
      print('DataProvider: Failed to get logs in date range: $e');
      return [];
    }
  }

  List<PasswordActivityLog> getPasswordLogsByActivityType(ActivityType activityType) {
    try {
      return ActivityLogService.getLogsByActivityType(activityType);
    } catch (e) {
      print('DataProvider: Failed to get logs by activity type: $e');
      return [];
    }
  }

  // MANUAL FIREBASE SYNC METHODS

  /// Sync a specific password to Firebase when user views password details
  Future<bool> syncPasswordToFirebase(PasswordEntry password) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await SyncService.syncPasswordToFirebase(password);
      if (success) {
        // Password synced to Firebase
      }
      return success;
    } catch (e) {
      _setError('Failed to sync password: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sync a specific link to Firebase when user views link details
  Future<bool> syncLinkToFirebase(LinkEntry link) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await SyncService.syncLinkToFirebase(link);
      if (success) {
        // Link synced to Firebase
      }
      return success;
    } catch (e) {
      _setError('Failed to sync link: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Manual full sync to Firebase - triggered by user action
  Future<bool> syncAllToFirebase() async {
    _setLoading(true);
    _clearError();

    try {
      final success = await SyncService.syncAllToFirebase();
      if (success) {
        // All data synced to Firebase
      }
      notifyListeners();
      return success;
    } catch (e) {
      _setError('Failed to sync to Firebase: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Manual sync from Firebase - download cloud data
  Future<bool> syncFromFirebase() async {
    _setLoading(true);
    _clearError();

    try {
      final success = await SyncService.syncFromFirebase();
      if (success) {
        // Reload local data after sync
        await loadData();
        // Data synced from Firebase
      }
      return success;
    } catch (e) {
      _setError('Failed to sync from Firebase: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Check if user can sync with Firebase
  bool canSyncWithFirebase() {
    return SyncService.canSync();
  }

  /// Get sync status information
  Future<Map<String, dynamic>> getSyncStatus() async {
    return SyncService.getSyncStatus();
  }

  /// Get current user email for display
  String? getCurrentUserEmail() {
    return SyncService.getCurrentUserEmail();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
