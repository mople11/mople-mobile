import 'package:mople_mobile/data/models/common/json_utils.dart';

/// `GET /settings` 의 language.
enum AppLanguage {
  ko('ko'),
  en('en'),
  ja('ja'),
  zh('zh');

  const AppLanguage(this.value);

  final String value;

  static AppLanguage? fromValue(String? value) {
    for (final item in values) {
      if (item.value == value) return item;
    }
    return null;
  }
}

/// `data.notifications`
class NotificationSettings {
  const NotificationSettings({required this.push, required this.goldenHour});

  final bool push;

  /// 골든아워(촬영 좋은 시간) 알림.
  final bool goldenHour;

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      NotificationSettings(
        push: asBool(json['push']),
        goldenHour: asBool(json['goldenHour']),
      );

  Map<String, dynamic> toJson() => {'push': push, 'goldenHour': goldenHour};

  NotificationSettings copyWith({bool? push, bool? goldenHour}) =>
      NotificationSettings(
        push: push ?? this.push,
        goldenHour: goldenHour ?? this.goldenHour,
      );

  static const defaults = NotificationSettings(push: true, goldenHour: true);
}

/// `data.permissions`
class PermissionSettings {
  const PermissionSettings({required this.location});

  final bool location;

  factory PermissionSettings.fromJson(Map<String, dynamic> json) =>
      PermissionSettings(location: asBool(json['location']));

  Map<String, dynamic> toJson() => {'location': location};

  PermissionSettings copyWith({bool? location}) =>
      PermissionSettings(location: location ?? this.location);

  static const defaults = PermissionSettings(location: true);
}

/// `GET /settings` 의 `data`.
class AppSettings {
  const AppSettings({
    required this.notifications,
    required this.language,
    required this.permissions,
  });

  final NotificationSettings notifications;
  final AppLanguage language;
  final PermissionSettings permissions;

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    notifications: NotificationSettings.fromJson(asMap(json['notifications'])),
    language:
        AppLanguage.fromValue(asStringOrNull(json['language'])) ??
        AppLanguage.ko,
    permissions: PermissionSettings.fromJson(asMap(json['permissions'])),
  );

  Map<String, dynamic> toJson() => {
    'notifications': notifications.toJson(),
    'language': language.value,
    'permissions': permissions.toJson(),
  };

  AppSettings copyWith({
    NotificationSettings? notifications,
    AppLanguage? language,
    PermissionSettings? permissions,
  }) => AppSettings(
    notifications: notifications ?? this.notifications,
    language: language ?? this.language,
    permissions: permissions ?? this.permissions,
  );

  static const defaults = AppSettings(
    notifications: NotificationSettings.defaults,
    language: AppLanguage.ko,
    permissions: PermissionSettings.defaults,
  );
}

/// `PATCH /settings` 요청 바디. 변경된 항목만 담는다.
class SettingsUpdateRequest {
  const SettingsUpdateRequest({
    this.notifications,
    this.language,
    this.permissions,
  });

  final NotificationSettings? notifications;
  final AppLanguage? language;
  final PermissionSettings? permissions;

  bool get isEmpty =>
      notifications == null && language == null && permissions == null;

  Map<String, dynamic> toJson() => compactJson({
    'notifications': notifications?.toJson(),
    'language': language?.value,
    'permissions': permissions?.toJson(),
  });
}
