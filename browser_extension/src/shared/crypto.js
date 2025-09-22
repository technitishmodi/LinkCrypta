// Cryptographic utilities for LinkCrypta Extension
class CryptoUtils {
  constructor() {
    this.encoder = new TextEncoder();
    this.decoder = new TextDecoder();
  }

  // Generate a random salt
  generateSalt(length = 16) {
    return crypto.getRandomValues(new Uint8Array(length));
  }

  // Generate a random IV
  generateIV(length = 12) {
    return crypto.getRandomValues(new Uint8Array(length));
  }

  // Derive encryption key from master password
  async deriveKey(password, salt, iterations = 100000) {
    const keyMaterial = await crypto.subtle.importKey(
      'raw',
      this.encoder.encode(password),
      { name: 'PBKDF2' },
      false,
      ['deriveBits', 'deriveKey']
    );

    return crypto.subtle.deriveKey(
      {
        name: 'PBKDF2',
        salt: salt,
        iterations: iterations,
        hash: 'SHA-256'
      },
      keyMaterial,
      { name: 'AES-GCM', length: 256 },
      true,
      ['encrypt', 'decrypt']
    );
  }

  // Encrypt data using AES-GCM
  async encrypt(data, key) {
    const iv = this.generateIV();
    const encodedData = this.encoder.encode(JSON.stringify(data));

    const encrypted = await crypto.subtle.encrypt(
      {
        name: 'AES-GCM',
        iv: iv
      },
      key,
      encodedData
    );

    // Combine IV and encrypted data
    const result = new Uint8Array(iv.length + encrypted.byteLength);
    result.set(iv);
    result.set(new Uint8Array(encrypted), iv.length);

    return Array.from(result);
  }

  // Decrypt data using AES-GCM
  async decrypt(encryptedArray, key) {
    const encryptedData = new Uint8Array(encryptedArray);
    const iv = encryptedData.slice(0, 12);
    const data = encryptedData.slice(12);

    const decrypted = await crypto.subtle.decrypt(
      {
        name: 'AES-GCM',
        iv: iv
      },
      key,
      data
    );

    const decryptedText = this.decoder.decode(decrypted);
    return JSON.parse(decryptedText);
  }

  // Hash master password for verification
  async hashPassword(password, salt) {
    const key = await this.deriveKey(password, salt, 10000); // Fewer iterations for hash
    const exported = await crypto.subtle.exportKey('raw', key);
    return Array.from(new Uint8Array(exported));
  }

  // Generate secure random password
  generatePassword(options = {}) {
    const {
      length = 16,
      includeUppercase = true,
      includeLowercase = true,
      includeNumbers = true,
      includeSymbols = true,
      excludeSimilar = true
    } = options;

    let charset = '';
    
    if (includeLowercase) {
      charset += excludeSimilar ? 'abcdefghjkmnpqrstuvwxyz' : 'abcdefghijklmnopqrstuvwxyz';
    }
    if (includeUppercase) {
      charset += excludeSimilar ? 'ABCDEFGHJKMNPQRSTUVWXYZ' : 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    }
    if (includeNumbers) {
      charset += excludeSimilar ? '23456789' : '0123456789';
    }
    if (includeSymbols) {
      charset += '!@#$%^&*()_+-=[]{}|;:,.<>?';
    }

    let password = '';
    const array = new Uint8Array(length);
    crypto.getRandomValues(array);

    for (let i = 0; i < length; i++) {
      password += charset[array[i] % charset.length];
    }

    return password;
  }

  // Calculate password strength
  calculatePasswordStrength(password) {
    let score = 0;
    let feedback = [];

    // Length check
    if (password.length >= 12) score += 25;
    else if (password.length >= 8) score += 15;
    else feedback.push('Use at least 8 characters');

    // Character variety
    if (/[a-z]/.test(password)) score += 15;
    else feedback.push('Add lowercase letters');

    if (/[A-Z]/.test(password)) score += 15;
    else feedback.push('Add uppercase letters');

    if (/[0-9]/.test(password)) score += 15;
    else feedback.push('Add numbers');

    if (/[^A-Za-z0-9]/.test(password)) score += 15;
    else feedback.push('Add symbols');

    // Bonus for length
    if (password.length >= 16) score += 10;
    if (password.length >= 20) score += 5;

    // Penalty for common patterns
    if (/(.)\1{2,}/.test(password)) score -= 10;
    if (/123|abc|qwe/i.test(password)) score -= 15;

    score = Math.max(0, Math.min(100, score));

    let strength = 'Very Weak';
    if (score >= 80) strength = 'Very Strong';
    else if (score >= 60) strength = 'Strong';
    else if (score >= 40) strength = 'Fair';
    else if (score >= 20) strength = 'Weak';

    return {
      score,
      strength,
      feedback
    };
  }

  // Secure memory cleanup
  clearSensitiveData(obj) {
    if (typeof obj === 'string') {
      // For strings, we can't truly clear memory in JS
      // but we can at least remove references
      return '';
    } else if (obj instanceof Uint8Array) {
      obj.fill(0);
    } else if (typeof obj === 'object' && obj !== null) {
      for (const key in obj) {
        if (obj.hasOwnProperty(key)) {
          obj[key] = null;
        }
      }
    }
  }
}

// Make CryptoUtils available globally
if (typeof window !== 'undefined') {
  window.CryptoUtils = CryptoUtils;
} else if (typeof global !== 'undefined') {
  global.CryptoUtils = CryptoUtils;
}
