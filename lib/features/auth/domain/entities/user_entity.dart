class UserEntity {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  @override
  String toString() => 'UserEntity(id: $id, name: $name, email: $email)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
