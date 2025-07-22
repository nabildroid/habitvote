import 'package:equatable/equatable.dart';
import 'package:habitvote/features/user/data/models/access_token_model.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

final class UserClaimsModel extends Equatable {
  const UserClaimsModel({
    this.premiumExpires,
  });

  final DateTime? premiumExpires;

  bool get isPremium =>
      premiumExpires != null && DateTime.now().isBefore(premiumExpires!);

  bool get isTrulyPremium =>
      isPremium && premiumExpires!.difference(DateTime.now()).inDays < 1000;

  Map<String, dynamic> toJson() {
    return {
      "premiumExpires": isPremium ? premiumExpires!.toIso8601String() : null,
    };
  }

  factory UserClaimsModel.fromJson(Map<String, dynamic> data) {
    return UserClaimsModel(
      premiumExpires: data['premiumExpires'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              int.parse(data['premiumExpires'].toString()))
          : null,
    );
  }

  @override
  List<Object?> get props => [premiumExpires];
}

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final UserClaimsModel claims;

  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.createdAt,
    this.photoURL,
    this.displayName = 'User',
    required this.claims,
    required this.email,
  });

  // from json
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      createdAt: DateTime.parse(json['createdAt']),
      displayName: json['displayName'] ?? 'User',
      photoURL: json['photoURL'],
      claims: UserClaimsModel.fromJson(json['claims'] ?? {}),
      email: json['email'] ?? '',
    );
  }

  factory UserModel.fromAccessToken(AccessTokenModel accessToken) {
    final token = accessToken.token;
    final Map<String, dynamic> data = JwtDecoder.decode(token);
    return UserModel.fromJson(data);
  }

  UserModel makeItPro() {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      createdAt: createdAt,
      claims: UserClaimsModel(
        premiumExpires: DateTime.now().add(const Duration(days: 30)),
      ),
    );
  }

  Duration get accountAge {
    return DateTime.now().difference(createdAt);
  }

  @override
  List<Object?> get props => [uid, email, displayName, createdAt, claims];
}
