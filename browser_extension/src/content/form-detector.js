// Form Detection Module for LinkCrypta Extension
class FormDetector {
  constructor() {
    this.detectedForms = new Map();
    this.observing = false;
    this.observer = null;
  }

  // Start observing the page for forms
  startObserving() {
    if (this.observing) return;

    this.detectExistingForms();
    this.setupMutationObserver();
    this.observing = true;
  }

  // Stop observing
  stopObserving() {
    if (this.observer) {
      this.observer.disconnect();
      this.observer = null;
    }
    this.observing = false;
  }

  // Detect existing forms on page load
  detectExistingForms() {
    const forms = document.querySelectorAll('form');
    forms.forEach(form => this.analyzeForm(form));

    // Also check for forms without form tags
    this.detectFormlessCredentials();
  }

  // Setup mutation observer to detect dynamically added forms
  setupMutationObserver() {
    this.observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        mutation.addedNodes.forEach((node) => {
          if (node.nodeType === Node.ELEMENT_NODE) {
            // Check if the added node is a form
            if (node.tagName === 'FORM') {
              this.analyzeForm(node);
            }
            
            // Check for forms within added nodes
            const forms = node.querySelectorAll?.('form');
            forms?.forEach(form => this.analyzeForm(form));
            
            // Check for credential fields
            this.analyzeForCredentialFields(node);
          }
        });
      });
    });

    this.observer.observe(document.body, {
      childList: true,
      subtree: true
    });
  }

  // Analyze a form to determine if it's a login form
  analyzeForm(form) {
    const formData = this.extractFormData(form);
    
    if (formData.isLoginForm) {
      this.detectedForms.set(form, formData);
      this.markFormAsDetected(form);
      
      // Notify background script
      this.notifyFormDetected(formData);
    }
  }

  // Extract form data and classify
  extractFormData(form) {
    const usernameField = this.findUsernameField(form);
    const passwordField = this.findPasswordField(form);
    const submitButton = this.findSubmitButton(form);
    
    const isLoginForm = this.classifyAsLoginForm(form, usernameField, passwordField);
    const confidence = this.calculateConfidence(form, usernameField, passwordField);
    
    return {
      form,
      usernameField,
      passwordField,
      submitButton,
      isLoginForm,
      confidence,
      url: window.location.href,
      domain: window.location.hostname,
      formAction: form.action || window.location.href,
      formMethod: form.method || 'GET'
    };
  }

  // Find username field in form
  findUsernameField(form) {
    const selectors = LINKCRYPTA_CONFIG.FORM_SELECTORS.USERNAME_FIELDS;
    
    for (const selector of selectors) {
      const field = form.querySelector(selector);
      if (field && this.isVisibleField(field)) {
        return field;
      }
    }
    
    // Fallback: look for text inputs that might be username fields
    const textInputs = form.querySelectorAll('input[type="text"], input[type="email"]');
    return Array.from(textInputs).find(input => 
      this.isVisibleField(input) && this.looksLikeUsernameField(input)
    );
  }

  // Find password field in form
  findPasswordField(form) {
    const selectors = LINKCRYPTA_CONFIG.FORM_SELECTORS.PASSWORD_FIELDS;
    
    for (const selector of selectors) {
      const field = form.querySelector(selector);
      if (field && this.isVisibleField(field)) {
        return field;
      }
    }
    
    return null;
  }

  // Find submit button
  findSubmitButton(form) {
    // Look for submit button
    let submitBtn = form.querySelector('input[type="submit"], button[type="submit"]');
    
    if (!submitBtn) {
      // Look for buttons with login-related text
      const buttons = form.querySelectorAll('button');
      submitBtn = Array.from(buttons).find(btn => {
        const text = btn.textContent.toLowerCase();
        return /sign.?in|log.?in|submit|continue|next/i.test(text);
      });
    }
    
    return submitBtn;
  }

  // Classify form as login form
  classifyAsLoginForm(form, usernameField, passwordField) {
    // Must have a password field
    if (!passwordField) return false;
    
    // Check form characteristics
    const hasUsernameField = !!usernameField;
    const hasLoginKeywords = this.hasLoginKeywords(form);
    const isInLoginContext = this.isInLoginContext();
    
    return hasUsernameField && (hasLoginKeywords || isInLoginContext);
  }

  // Check if form has login-related keywords
  hasLoginKeywords(form) {
    const text = (form.textContent || '').toLowerCase();
    const className = (form.className || '').toLowerCase();
    const id = (form.id || '').toLowerCase();
    
    const loginKeywords = /sign.?in|log.?in|auth|login|credential/i;
    
    return loginKeywords.test(text) || loginKeywords.test(className) || loginKeywords.test(id);
  }

  // Check if page is in login context
  isInLoginContext() {
    const url = window.location.href.toLowerCase();
    const title = document.title.toLowerCase();
    
    const loginKeywords = /sign.?in|log.?in|auth|login|account|portal/i;
    
    return loginKeywords.test(url) || loginKeywords.test(title);
  }

  // Check if field looks like username field
  looksLikeUsernameField(field) {
    const name = (field.name || '').toLowerCase();
    const id = (field.id || '').toLowerCase();
    const placeholder = (field.placeholder || '').toLowerCase();
    const autocomplete = (field.autocomplete || '').toLowerCase();
    
    const usernamePatterns = /user|email|login|account|member/i;
    
    return usernamePatterns.test(name) || 
           usernamePatterns.test(id) || 
           usernamePatterns.test(placeholder) ||
           autocomplete.includes('username') ||
           autocomplete.includes('email');
  }

  // Check if field is visible
  isVisibleField(field) {
    const style = window.getComputedStyle(field);
    return style.display !== 'none' && 
           style.visibility !== 'hidden' && 
           style.opacity !== '0' &&
           field.offsetWidth > 0 && 
           field.offsetHeight > 0;
  }

  // Calculate confidence score
  calculateConfidence(form, usernameField, passwordField) {
    let score = 0;
    
    // Base score for having required fields
    if (passwordField) score += 40;
    if (usernameField) score += 30;
    
    // Bonus for form characteristics
    if (this.hasLoginKeywords(form)) score += 15;
    if (this.isInLoginContext()) score += 10;
    
    // Bonus for proper field attributes
    if (usernameField?.autocomplete?.includes('username')) score += 5;
    if (passwordField?.autocomplete?.includes('current-password')) score += 5;
    
    return Math.min(100, score) / 100;
  }

  // Detect credentials in forms without form tags
  detectFormlessCredentials() {
    const usernameFields = document.querySelectorAll(
      LINKCRYPTA_CONFIG.FORM_SELECTORS.USERNAME_FIELDS.join(', ')
    );
    const passwordFields = document.querySelectorAll(
      LINKCRYPTA_CONFIG.FORM_SELECTORS.PASSWORD_FIELDS.join(', ')
    );
    
    // Group nearby fields
    passwordFields.forEach(passwordField => {
      if (!this.isVisibleField(passwordField)) return;
      
      const nearbyUsernameField = this.findNearbyUsernameField(passwordField, usernameFields);
      
      if (nearbyUsernameField) {
        const pseudoForm = {
          usernameField: nearbyUsernameField,
          passwordField: passwordField,
          isFormless: true,
          confidence: 0.8,
          url: window.location.href,
          domain: window.location.hostname
        };
        
        this.detectedForms.set(passwordField, pseudoForm);
        this.markFieldAsDetected(passwordField);
        this.notifyFormDetected(pseudoForm);
      }
    });
  }

  // Find nearby username field for formless detection
  findNearbyUsernameField(passwordField, usernameFields) {
    const passwordRect = passwordField.getBoundingClientRect();
    let closestField = null;
    let closestDistance = Infinity;
    
    Array.from(usernameFields).forEach(field => {
      if (!this.isVisibleField(field)) return;
      
      const fieldRect = field.getBoundingClientRect();
      const distance = Math.sqrt(
        Math.pow(passwordRect.top - fieldRect.top, 2) +
        Math.pow(passwordRect.left - fieldRect.left, 2)
      );
      
      if (distance < closestDistance && distance < 200) { // Within 200px
        closestDistance = distance;
        closestField = field;
      }
    });
    
    return closestField;
  }

  // Analyze node for credential fields
  analyzeForCredentialFields(node) {
    if (!node.querySelectorAll) return;
    
    const passwordFields = node.querySelectorAll(
      LINKCRYPTA_CONFIG.FORM_SELECTORS.PASSWORD_FIELDS.join(', ')
    );
    
    if (passwordFields.length > 0) {
      // Re-run formless detection for new fields
      this.detectFormlessCredentials();
    }
  }

  // Mark form as detected (visual indicator)
  markFormAsDetected(form) {
    if (!form.hasAttribute('data-linkcrypta-detected')) {
      form.setAttribute('data-linkcrypta-detected', 'true');
      form.style.cssText += 'border: 1px solid #6C63FF !important; border-radius: 4px !important;';
    }
  }

  // Mark field as detected
  markFieldAsDetected(field) {
    if (!field.hasAttribute('data-linkcrypta-detected')) {
      field.setAttribute('data-linkcrypta-detected', 'true');
    }
  }

  // Notify background script of detected form
  notifyFormDetected(formData) {
    chrome.runtime.sendMessage({
      type: 'FORM_DETECTED',
      formData: {
        url: formData.url,
        domain: formData.domain,
        confidence: formData.confidence,
        isFormless: formData.isFormless || false,
        hasUsernameField: !!formData.usernameField,
        hasPasswordField: !!formData.passwordField
      }
    }).catch(() => {}); // Ignore if background script not ready
  }

  // Get all detected forms
  getDetectedForms() {
    return Array.from(this.detectedForms.values());
  }

  // Get form by element
  getFormData(element) {
    return this.detectedForms.get(element);
  }

  // Clear detected forms
  clearDetectedForms() {
    this.detectedForms.clear();
  }

  // Check if a form is already detected
  isFormDetected(form) {
    return this.detectedForms.has(form);
  }
}

// Make FormDetector available globally
if (typeof window !== 'undefined') {
  window.FormDetector = FormDetector;
}
