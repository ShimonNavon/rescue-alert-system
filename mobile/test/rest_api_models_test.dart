import 'package:flutter_test/flutter_test.dart';
import 'package:rescue_app/domain/services/api/rest_api_models.dart';

void main() {
  test('parses a JWT pair', () {
    final tokens = JwtTokens.fromJson({
      'access': 'access-token',
      'refresh': 'refresh-token',
    });

    expect(tokens.access, 'access-token');
    expect(tokens.refresh, 'refresh-token');
    expect(tokens.toJson(), {
      'access': 'access-token',
      'refresh': 'refresh-token',
    });
  });
}
