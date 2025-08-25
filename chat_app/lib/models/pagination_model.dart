class PaginationModel {
  final int page;
  final int limit;
  final int totalChats;
  final int totalPages;

  const PaginationModel({
    required this.page,
    required this.limit,
    required this.totalChats,
    required this.totalPages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      totalChats: (json['totalChats'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'totalChats': totalChats,
      'totalPages': totalPages,
    };
  }

  PaginationModel copyWith({
    int? page,
    int? limit,
    int? totalChats,
    int? totalPages,
  }) {
    return PaginationModel(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      totalChats: totalChats ?? this.totalChats,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaginationModel &&
        other.page == page &&
        other.limit == limit &&
        other.totalChats == totalChats &&
        other.totalPages == totalPages;
  }

  @override
  int get hashCode {
    return Object.hash(page, limit, totalChats, totalPages);
  }

  @override
  String toString() {
    return 'PaginationModel(page: $page, limit: $limit, totalChats: $totalChats, totalPages: $totalPages)';
  }
}