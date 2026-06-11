// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity_user_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IdentityUserData _$IdentityUserDataFromJson(Map<String, dynamic> json) =>
    IdentityUserData(
      email: json['email'] as String,
      accessToken: json['accessToken'] as String,
      activeBillingAccount: json['activeBillingAccount'] as bool,
      isAdmin: json['isAdmin'] as bool,
    );

Map<String, dynamic> _$IdentityUserDataToJson(IdentityUserData instance) =>
    <String, dynamic>{
      'email': instance.email,
      'accessToken': instance.accessToken,
      'activeBillingAccount': instance.activeBillingAccount,
      'isAdmin': instance.isAdmin,
    };
