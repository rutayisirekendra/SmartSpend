import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 4)
class Category extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String icon; // Storing icon codepoint as a string for simplicity

  @HiveField(3)
  int color; // NEW: Store Color.value

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  Category copyWith({
    String? id,
    String? name,
    String? icon,
    int? color,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }
}