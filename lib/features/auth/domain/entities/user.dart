import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String phoneNumber;
  final String? name;
  final String? email;
  final String? photoUrl;
  final bool isVerified;
  final double? creditLimit;
  final double? usedLimit; // Used credit limit
  final DateTime? limitExpiryDate;

  const User({
    required this.id,
    required this.phoneNumber,
    this.name,
    this.email,
    this.photoUrl,
    this.isVerified = false,
    this.creditLimit,
    this.usedLimit = 0.0,
    this.limitExpiryDate,
  });
  
  double get availableLimit => (creditLimit ?? 0.0) - (usedLimit ?? 0.0);

  User copyWith({
    String? id,
    String? phoneNumber,
    String? name,
    String? email,
    String? photoUrl,
    bool? isVerified,
    double? creditLimit,
    double? usedLimit,
    DateTime? limitExpiryDate,
  }) {
    return User(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isVerified: isVerified ?? this.isVerified,
      creditLimit: creditLimit ?? this.creditLimit,
      usedLimit: usedLimit ?? this.usedLimit,
      limitExpiryDate: limitExpiryDate ?? this.limitExpiryDate,
    );
  }

  @override
  List<Object?> get props => [id, phoneNumber, name, email, photoUrl, isVerified, creditLimit, usedLimit, limitExpiryDate];
}
