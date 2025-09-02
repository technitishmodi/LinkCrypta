import 'dart:math';

enum PasswordType { random, pronounceable, passphrase, pattern }

class PasswordGenerationOptions {
  final PasswordType type;
  final int length;
  final bool includeUppercase;
  final bool includeLowercase;
  final bool includeNumbers;
  final bool includeSymbols;
  final bool excludeSimilar;
  final bool excludeAmbiguous;
  final String customPattern;
  final int wordCount;
  final String wordSeparator;
  final bool capitalizeWords;
  final bool includeNumbers2;

  PasswordGenerationOptions({
    this.type = PasswordType.random,
    this.length = 16,
    this.includeUppercase = true,
    this.includeLowercase = true,
    this.includeNumbers = true,
    this.includeSymbols = true,
    this.excludeSimilar = false,
    this.excludeAmbiguous = false,
    this.customPattern = '',
    this.wordCount = 4,
    this.wordSeparator = '-',
    this.capitalizeWords = true,
    this.includeNumbers2 = false,
  });
}

class GeneratedPassword {
  final String password;
  final int strength;
  final double entropy;
  final DateTime generatedAt;

  GeneratedPassword({
    required this.password,
    required this.strength,
    required this.entropy,
    required this.generatedAt,
  });
}

class AdvancedPasswordGenerator {
  static final Random _random = Random.secure();
  
  // Character sets
  static const String _lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const String _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _numbers = '0123456789';
  static const String _symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
  static const String _similar = 'il1Lo0O';
  static const String _ambiguous = '{}[]()/\\\'"`~,;<>.?';
  
  // Pronounceable patterns
  static const List<String> _consonants = [
    'b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'n', 'p', 'q', 'r', 's', 't', 'v', 'w', 'x', 'z'
  ];
  static const List<String> _vowels = ['a', 'e', 'i', 'o', 'u'];
  static const List<String> _consonantClusters = [
    'bl', 'br', 'ch', 'cl', 'cr', 'dr', 'fl', 'fr', 'gl', 'gr', 'pl', 'pr', 'sc', 'sh', 'sk', 'sl', 'sm', 'sn', 'sp', 'st', 'sw', 'th', 'tr', 'tw'
  ];
  
  // Common words for passphrases
  static const List<String> _commonWords = [
    'apple', 'banana', 'cherry', 'dragon', 'eagle', 'forest', 'guitar', 'happy', 'island', 'jungle',
    'kitten', 'lemon', 'mountain', 'ocean', 'piano', 'queen', 'river', 'sunset', 'tiger', 'umbrella',
    'violet', 'wizard', 'yellow', 'zebra', 'anchor', 'bridge', 'castle', 'diamond', 'engine', 'flower',
    'garden', 'hammer', 'iceberg', 'jacket', 'knight', 'ladder', 'magnet', 'needle', 'orange', 'pencil',
    'quartz', 'rocket', 'silver', 'turtle', 'unicorn', 'valley', 'window', 'xylophone', 'yogurt', 'zigzag'
  ];

  /// Generates a single password based on options
  static GeneratedPassword generatePassword(PasswordGenerationOptions options) {
    String password;
    
    switch (options.type) {
      case PasswordType.random:
        password = _generateRandomPassword(options);
        break;
      case PasswordType.pronounceable:
        password = _generatePronounceablePassword(options);
        break;
      case PasswordType.passphrase:
        password = _generatePassphrase(options);
        break;
      case PasswordType.pattern:
        password = _generatePatternPassword(options);
        break;
    }
    
    final strength = _calculateStrength(password);
    final entropy = _calculateEntropy(password);
    
    return GeneratedPassword(
      password: password,
      strength: strength,
      entropy: entropy,
      generatedAt: DateTime.now(),
    );
  }

  /// Generates multiple passwords
  static List<GeneratedPassword> generateBulkPasswords(
    PasswordGenerationOptions options,
    int count,
  ) {
    final passwords = <GeneratedPassword>[];
    for (int i = 0; i < count; i++) {
      passwords.add(generatePassword(options));
    }
    return passwords;
  }

  /// Generates a random password
  static String _generateRandomPassword(PasswordGenerationOptions options) {
    String charset = '';
    
    if (options.includeLowercase) charset += _lowercase;
    if (options.includeUppercase) charset += _uppercase;
    if (options.includeNumbers) charset += _numbers;
    if (options.includeSymbols) charset += _symbols;
    
    if (options.excludeSimilar) {
      for (final char in _similar.split('')) {
        charset = charset.replaceAll(char, '');
      }
    }
    
    if (options.excludeAmbiguous) {
      for (final char in _ambiguous.split('')) {
        charset = charset.replaceAll(char, '');
      }
    }
    
    if (charset.isEmpty) charset = _lowercase + _numbers;
    
    final password = StringBuffer();
    for (int i = 0; i < options.length; i++) {
      password.write(charset[_random.nextInt(charset.length)]);
    }
    
    return password.toString();
  }

  /// Generates a pronounceable password
  static String _generatePronounceablePassword(PasswordGenerationOptions options) {
    final password = StringBuffer();
    int currentLength = 0;
    
    while (currentLength < options.length) {
      // Add consonant or consonant cluster
      if (_random.nextBool() && _consonantClusters.isNotEmpty) {
        final cluster = _consonantClusters[_random.nextInt(_consonantClusters.length)];
        password.write(cluster);
        currentLength += cluster.length;
      } else {
        final consonant = _consonants[_random.nextInt(_consonants.length)];
        password.write(consonant);
        currentLength += 1;
      }
      
      if (currentLength >= options.length) break;
      
      // Add vowel
      final vowel = _vowels[_random.nextInt(_vowels.length)];
      password.write(vowel);
      currentLength += 1;
      
      // Occasionally add a number or symbol
      if (currentLength < options.length && _random.nextInt(4) == 0) {
        if (options.includeNumbers && _random.nextBool()) {
          password.write(_numbers[_random.nextInt(_numbers.length)]);
          currentLength += 1;
        } else if (options.includeSymbols) {
          password.write(_symbols[_random.nextInt(_symbols.length)]);
          currentLength += 1;
        }
      }
    }
    
    String result = password.toString();
    
    // Trim to exact length
    if (result.length > options.length) {
      result = result.substring(0, options.length);
    }
    
    // Apply case modifications
    if (options.includeUppercase) {
      result = _randomizeCase(result);
    }
    
    return result;
  }

