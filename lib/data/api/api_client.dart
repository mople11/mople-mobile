import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mople_mobile/data/api/api_endpoints.dart';
import 'package:mople_mobile/data/api/auth_token_store.dart';
import 'package:mople_mobile/data/models/common/api_response.dart';
import 'package:mople_mobile/data/models/common/json_utils.dart';
import 'package:mople_mobile/data/models/common/pagination.dart';

/// `{ success, data, error }` 봉투를 벗겨 Repository 에 값 또는 [ApiException] 을 돌려주는
/// 공용 Dio 래퍼.
///
/// 도메인 Repository 는 이 클래스만 통해 통신하고, 응답 파싱은 각 모델의 `fromJson` 에 맡긴다.
class ApiClient {
  ApiClient({Dio? dio, String? baseUrl})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl ?? _defaultBaseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              contentType: 'application/json',
            ),
          ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = AuthTokenStore.accessToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          _log('→ ${options.method} ${options.uri}');
          if (options.data != null) {
            _log('  body: ${_redact(options.data, request: true)}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          _log(
            '← ${response.statusCode} ${response.requestOptions.uri}\n'
            '  ${_redact(response.data)}',
          );
          handler.next(response);
        },
        onError: (e, handler) {
          _log(
            '✖ ${e.type.name} ${e.requestOptions.uri}\n'
            '  status: ${e.response?.statusCode}\n'
            '  message: ${e.message}\n'
            '  body: ${_redact(e.response?.data)}',
          );
          // 저장된 토큰이 만료·폐기됐다는 뜻이므로 세션을 비운다.
          // 화면 전환은 앱 쪽에서 [onUnauthorized] 로 처리한다.
          if (e.response?.statusCode == 401 && AuthTokenStore.hasSession) {
            _log('401 — 저장된 세션을 정리한다.');
            // 인터셉터는 동기라 기다릴 수 없다. 실패해도 이후 복원은
            // AuthTokenStore 가 차단하므로 로그만 남기고 넘어간다.
            unawaited(
              AuthTokenStore.clear().catchError(
                (Object e) => _log('세션 삭제 실패(복원은 차단됨): $e'),
              ),
            );
            onUnauthorized?.call();
          }
          handler.next(e);
        },
      ),
    );
  }

  final Dio _dio;

  /// 401 로 세션이 무효해졌을 때 앱이 로그인 화면으로 보낼 수 있게 두는 훅.
  static void Function()? onUnauthorized;

  /// 디버그 빌드에서만 콘솔에 남긴다. 릴리스에서는 토큰·응답 본문이 새지 않도록 조용히 넘어간다.
  static void _log(String message) {
    if (kDebugMode) debugPrint('[API] $message');
  }

  /// 요청·응답 양쪽에서 항상 가리는 키.
  ///
  /// 디버그 빌드의 콘솔·Xcode 로그는 파일로 남고 공유되기 쉬워서, 비밀번호와
  /// 토큰이 그대로 찍히면 그 자체가 유출 경로가 된다.
  static const _secretKeys = <String>{
    'pw',
    'newPw',
    'currentPw',
    'password',
    'accessToken',
    'refreshToken',
    'oauthToken',
  };

  /// **요청 바디에서만** 가리는 키.
  ///
  /// `code` 는 요청에서는 이메일 인증번호지만 응답 봉투에서는 에러 코드
  /// (`WEATHER_FETCH_FAILED` 등)다. 응답까지 가리면 로그로 원인을 못 찾는다.
  static const _requestOnlySecretKeys = <String>{'code', 'verifyCode'};

  /// 민감한 값을 `***` 로 바꾼 사본을 돌려준다. 중첩된 Map/List 도 따라 들어간다.
  ///
  /// [request] 가 true 면 [_requestOnlySecretKeys] 까지 함께 가린다.
  static Object? _redact(Object? value, {bool request = false}) {
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key:
              _secretKeys.contains('${entry.key}') ||
                  (request && _requestOnlySecretKeys.contains('${entry.key}'))
              ? '***'
              : _redact(entry.value, request: request),
      };
    }
    if (value is List) {
      return value.map((e) => _redact(e, request: request)).toList();
    }
    return value;
  }

  static String get _defaultBaseUrl => ApiEndpoints.baseUrl;

  /// `data` 를 [parse] 로 파싱해 돌려준다. `data` 가 없으면(예: 명세 오류) 실패로 취급한다.
  Future<T> requestObject<T>(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    required T Function(Map<String, dynamic> data) parse,
  }) async {
    final json = await _send(method, path, query: query, body: body);
    final response = ApiResponse<T>.fromJson(json, parse);
    if (!response.success) throw ApiException(_errorOf(response));
    if (!response.hasData) {
      throw ApiException(ApiError.local(ApiErrorCode.unknown));
    }
    return response.data as T;
  }

  /// `data` 의 [listKey] 배열을 [parse] 로 파싱해 리스트로 돌려준다.
  Future<List<T>> requestList<T>(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    required String listKey,
    required T Function(Map<String, dynamic> json) parse,
  }) async {
    final json = await _send(method, path, query: query, body: body);
    if (!asBool(json['success'])) {
      throw ApiException(_errorFrom(json));
    }
    final data = asMap(json['data']);
    return asModelList(data[listKey], parse);
  }

  /// [requestList] 와 같지만 `data.pagination` 까지 함께 돌려준다.
  Future<Paged<T>> requestPaged<T>(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    required String listKey,
    required T Function(Map<String, dynamic> json) parse,
  }) async {
    final json = await _send(method, path, query: query, body: body);
    if (!asBool(json['success'])) {
      throw ApiException(_errorFrom(json));
    }
    final data = asMap(json['data']);
    return Paged(
      items: asModelList(data[listKey], parse),
      pagination: data['pagination'] == null
          ? Pagination.first
          : Pagination.fromJson(asMap(data['pagination'])),
    );
  }

  /// 응답 `data` 를 그대로 쓰지 않는 호출(로그아웃 등)에 사용한다.
  Future<void> requestVoid(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    Map<String, String>? headers,
  }) async {
    final json = await _send(
      method,
      path,
      query: query,
      body: body,
      headers: headers,
    );
    if (!asBool(json['success'])) {
      throw ApiException(_errorFrom(json));
    }
  }

  ApiError _errorOf(ApiResponse<Object?> response) {
    final error = response.error ?? ApiError.local(ApiErrorCode.unknown);
    _log('서버 오류 응답: $error');
    return error;
  }

  ApiError _errorFrom(Map<String, dynamic> json) {
    final error = json['error'] == null
        ? ApiError.local(ApiErrorCode.unknown)
        : ApiError.fromJson(asMap(json['error']));
    _log('서버 오류 응답: $error');
    return error;
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.request<dynamic>(
        path,
        queryParameters: query,
        data: body,
        options: Options(method: method, headers: headers),
      );
      return asMap(response.data);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map) return asMap(data);
      throw ApiException(_mapDioError(e));
    }
  }

  ApiError _mapDioError(DioException e) {
    _log('통신 실패 → ${e.type.name}: ${e.error ?? e.message}');
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return ApiError.local(ApiErrorCode.network, '네트워크 연결을 확인해주세요.');
      default:
        return ApiError.local(ApiErrorCode.unknown, e.message);
    }
  }
}

final apiClient = ApiClient();
