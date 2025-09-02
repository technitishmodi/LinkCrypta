import '../models/password_entry.dart';

enum FieldType { username, email, password, other }
enum MatchConfidence { exact, high, medium, low }

class UrlMatch {
  final PasswordEntry entry;
  final MatchConfidence confidence;
  final String reason;
  final double score;

  UrlMatch({
    required this.entry,
    required this.confidence,
    required this.reason,
    required this.score,
  });
}

class FormField {
  final String id;
  final String name;
  final String type;
  final String placeholder;
  final String label;
  final FieldType fieldType;

  FormField({
    required this.id,
    required this.name,
    required this.type,
    required this.placeholder,
    required this.label,
    required this.fieldType,
  });

  factory FormField.fromJson(Map<String, dynamic> json) {
    return FormField(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      placeholder: json['placeholder'] ?? '',
      label: json['label'] ?? '',
      fieldType: _detectFieldType(json),
    );
  }

  static FieldType _detectFieldType(Map<String, dynamic> json) {
    final type = (json['type'] ?? '').toLowerCase();
    final name = (json['name'] ?? '').toLowerCase();
    final id = (json['id'] ?? '').toLowerCase();
    final placeholder = (json['placeholder'] ?? '').toLowerCase();
    final label = (json['label'] ?? '').toLowerCase();

    final allText = '$type $name $id $placeholder $label';

    if (type == 'password') return FieldType.password;
    if (type == 'email') return FieldType.email;

    if (allText.contains('password') || allText.contains('pwd')) {
      return FieldType.password;
    }
    if (allText.contains('email') || allText.contains('e-mail')) {
      return FieldType.email;
    }
    if (allText.contains('username') || allText.contains('user') || 
        allText.contains('login') || allText.contains('account')) {
      return FieldType.username;
    }

    return FieldType.other;
  }
}

class AutoFillSuggestion {
  final PasswordEntry entry;
  final String fieldValue;
  final FieldType fieldType;
  final double confidence;

  AutoFillSuggestion({
    required this.entry,
    required this.fieldValue,
    required this.fieldType,
    required this.confidence,
  });
}

class SmartAutoFillService {
  static const List<String> _commonSubdomains = [
    'www', 'login', 'auth', 'signin', 'accounts', 'secure', 'my', 'app', 'api'
  ];

  static const List<String> _commonTlds = [
    '.com', '.org', '.net', '.edu', '.gov', '.co.uk', '.de', '.fr', '.jp', '.au'
  ];

  /// Finds matching passwords for a given URL
  static List<UrlMatch> findMatchingPasswords(
    String currentUrl,
    List<PasswordEntry> passwords,
  ) {
    final matches = <UrlMatch>[];
    final normalizedCurrentUrl = _normalizeUrl(currentUrl);

    for (final password in passwords) {
      final match = _calculateUrlMatch(normalizedCurrentUrl, password);
      if (match != null) {
        matches.add(match);
      }
    }

    // Sort by confidence and score
    matches.sort((a, b) {
      final confidenceCompare = _getConfidenceValue(b.confidence)
          .compareTo(_getConfidenceValue(a.confidence));
      if (confidenceCompare != 0) return confidenceCompare;
      return b.score.compareTo(a.score);
    });

    return matches;
  }

  /// Calculates URL match for a password entry
  static UrlMatch? _calculateUrlMatch(String currentUrl, PasswordEntry entry) {
    final entryUrl = _normalizeUrl(entry.url);
    if (entryUrl.isEmpty) return null;

    double score = 0;
    String reason = '';
    MatchConfidence confidence = MatchConfidence.low;

    // Exact match
    if (currentUrl == entryUrl) {
      score = 100;
      reason = 'Exact URL match';
      confidence = MatchConfidence.exact;
    }
    // Domain match
    else {
      final currentDomain = _extractDomain(currentUrl);
      final entryDomain = _extractDomain(entryUrl);

      if (currentDomain == entryDomain) {
        score = 90;
        reason = 'Exact domain match';
        confidence = MatchConfidence.high;
      }
      // Subdomain match
      else if (_isSubdomainMatch(currentDomain, entryDomain)) {
        score = 80;
        reason = 'Subdomain match';
        confidence = MatchConfidence.high;
      }
      // Root domain match
      else if (_isRootDomainMatch(currentDomain, entryDomain)) {
        score = 70;
        reason = 'Root domain match';
        confidence = MatchConfidence.medium;
      }
      // Similar domain
      else if (_isSimilarDomain(currentDomain, entryDomain)) {
        score = 50;
        reason = 'Similar domain';
        confidence = MatchConfidence.medium;
      }
      // Name/title similarity
      else if (_isNameSimilar(currentUrl, entry)) {
        score = 30;
        reason = 'Name similarity';
        confidence = MatchConfidence.low;
      }
    }

    // Boost score for recently used passwords
    final daysSinceUsed = DateTime.now().difference(entry.updatedAt).inDays;
    if (daysSinceUsed < 7) {
      score += 10;
    } else if (daysSinceUsed < 30) score += 5;

    // Boost score for favorites
    if (entry.isFavorite) score += 15;

    if (score > 25) {
      return UrlMatch(
        entry: entry,
        confidence: confidence,
        reason: reason,
        score: score,
      );
    }

    return null;
  }

