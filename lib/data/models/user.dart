import 'package:hive/hive.dart';

class User {
  String name;
  String email;
  String phone;
  String password;
  String? profilePicture;

  User({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    this.profilePicture,
  });
}

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final name = reader.readString();
    final email = reader.readString();
    final phone = reader.readString();
    final password = reader.readString();
    final profilePicture = reader.readString();
    return User(
      name: name,
      email: email,
      phone: phone,
      password: password,
      profilePicture: profilePicture.isEmpty ? null : profilePicture,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer.writeString(obj.name);
    writer.writeString(obj.email);
    writer.writeString(obj.phone);
    writer.writeString(obj.password);
    writer.writeString(obj.profilePicture ?? '');
  }
}
