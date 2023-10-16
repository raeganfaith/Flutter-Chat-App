import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  //instance of auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  //instance of firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // sign in user
  Future<UserCredential> signInWithEmailandPassword(
      String email, String password) async {
    try {
      //sign in
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      //add a new document for the user in users collection if it doesn't already exist
      _fireStore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
      }, SetOptions(merge: true));

      return userCredential;
    }
    //catch errors
    on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // create a new user
  Future<UserCredential> signUpWithEmailandPassword(
      String email, password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> updateProfile(String username, String newPassword) async {
    User? user = _firebaseAuth.currentUser;
    try {
      if (user != null) {
        // Update username in Firestore
        await _fireStore.collection('users').doc(user.uid).update({
          'username': username,
        });

        // Update password in Firebase Authentication
        if (newPassword.isNotEmpty) {
          await user.updatePassword(newPassword);
        }

        // Reload user to reflect changes
        await user.reload();
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> updatePasswordOnly(String newPassword) async {
    try {
      await FirebaseAuth.instance.currentUser!.updatePassword(newPassword);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  //sign out user
  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }
}
