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

  Category({
    required this.id,
    required this.name,
    required this.icon,
  });
}
