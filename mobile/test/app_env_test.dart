import 'package:flutter_test/flutter_test.dart';
import 'package:rescue_app/constants/app_env.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('falls back to the cluster API when dotenv is not initialized', () {
    expect(AppEnv.apiBaseUrl, 'http://ubuntu03:30093');
    expect(AppEnv.env, 'staging');
    expect(AppEnv.mapboxAccessToken, isEmpty);
  });
}
