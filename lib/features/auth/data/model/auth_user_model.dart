import 'package:equatable/equatable.dart';

class AuthUserModel extends Equatable {
  const AuthUserModel({
    required this.uid,
    required this.email,
    required this.providerIds,
    required this.isEmailVerified,
    this.displayName,
    this.photoUrl,
  });

  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final List<String> providerIds;
  final bool isEmailVerified;

  @override
  List<Object?> get props => [
    uid,
    email,
    displayName,
    photoUrl,
    providerIds,
    isEmailVerified,
  ];
}
