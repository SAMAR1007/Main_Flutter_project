import 'package:hive/hive.dart';

class User {
  String name;
  String email;
  String phone;
  String password;

  User({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
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
    return User(name: name, email: email, phone: phone, password: password);
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer.writeString(obj.name);
    writer.writeString(obj.email);
    writer.writeString(obj.phone);
    writer.writeString(obj.password);
  }
}
