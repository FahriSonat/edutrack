import 'package:flutter_test/flutter_test.dart';
import 'package:edutrack_app/core/utils/validators.dart';

void main() {
  group('Validators Tests', () {
    test('required validator', () {
      expect(Validators.required(null), isNotNull);
      expect(Validators.required(''), isNotNull);
      expect(Validators.required('   '), isNotNull);
      expect(Validators.required('valid input'), isNull);
    });

    test('email validator', () {
      expect(Validators.email(null), isNotNull);
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('invalid-email'), isNotNull);
      expect(Validators.email('test@'), isNotNull);
      expect(Validators.email('student@edutrack.com'), isNull);
    });

    test('password validator', () {
      expect(Validators.password(null), isNotNull);
      expect(Validators.password('12345'), isNotNull); // < 6
      expect(Validators.password('123456'), isNull);
      expect(Validators.password('strongpassword123'), isNull);
    });

    test('githubRepoUrl validator', () {
      expect(Validators.githubRepoUrl(null), isNotNull);
      expect(Validators.githubRepoUrl(''), isNotNull);
      expect(Validators.githubRepoUrl('https://gitlab.com/user/repo'), isNotNull);
      expect(Validators.githubRepoUrl('https://github.com/torvalds/linux'), isNull);
      expect(Validators.githubRepoUrl('github.com/flutter/flutter.git'), isNull);
    });

    test('numberInRange validator', () {
      expect(Validators.numberInRange(null, min: 0, max: 100), isNotNull);
      expect(Validators.numberInRange('abc', min: 0, max: 100), isNotNull);
      expect(Validators.numberInRange('-1', min: 0, max: 100), isNotNull);
      expect(Validators.numberInRange('101', min: 0, max: 100), isNotNull);
      expect(Validators.numberInRange('0', min: 0, max: 100), isNull);
      expect(Validators.numberInRange('85', min: 0, max: 100), isNull);
      expect(Validators.numberInRange('100', min: 0, max: 100), isNull);
    });
  });
}

