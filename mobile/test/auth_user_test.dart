import 'package:flutter_test/flutter_test.dart';
import 'package:rescue_app/domain/models/auth_user.dart';

void main() {
  test('parses a full user payload', () {
    final user = AuthUser.fromJson({
      'id': 7,
      'username': 'responder@example.com',
      'email': 'responder@example.com',
      'name': 'Responder One',
      'role': 'rescuer',
      'is_staff': false,
    });

    expect(user.id, 7);
    expect(user.username, 'responder@example.com');
    expect(user.email, 'responder@example.com');
    expect(user.name, 'Responder One');
    expect(user.role, 'rescuer');
    expect(user.isStaff, isFalse);
  });

  test('fills safe defaults for a sparse payload', () {
    final user = AuthUser.fromJson({});

    expect(user.id, 0);
    expect(user.username, isEmpty);
    expect(user.email, isEmpty);
    expect(user.name, isEmpty);
    expect(user.role, isNull);
    expect(user.isStaff, isFalse);
  });
}
