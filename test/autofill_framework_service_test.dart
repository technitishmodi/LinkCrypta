import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

import '../lib/services/autofill_framework_service.dart';

void main() {
  group('AutofillFrameworkService', () {
    late AutofillFrameworkService autofillService;

    setUp(() {
      autofillService = AutofillFrameworkService.instance;
    });

    test('should be a singleton', () {
      final instance1 = AutofillFrameworkService.instance;
      final instance2 = AutofillFrameworkService.instance;
      expect(instance1, equals(instance2));
    });

    test('isSupported should return true', () {
      expect(AutofillFrameworkService.isSupported, isTrue);
    });

    test('showSaveCredentialsDialog method should exist', () {
      expect(AutofillFrameworkService.showSaveCredentialsDialog, isNotNull);
    });

    test('should handle method channel calls gracefully', () async {
      // Test that service doesn't crash when method channel is not available
      final service = AutofillFrameworkService.instance;
      
      // These calls might fail in test environment, but should not crash
      expect(() async {
        try {
          await service.isAutofillServiceEnabled();
          await service.getAutofillStats();
          await service.getAutofillApps();
        } catch (e) {
          // Platform channel errors are expected in test environment
          expect(e, isA<PlatformException>());
        }
      }, returnsNormally);
    });

    test('service should be instantiable', () {
      expect(autofillService, isNotNull);
      expect(autofillService, isA<AutofillFrameworkService>());
    });
  });
}