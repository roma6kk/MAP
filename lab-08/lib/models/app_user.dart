import 'package:hive/hive.dart';

enum UserRole { admin, manager, user }

class AppUser {
  AppUser({required this.id, required this.name, required this.role});

  final String id;
  final String name;
  final UserRole role;

  bool get canEdit => role != UserRole.user;
}

class AppUserAdapter extends TypeAdapter<AppUser> {
  @override
  final int typeId = 1;

  @override
  AppUser read(BinaryReader r) =>
      AppUser(id: r.readString(), name: r.readString(), role: UserRole.values[r.readByte()]);

  @override
  void write(BinaryWriter w, AppUser u) {
    w
      ..writeString(u.id)
      ..writeString(u.name)
      ..writeByte(u.role.index);
  }
}
