class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.roles,
    required this.isActive,
    required this.createdAt,
    required this.baseCurrency,
  });

  final int id;
  final String name;
  final String email;
  final List<String> roles;
  final bool isActive;
  final String createdAt;
  final String baseCurrency;

  bool get isAdmin =>
      roles.contains('ADMIN') || roles.contains('SUPER_ADMIN');

  bool get isSuperAdmin => roles.contains('SUPER_ADMIN');

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      roles: List<String>.from(json['roles'] as List),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] as String? ?? '',
      baseCurrency: json['baseCurrency'] as String? ?? 'INR',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'roles': roles,
        'isActive': isActive,
        'createdAt': createdAt,
        'baseCurrency': baseCurrency,
      };

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    List<String>? roles,
    bool? isActive,
    String? createdAt,
    String? baseCurrency,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      roles: roles ?? this.roles,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      baseCurrency: baseCurrency ?? this.baseCurrency,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => Object.hash(id, email);

  @override
  String toString() => 'UserModel(id: $id, name: $name, email: $email)';
}
