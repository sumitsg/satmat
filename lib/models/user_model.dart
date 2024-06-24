class UserModel {
  String uid;
  String username;
  String email;
  String mobileNumber;
  String address;
  String profileImageUrl;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.mobileNumber,
    required this.address,
    required this.profileImageUrl,
  });

  factory UserModel.fromDocumentSnapshot(Map<String, dynamic> doc, String uid) {
    return UserModel(
      uid: uid,
      username: doc['username'],
      email: doc['email'],
      mobileNumber: doc['mobileNumber'],
      address: doc['address'],
      profileImageUrl: doc['profileImageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'mobileNumber': mobileNumber,
      'address': address,
      'profileImageUrl': profileImageUrl,
    };
  }
}
