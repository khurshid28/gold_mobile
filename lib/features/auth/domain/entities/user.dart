import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String phoneNumber;
  final String? name;
  final String? email;
  final String? photoUrl;

  const User({
    required this.id,
    required this.phoneNumber,
    this.name,
    this.email,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [id, phoneNumber, name, email, photoUrl];
}
