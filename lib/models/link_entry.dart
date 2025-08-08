import 'package:hive/hive.dart';

part 'link_entry.g.dart';

@HiveType(typeId: 1)
class LinkEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String url;

  @HiveField(4)
  String category;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  @HiveField(7)
  bool isFavorite;

  @HiveField(8)
  bool isBookmarked;

  LinkEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    this.category = 'General',
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.isBookmarked = false,
  });

  LinkEntry copyWith({
    String? id,
    String? title,
    String? description,
    String? url,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    bool? isBookmarked,
  }) {
    return LinkEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'url': url,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFavorite': isFavorite,
      'isBookmarked': isBookmarked,
    };
  }

  factory LinkEntry.fromJson(Map<String, dynamic> json) {
    return LinkEntry(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      url: json['url'],
      category: json['category'] ?? 'General',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isFavorite: json['isFavorite'] ?? false,
      isBookmarked: json['isBookmarked'] ?? false,
    );
  }
} 