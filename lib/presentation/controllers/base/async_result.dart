import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/data/models/models.dart';

/// [AsyncValue] 안의 에러를 [ApiError] 로 바로 꺼내 쓰기 위한 확장.
///
/// 컨트롤러의 각 async 필드는 `AsyncValue<T>?` 로 선언한다 — `null` 이면
/// 아직 한 번도 불러오지 않은 상태(구 `AsyncState.isIdle`), non-null 이면
/// loading/data/error 중 하나다.
extension AsyncValueApiErrorX<T> on AsyncValue<T> {
  ApiError? get apiError {
    final err = error;
    return err is ApiError ? err : null;
  }
}

/// [task] 를 실행해 성공하면 [AsyncData], 실패하면 [AsyncError] 로 감싼다.
/// 구 `AsyncState.load()` 의 try/catch 를 함수 하나로 재사용한다.
Future<AsyncValue<T>> guardAsync<T>(Future<T> Function() task) async {
  try {
    return AsyncData<T>(await task());
  } on ApiException catch (e) {
    return AsyncError<T>(e.error, StackTrace.current);
  } catch (e, st) {
    return AsyncError<T>(
      ApiError.local(ApiErrorCode.unknown, e.toString()),
      st,
    );
  }
}
