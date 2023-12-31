import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class StoreImage {
  Future<String> uploadImageToStorage(
      String uid, String childName, Uint8List file) async {
    Reference ref =
        _storage.ref().child('profileImages').child(uid).child(childName);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> saveData(
      {required String uid,
      required String imageName,
      required Uint8List file}) async {
    String imageUrl = await uploadImageToStorage(uid, imageName, file);
    return imageUrl;
  }
}
