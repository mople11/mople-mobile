import 'package:mople_mobile/data/models/common/json_utils.dart';

/// 목록 응답이 `data.pagination` 으로 함께 내려주는 페이지 정보.
///
/// `/search`, `/reviews`, `/users/me/courses`, `/users/me/likes`,
/// `/users/me/reviews` 다섯 곳이 동일한 형태를 쓴다.
class Pagination {
  const Pagination({
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  /// 다음 페이지가 남아 있는지. 무한 스크롤에서 추가 요청 여부를 판단한다.
  bool get hasMore => page < totalPages;

  int get nextPage => page + 1;

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    page: asInt(json['page'], 1),
    pageSize: asInt(json['pageSize']),
    totalCount: asInt(json['totalCount']),
    totalPages: asInt(json['totalPages']),
  );

  static const first = Pagination(
    page: 1,
    pageSize: 0,
    totalCount: 0,
    totalPages: 1,
  );
}

/// 목록 + 페이지 정보를 함께 담는 응답 래퍼.
class Paged<T> {
  const Paged({required this.items, required this.pagination});

  final List<T> items;
  final Pagination pagination;

  bool get hasMore => pagination.hasMore;

  bool get isEmpty => items.isEmpty;

  /// 다음 페이지 결과를 뒤에 이어 붙인다(무한 스크롤).
  Paged<T> append(Paged<T> next) =>
      Paged(items: [...items, ...next.items], pagination: next.pagination);

  static Paged<T> empty<T>() =>
      Paged<T>(items: const [], pagination: Pagination.first);
}

/// 페이지 요청 파라미터. null 이면 서버 기본값을 쓴다.
class PageQuery {
  const PageQuery({this.page, this.pageSize});

  final int? page;
  final int? pageSize;

  Map<String, dynamic> toJson() =>
      compactJson({'page': page, 'pageSize': pageSize});

  static const first = PageQuery(page: 1);
}
