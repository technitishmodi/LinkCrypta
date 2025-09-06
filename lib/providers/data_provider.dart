import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

import '../models/password_entry.dart';
import '../models/link_entry.dart';
import '../models/password_activity_log.dart';
import '../services/storage_service.dart';
import '../services/sync_service.dart';
import '../services/activity_log_service.dart';
import '../services/encryption_service.dart';

class DataProvider extends ChangeNotifier {
  List<PasswordEntry> _passwords = [];
  List<LinkEntry> _links = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedLinkCategory = 'All';

  List<PasswordEntry> get passwords => _getFilteredPasswords();
  List<LinkEntry> get links => _getFilteredLinks();
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
    final categories = _passwords.map((p) => p.category).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

  List<String> get linkCategories {
    final categories = _links.map((l) => l.category).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSelectedPasswordCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSelectedLinkCategory(String category) {
    _selectedLinkCategory = category;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    _selectedLinkCategory = 'All';
    notifyListeners();
  }

  List<LinkEntry> get allLinks => _links;


  List<PasswordEntry> _getFilteredPasswords() {
    List<PasswordEntry> filtered = _passwords;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((p) => p.category == _selectedCategory)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (p) =>
                p.name.toLowerCase().contains(query) ||
                p.username.toLowerCase().contains(query) ||
                p.url.toLowerCase().contains(query),
          )
          .toList();
    }

    return filtered;
  }

  List<LinkEntry> _getFilteredLinks() {
    List<LinkEntry> filtered = _links;

    // Filter by category
    if (_selectedLinkCategory != 'All') {
      filtered = filtered
          .where((l) => l.category == _selectedLinkCategory)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (l) =>
                l.title.toLowerCase().contains(query) ||
                l.description.toLowerCase().contains(query) ||
                l.url.toLowerCase().contains(query),
          )
          .toList();
    }

    return filtered;
  }

  Future<void> loadData() async {
    _setLoading(true);
    _clearError();

    try {
      _passwords = StorageService.getAllPasswords();
      _links = StorageService.getAllLinks();
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
        print('DataProvider: Password "${password.name}" synced to Firebase');
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
        print('DataProvider: Link "${link.title}" synced to Firebase');
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
        print('DataProvider: All data synced to Firebase');
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
        print('DataProvider: Data synced from Firebase');
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
    return await SyncService.getSyncStatus();
  }

  /// Get current user email for display
  String? getCurrentUserEmail() {
    return SyncService.getCurrentUserEmail();
  }
}
