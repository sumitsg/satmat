import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newapp/models/user_model.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _firebaseUser;
  UserModel? _userModel;
  UserModel? get userModel => _userModel;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    _firebaseUser = firebaseUser;
    await _loadUserModel();
    notifyListeners();
  }

  Future<void> _loadUserModel() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_firebaseUser?.uid)
        .get();
    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      _userModel = UserModel.fromDocumentSnapshot(userData, _firebaseUser!.uid);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required String mobileNumber,
    required String address,
    required String profileImageUrl,
  }) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    _firebaseUser = userCredential.user;
    _userModel = UserModel(
      uid: _firebaseUser!.uid,
      username: username,
      email: email,
      mobileNumber: mobileNumber,
      address: address,
      profileImageUrl: profileImageUrl,
    );
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_firebaseUser!.uid)
        .set(_userModel!.toMap());

    notifyListeners();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await _auth.signOut();
    _firebaseUser = null;
    _userModel = null;
    notifyListeners();
  }
}
