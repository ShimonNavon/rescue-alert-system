import 'package:json_annotation/json_annotation.dart';

part 'identity_user_data.g.dart';

@JsonSerializable(explicitToJson: true)
class IdentityUserData {
  final String email;
  final String accessToken;
  final bool activeBillingAccount;
  final bool isAdmin;

  IdentityUserData({
    required this.email,
    required this.accessToken,
    required this.activeBillingAccount,
    required this.isAdmin,
  });

  IdentityUserData copyWith({
    String? email,
    String? accessToken,
    bool? activeBillingAccount,
    bool? isAdmin,
  }) {
    return IdentityUserData(
      email: email ?? this.email,
      accessToken: accessToken ?? this.accessToken,
      activeBillingAccount: activeBillingAccount ?? this.activeBillingAccount,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  String? get bearer => (accessToken.isNotEmpty) ? 'Bearer $accessToken' : null;

  factory IdentityUserData.fromJson(Map<String, dynamic> json) =>
      _$IdentityUserDataFromJson(json);

  Map<String, dynamic> toJson() => _$IdentityUserDataToJson(this);
}
