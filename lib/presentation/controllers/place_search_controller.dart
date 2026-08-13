import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/data/mock/mock_api.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/presentation/controllers/base/async_result.dart';

/// 통합 검색(`GET /search`) 상태.
///
/// 검색어·카테고리·지역·정렬은 화면에서 개별로 바뀌므로 각각 필드로 두고,
/// 실제 요청 직전에 [currentQuery] 로 합친다.
class PlaceSearchState {
  const PlaceSearchState({
    this.keyword = '',
    this.category,
    this.region,
    this.sort,
    this.results,
    this.recentKeywords = const <String>[],
  });

  final String keyword;
  final PlaceCategory? category;
  final String? region;
  final String? sort;

  final AsyncValue<List<SearchResultItem>>? results;

  /// 최근 검색어(로컬 유지, 서버 명세 없음).
  final List<String> recentKeywords;

  SearchQuery get currentQuery => SearchQuery(
    keyword: keyword.trim().isEmpty ? null : keyword.trim(),
    category: category,
    region: region,
    sort: sort,
  );

  bool get hasFilter => category != null || region != null || sort != null;
}

class PlaceSearchNotifier extends Notifier<PlaceSearchState> {
  @override
  PlaceSearchState build() => const PlaceSearchState();

  void setKeyword(String value) {
    state = PlaceSearchState(
      keyword: value,
      category: state.category,
      region: state.region,
      sort: state.sort,
      results: state.results,
      recentKeywords: state.recentKeywords,
    );
  }

  /// 같은 카테고리를 다시 누르면 해제한다.
  void toggleCategory(PlaceCategory value) {
    state = PlaceSearchState(
      keyword: state.keyword,
      category: state.category == value ? null : value,
      region: state.region,
      sort: state.sort,
      results: state.results,
      recentKeywords: state.recentKeywords,
    );
  }

  void setRegion(String? value) {
    state = PlaceSearchState(
      keyword: state.keyword,
      category: state.category,
      region: value,
      sort: state.sort,
      results: state.results,
      recentKeywords: state.recentKeywords,
    );
  }

  void setSort(String? value) {
    state = PlaceSearchState(
      keyword: state.keyword,
      category: state.category,
      region: state.region,
      sort: value,
      results: state.results,
      recentKeywords: state.recentKeywords,
    );
  }

  void clearFilters() {
    state = PlaceSearchState(
      keyword: state.keyword,
      results: state.results,
      recentKeywords: state.recentKeywords,
    );
  }

  Future<void> search() async {
    final query = state.currentQuery;
    if (query.keyword != null) _rememberKeyword(query.keyword!);
    state = PlaceSearchState(
      keyword: state.keyword,
      category: state.category,
      region: state.region,
      sort: state.sort,
      results: const AsyncLoading(),
      recentKeywords: state.recentKeywords,
    );
    final result = await guardAsync(() => mockApi.search(query));
    state = PlaceSearchState(
      keyword: state.keyword,
      category: state.category,
      region: state.region,
      sort: state.sort,
      results: result,
      recentKeywords: state.recentKeywords,
    );
  }

  void clear() {
    state = const PlaceSearchState();
  }

  void _rememberKeyword(String value) {
    final keywords = [...state.recentKeywords];
    keywords.remove(value);
    keywords.insert(0, value);
    if (keywords.length > 10) keywords.removeLast();
    state = PlaceSearchState(
      keyword: state.keyword,
      category: state.category,
      region: state.region,
      sort: state.sort,
      results: state.results,
      recentKeywords: keywords,
    );
  }

  void removeRecentKeyword(String value) {
    final keywords = [...state.recentKeywords]..remove(value);
    state = PlaceSearchState(
      keyword: state.keyword,
      category: state.category,
      region: state.region,
      sort: state.sort,
      results: state.results,
      recentKeywords: keywords,
    );
  }

  void clearRecentKeywords() {
    state = PlaceSearchState(
      keyword: state.keyword,
      category: state.category,
      region: state.region,
      sort: state.sort,
      results: state.results,
    );
  }
}

final placeSearchProvider =
    NotifierProvider<PlaceSearchNotifier, PlaceSearchState>(
      PlaceSearchNotifier.new,
    );