  /// Normalizes URL for comparison
  static String _normalizeUrl(String url) {
    if (url.isEmpty) return '';
    
    String normalized = url.toLowerCase().trim();
    
    // Add protocol if missing
    if (!normalized.startsWith('http://') && !normalized.startsWith('https://')) {
      normalized = 'https://$normalized';
    }
    
    // Remove trailing slash
    if (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    
    // Remove common parameters
    final uri = Uri.tryParse(normalized);
    if (uri != null) {
      return '${uri.scheme}://${uri.host}${uri.path}';
    }
    
    return normalized;
  }

  /// Extracts domain from URL
  static String _extractDomain(String url) {
    final uri = Uri.tryParse(url);
    return uri?.host ?? '';
  }

  /// Checks if domains are subdomain matches
  static bool _isSubdomainMatch(String domain1, String domain2) {
    if (domain1 == domain2) return false;
    
    final parts1 = domain1.split('.');
    final parts2 = domain2.split('.');
    
    if (parts1.length < 2 || parts2.length < 2) return false;
    
    // Check if one is a subdomain of the other
    final rootDomain1 = parts1.sublist(parts1.length - 2).join('.');
    final rootDomain2 = parts2.sublist(parts2.length - 2).join('.');
    
    if (rootDomain1 == rootDomain2) {
      // Check if the subdomain is common
      final subdomain1 = parts1.length > 2 ? parts1[0] : '';
      final subdomain2 = parts2.length > 2 ? parts2[0] : '';
      
      return _commonSubdomains.contains(subdomain1) || 
             _commonSubdomains.contains(subdomain2) ||
             subdomain1.isEmpty || subdomain2.isEmpty;
    }
    
    return false;
  }

  /// Checks if domains share the same root domain
  static bool _isRootDomainMatch(String domain1, String domain2) {
    final parts1 = domain1.split('.');
    final parts2 = domain2.split('.');
    
    if (parts1.length < 2 || parts2.length < 2) return false;
    
    final rootDomain1 = parts1.sublist(parts1.length - 2).join('.');
    final rootDomain2 = parts2.sublist(parts2.length - 2).join('.');
    
    return rootDomain1 == rootDomain2;
  }

  /// Checks if domains are similar (fuzzy matching)
  static bool _isSimilarDomain(String domain1, String domain2) {
    // Remove common subdomains for comparison
    String clean1 = domain1;
    String clean2 = domain2;
    
    for (final subdomain in _commonSubdomains) {
      if (clean1.startsWith('$subdomain.')) {
        clean1 = clean1.substring(subdomain.length + 1);
      }
      if (clean2.startsWith('$subdomain.')) {
        clean2 = clean2.substring(subdomain.length + 1);
      }
    }
    
    // Calculate Levenshtein distance
    final distance = _levenshteinDistance(clean1, clean2);
    final maxLength = [clean1.length, clean2.length].reduce((a, b) => a > b ? a : b);
    
    if (maxLength == 0) return false;
    
    final similarity = 1 - (distance / maxLength);
    return similarity > 0.7; // 70% similarity threshold
  }

  /// Checks if entry name is similar to current URL
  static bool _isNameSimilar(String currentUrl, PasswordEntry entry) {
    final domain = _extractDomain(currentUrl);
    final entryName = entry.name.toLowerCase();
    
    // Check if entry name contains domain parts
    final domainParts = domain.split('.');
    for (final part in domainParts) {
      if (part.length > 3 && entryName.contains(part)) {
        return true;
      }
    }
    
    return false;
  }

  /// Calculates Levenshtein distance between two strings
  static int _levenshteinDistance(String s1, String s2) {
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;
    
    final matrix = List.generate(
      s1.length + 1,
      (i) => List.generate(s2.length + 1, (j) => 0),
    );
    
    for (int i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }
    
    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,      // deletion
          matrix[i][j - 1] + 1,      // insertion
          matrix[i - 1][j - 1] + cost // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    
    return matrix[s1.length][s2.length];
  }

  /// Gets numeric value for confidence comparison
  static int _getConfidenceValue(MatchConfidence confidence) {
    switch (confidence) {
      case MatchConfidence.exact: return 4;
      case MatchConfidence.high: return 3;
      case MatchConfidence.medium: return 2;
      case MatchConfidence.low: return 1;
    }
  }

  /// Analyzes form fields and suggests auto-fill values
  static List<AutoFillSuggestion> generateAutoFillSuggestions(
    List<FormField> formFields,
    List<UrlMatch> urlMatches,
    String Function(String encrypted) decryptionService,
  ) {
    final suggestions = <AutoFillSuggestion>[];
    
    if (urlMatches.isEmpty) return suggestions;
    
    final bestMatch = urlMatches.first;
    
    for (final field in formFields) {
      String? fieldValue;
      double confidence = bestMatch.score / 100;
      
      switch (field.fieldType) {
        case FieldType.username:
          fieldValue = bestMatch.entry.username;
          break;
        case FieldType.email:
          // Use username if it looks like an email, otherwise skip
          if (bestMatch.entry.username.contains('@')) {
            fieldValue = bestMatch.entry.username;
          }
          break;
        case FieldType.password:
          fieldValue = decryptionService(bestMatch.entry.password);
          confidence *= 0.9; // Slightly lower confidence for password fields
          break;
        case FieldType.other:
          continue; // Skip unknown fields
      }
      
      if (fieldValue != null && fieldValue.isNotEmpty) {
        suggestions.add(AutoFillSuggestion(
          entry: bestMatch.entry,
          fieldValue: fieldValue,
          fieldType: field.fieldType,
          confidence: confidence,
        ));
      }
    }
    
    return suggestions;
  }

  /// Extracts form fields from page HTML (simplified version)
  static List<FormField> extractFormFields(String html) {
    final fields = <FormField>[];
    
    // This is a simplified implementation
    // In a real browser extension, you'd use proper DOM parsing
    final inputRegex = RegExp(
      r'<input[^>]*>',
      caseSensitive: false,
    );
    
    final matches = inputRegex.allMatches(html);
    
    for (final match in matches) {
      final inputTag = match.group(0) ?? '';
      
      // Extract attributes using simpler regex patterns
      final type = _extractAttribute(inputTag, 'type');
      final name = _extractAttribute(inputTag, 'name');
      final id = _extractAttribute(inputTag, 'id');
      final placeholder = _extractAttribute(inputTag, 'placeholder');
      
      // Skip non-relevant input types
      if (['submit', 'button', 'hidden', 'checkbox', 'radio'].contains(type.toLowerCase())) {
        continue;
      }
      
      fields.add(FormField(
        id: id,
        name: name,
        type: type,
        placeholder: placeholder,
        label: '', // Would need more complex parsing for labels
        fieldType: FormField._detectFieldType({
          'type': type,
          'name': name,
          'id': id,
          'placeholder': placeholder,
        }),
      ));
    }
    
    return fields;
  }

  /// Helper method to extract attribute values from HTML tags
  static String _extractAttribute(String tag, String attributeName) {
    // Try double quotes first
    final doubleQuoteRegex = RegExp('$attributeName="([^"]*)"', caseSensitive: false);
    final doubleQuoteMatch = doubleQuoteRegex.firstMatch(tag);
    if (doubleQuoteMatch != null) {
      return doubleQuoteMatch.group(1) ?? '';
    }
    
    // Try single quotes
    final singleQuoteRegex = RegExp("$attributeName='([^']*)'", caseSensitive: false);
    final singleQuoteMatch = singleQuoteRegex.firstMatch(tag);
    if (singleQuoteMatch != null) {
      return singleQuoteMatch.group(1) ?? '';
    }
    
    // Try without quotes (less common but possible)
    final noQuoteRegex = RegExp('$attributeName=([^\\s>]*)', caseSensitive: false);
    final noQuoteMatch = noQuoteRegex.firstMatch(tag);
    if (noQuoteMatch != null) {
      return noQuoteMatch.group(1) ?? '';
    }
    
    return '';
  }

  /// Validates URL format
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  /// Gets domain suggestions for new password entries
  static List<String> getDomainSuggestions(String partialUrl) {
    final suggestions = <String>[];
    
    if (partialUrl.isEmpty) return suggestions;
    
    final normalized = partialUrl.toLowerCase();
    
    // Common domain patterns
    final commonDomains = [
      'google.com', 'facebook.com', 'twitter.com', 'github.com', 'linkedin.com',
      'amazon.com', 'microsoft.com', 'apple.com', 'netflix.com', 'spotify.com'
    ];
    
    for (final domain in commonDomains) {
      if (domain.contains(normalized) || normalized.contains(domain.split('.')[0])) {
        suggestions.add('https://$domain');
      }
    }
    
    // Add protocol if it looks like a domain
    if (normalized.contains('.') && !normalized.startsWith('http')) {
      suggestions.add('https://$normalized');
      suggestions.add('http://$normalized');
    }
    
    return suggestions.take(5).toList();
  }
}
