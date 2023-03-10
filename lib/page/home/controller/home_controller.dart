import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {



  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;


  Stream<DocumentSnapshot<Map<String, dynamic>>> streamHome() async* {
    String uid = await auth.currentUser!.uid;
    yield* firestore.collection('user').doc(uid).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getKehadiran() async* {
    String uid = await auth.currentUser!.uid;
    yield* firestore
        .collection('user')
        .doc(uid)
        .collection('kehadiran').orderBy('date')
        .snapshots();
  }
  Stream<QuerySnapshot<Map<String, dynamic>>> getIzin() async* {
    String uid = await auth.currentUser!.uid;
    yield* firestore
        .collection('user')
        .doc(uid)
        .collection('izin')
        .snapshots();
  }
}
