import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthProvider with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;

  User? _user;
  User? get user => _user;

  AuthProvider() {
    _user = _auth.currentUser;
    if (_user != null) {
      _loadUserData();
    }
  }

  Future<void> checkLoginStatus() async {
    _user = _auth.currentUser;
    if (_user != null) {
      await _loadUserData();
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      _user = userCredential.user;
      await _loadUserData();
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> signup(String email, String username, String mobile,
      String address, String password, String imageUrl) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      _user = userCredential.user;

      await _firestore.collection('users').doc(_user!.uid).set({
        'username': username,
        'mobile': mobile,
        'address': address,
        'email': email,
        'imageUrl': imageUrl,
      });

      await _loadUserData();
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> _loadUserData() async {
    if (_user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(_user!.uid).get();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('username', userDoc['username']);
      prefs.setString('mobile', userDoc['mobile']);
      prefs.setString('address', userDoc['address']);
      prefs.setString('email', userDoc['email']);
      prefs.setString('imageUrl', userDoc['imageUrl']);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
