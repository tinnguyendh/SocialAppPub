import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:insta2/models/user.dart' as model;
import 'package:flutter/material.dart';
import 'package:insta2/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get user details
  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(documentSnapshot);
  }

  // Signing Up User

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
    required bool gender,
    required String country,
    required String role


  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty ||
              password.isNotEmpty ||
              username.isNotEmpty ||
              bio.isNotEmpty
          // ||file != null
          ) {
        // registering user in auth with email and password
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        User? userin = cred.user;
        await userin!.reload();
        userin = await _auth.currentUser;

        userin!.updateDisplayName(username);

        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file, false);
        userin.updatePhotoURL(photoUrl);

        model.User user = model.User(
          username: username,
          uid: cred.user!.uid,
          photoUrl: photoUrl,
          email: email,
          bio: bio,
          followers: [],
          following: [],
          gender: gender,
          country: country,
          likedPost: [],
          role: role,
        );

        // adding user in our database
        await _firestore.collection("users").doc(cred.user!.uid).set(
              //   {
              //   "username": username,
              //   "uid": cred.user!.uid,
              //   "email": email,
              //   "bio": bio,
              //   "followers": [],
              //   "following": [],
              //   "photoUrl": photoUrl,
              // }
              user.toJson(),
            );



        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  // logging in user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        // logging in user with email and password
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      return authResult.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> googleSignOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    String res = "Some error Occurred";
    try {
      User currentUser = _auth.currentUser!;

      // Xác thực người dùng với mật khẩu hiện tại
      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser.email!,
        password: currentPassword,
      );

      await currentUser.reauthenticateWithCredential(credential);

      // Cập nhật mật khẩu mới cho người dùng
      await currentUser.updatePassword(newPassword);

      res = "success";
    } catch (err) {
      return err.toString();
    }
    return res;
  }
}