  /// Generates a passphrase
  static String _generatePassphrase(PasswordGenerationOptions options) {
    final words = <String>[];
    
    for (int i = 0; i < options.wordCount; i++) {
      String word = _commonWords[_random.nextInt(_commonWords.length)];
      
      if (options.capitalizeWords) {
        word = word[0].toUpperCase() + word.substring(1);
      }
      
      // Occasionally modify words
      if (options.includeNumbers2 && _random.nextInt(3) == 0) {
        word += _random.nextInt(100).toString();
      }
      
      words.add(word);
    }
    
    String passphrase = words.join(options.wordSeparator);
    
    // Add symbols at the end if requested
    if (options.includeSymbols && _random.nextBool()) {
      passphrase += _symbols[_random.nextInt(_symbols.length)];
    }
    
    return passphrase;
  }

  /// Generates a password based on custom pattern
  static String _generatePatternPassword(PasswordGenerationOptions options) {
    if (options.customPattern.isEmpty) {
      return _generateRandomPassword(options);
    }
    
    final password = StringBuffer();
    
    for (int i = 0; i < options.customPattern.length; i++) {
      final char = options.customPattern[i];
      
      switch (char.toLowerCase()) {
        case 'l': // lowercase letter
          password.write(_lowercase[_random.nextInt(_lowercase.length)]);
          break;
        case 'u': // uppercase letter
          password.write(_uppercase[_random.nextInt(_uppercase.length)]);
          break;
        case 'd': // digit
          password.write(_numbers[_random.nextInt(_numbers.length)]);
          break;
        case 's': // symbol
          password.write(_symbols[_random.nextInt(_symbols.length)]);
          break;
        case 'a': // any character
          final allChars = _lowercase + _uppercase + _numbers;
          password.write(allChars[_random.nextInt(allChars.length)]);
          break;
        case 'w': // word
          password.write(_commonWords[_random.nextInt(_commonWords.length)]);
          break;
        default:
          password.write(char); // literal character
      }
    }
    
    return password.toString();
  }

  /// Randomizes case of a string
  static String _randomizeCase(String input) {
    final result = StringBuffer();
    
    for (int i = 0; i < input.length; i++) {
      final char = input[i];
      if (_random.nextBool()) {
        result.write(char.toUpperCase());
      } else {
        result.write(char.toLowerCase());
      }
    }
    
    return result.toString();
  }

  /// Calculates password strength (0-100)
  static int _calculateStrength(String password) {
    int score = 0;
    
    // Length scoring
    if (password.length >= 8) score += 25;
    if (password.length >= 12) score += 25;
    if (password.length >= 16) score += 10;
    
    // Character variety
    if (password.contains(RegExp(r'[a-z]'))) score += 10;
    if (password.contains(RegExp(r'[A-Z]'))) score += 10;
    if (password.contains(RegExp(r'[0-9]'))) score += 10;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 10;
    
    return score.clamp(0, 100);
  }

  /// Calculates password entropy
  static double _calculateEntropy(String password) {
    // Estimate character set size
    int charsetSize = 0;
    if (password.contains(RegExp(r'[a-z]'))) charsetSize += 26;
    if (password.contains(RegExp(r'[A-Z]'))) charsetSize += 26;
    if (password.contains(RegExp(r'[0-9]'))) charsetSize += 10;
    if (password.contains(RegExp(r'[^a-zA-Z0-9]'))) charsetSize += 32;
    
    if (charsetSize == 0) charsetSize = 1;
    
    // Entropy = log2(charsetSize^length)
    return password.length * (log(charsetSize) / log(2));
  }

  /// Gets predefined patterns for UI
  static List<Map<String, String>> getPredefinedPatterns() {
    return [
      {'name': 'Word-Number-Symbol', 'pattern': 'w-dd-s'},
      {'name': 'Upper-Lower-Digits', 'pattern': 'UUU-lll-ddd'},
      {'name': 'Alternating Case', 'pattern': 'UlUlUlUl'},
      {'name': 'Strong Mixed', 'pattern': 'UllddssUll'},
      {'name': 'Pronounceable+', 'pattern': 'lululu-dd'},
    ];
  }

  /// Validates pattern syntax
  static bool isValidPattern(String pattern) {
    final validChars = RegExp(r'^[lLuUdDsSwWaA\-_.,!@#$%^&*()]*$');
    return validChars.hasMatch(pattern) && pattern.isNotEmpty;
  }

  /// Gets pattern description
  static String getPatternDescription(String pattern) {
    return pattern
        .replaceAll('l', 'lowercase')
        .replaceAll('L', 'lowercase')
        .replaceAll('u', 'UPPERCASE')
        .replaceAll('U', 'UPPERCASE')
        .replaceAll('d', '0-9')
        .replaceAll('D', '0-9')
        .replaceAll('s', '!@#')
        .replaceAll('S', '!@#')
        .replaceAll('w', 'word')
        .replaceAll('W', 'word')
        .replaceAll('a', 'any')
        .replaceAll('A', 'any');
  }
}
