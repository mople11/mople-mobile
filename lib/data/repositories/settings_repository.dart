import 'package:mople_mobile/data/api/api_client.dart';
import 'package:mople_mobile/data/api/api_endpoints.dart';
import 'package:mople_mobile/data/models/models.dart';

/// `GET /settings`, `PATCH /settings` 연동.
class SettingsRepository {
  SettingsRepository._();

  static final SettingsRepository instance = SettingsRepository._();

  Future<AppSettings> fetchSettings() => apiClient.requestObject(
    'GET',
    ApiEndpoints.settings,
    parse: AppSettings.fromJson,
  );

  Future<void> updateSettings(SettingsUpdateRequest request) =>
      apiClient.requestVoid(
        'PATCH',
        ApiEndpoints.settings,
        body: request.toJson(),
      );
}

SettingsRepository get settingsRepository => SettingsRepository.instance;
