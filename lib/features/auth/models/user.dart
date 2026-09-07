import 'package:eClassify/features/auth/models/auth_provider.dart';
import 'package:eClassify/core/models/contact.dart';
import 'package:eClassify/core/models/user_placeholder.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/utils/json_helper.dart';

class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.contact = const Contact(),
    this.profile,
    this.placeholder,
    this.address,
    this.fcmId,
    this.authProvider,
    required this.showPersonalDetails,
    required this.notificationsEnabled,
    required this.isVerified,
  });

  User.fromJson(Json json)
    : id = json['id'] as int,
      name = json['name'] as String,
      email = json['email'] as String,
      contact = Contact.fromJson(json),
      profile = json['profile'] as String?,
      placeholder = UserPlaceholder.fromJson(json),
      address = json['address'] as String?,
      fcmId = json['fcm_id'] as String?,
      authProvider = AuthProvider.fromRaw(json['type'] as String?),
      showPersonalDetails = (json['show_personal_details'] as int?) == 1,
      notificationsEnabled = (json['notification'] as int?) == 1,
      isVerified = (json['is_verified'] as int?) == 1;

  final int id;
  final String name;
  final String email;
  final Contact contact;
  final String? profile;
  final UserPlaceholder? placeholder;
  final String? address;
  final String? fcmId;
  final AuthProvider? authProvider;
  final bool showPersonalDetails;
  final bool notificationsEnabled;
  final bool isVerified;

  bool get isProfileComplete =>
      name.isNotNullAndNotEmpty && email.isNotNullAndNotEmpty;

  User copyWith({
    String? name,
    String? email,
    Contact? contact,
    String? address,
    bool? showPersonalDetails,
    bool? notificationsEnabled,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      contact: contact ?? this.contact,
      profile: profile,
      placeholder: placeholder,
      address: address ?? this.address,
      fcmId: fcmId,
      authProvider: authProvider,
      showPersonalDetails: showPersonalDetails ?? this.showPersonalDetails,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isVerified: isVerified,
    );
  }

  Json toJson() => {
    'id': id,
    'name': name,
    'email': email,
    ...contact.toJson(),
    'profile': profile,
    ...?placeholder?.toJson(),
    'address': address,
    'fcm_id': fcmId,
    'type': authProvider?.raw,
    'show_personal_details': showPersonalDetails ? 1 : 0,
    'notification': notificationsEnabled ? 1 : 0,
    'is_verified': isVerified ? 1 : 0,
  };
}
