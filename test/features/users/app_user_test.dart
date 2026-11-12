import 'package:flutter_test/flutter_test.dart';
import 'package:edutrack_app/features/users/domain/entities/app_user.dart';

void main() {
  group('AppUser Tests', () {
    test('role parsing works correctly', () {
      expect(UserRole.fromString('admin'), UserRole.admin);
      expect(UserRole.fromString('teacher'), UserRole.teacher);
      expect(UserRole.fromString('student'), UserRole.student);
      expect(UserRole.fromString('UNKNOWN'), UserRole.student); // default
      expect(UserRole.fromString(null), UserRole.student);
    });

    test('toMap and fromMap retain data correctly', () {
      final user = AppUser(
        uid: 'user_123',
        fullName: 'Fahri Test',
        email: 'fahri@test.com',
        role: UserRole.teacher,
        defaultLatePolicy: 'allowLate',
      );

      final map = user.toMap();
      expect(map['fullName'], 'Fahri Test');
      expect(map['email'], 'fahri@test.com');
      expect(map['role'], 'teacher');
      expect(map['defaultLatePolicy'], 'allowLate');

      final deserialized = AppUser.fromMap(map, 'user_123');
      expect(deserialized.uid, 'user_123');
      expect(deserialized.fullName, 'Fahri Test');
      expect(deserialized.isTeacher, isTrue);
      expect(deserialized.isAdmin, isFalse);
    });
  });
}

