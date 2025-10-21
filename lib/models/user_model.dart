import 'package:hive/hive.dart';

// FIX: This line is essential for the build_runner to work correctly.
part 'user_model.g.dart';

@HiveType(typeId: 3)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String email;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
  });
}



