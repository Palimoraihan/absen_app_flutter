import 'dart:io';

import 'package:absen_try_app/page/home/view/home.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as s;
import 'package:intl/intl.dart';

class IzinController extends GetxController {
  TextEditingController controllerDesc = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  final storage = s.FirebaseStorage.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  File? file;
  String? fileName;

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      file = File(result.files.single.path!);
      fileName = result.files.single.name;
      print(fileName);
      update();
    } else {
      print('error');
    }
  }

  void isIzin() async {
    print('Absen');
    Map<String, dynamic> dataResponse = await determinePosition();

    if (file != null) {
      if (dataResponse['error'] != true) {
        Position position = dataResponse['position'];
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);

        String addres =
            '${placemarks[0].thoroughfare}, ${placemarks[0].subLocality}';
        await updatePosition(position, addres);
        print('$addres');
        // double jarak = Geolocator.distanceBetween(
        //     -6.1636573, 106.8922156, position.latitude, position.longitude);
        // print(jarak);
        await present(position, addres);

        print('${position.latitude},${position.longitude}');
      } else {
        Get.snackbar('Eror', dataResponse['message']);
      }
    } else {
      Get.snackbar('Error', 'file belum di upload');
    }

    update();
  }

  Future<dynamic> present(Position position, String addres) async {
    String uid = await auth.currentUser!.uid;
    CollectionReference<Map<String, dynamic>> colKehadiran =
        await firestore.collection('user').doc(uid).collection('izin');

    // QuerySnapshot<Map<String, dynamic>> getKehadiran = await colKehadiran.get();

    DateTime now = DateTime.now();
    print(DateFormat.yMd().format(now));
    // String getTodayID = DateFormat.yMd().format(now).replaceAll('/', '-');

    // String statusLoc = 'Di Luar Qtera';

    // if (jaralk <= 200) {
    //   statusLoc = 'Di Qtera';
    // }

    await storage.ref('$fileName').putFile(file!);
    String filePDF = await storage.ref('$fileName').getDownloadURL();

    await colKehadiran.doc().set({
      'date': now.toIso8601String(),
      'lat': position.latitude,
      'long': position.longitude,
      'description': controllerDesc.text,
      'address': addres,
      'nameFile': fileName,
      'file': filePDF,
    });
    Get.snackbar('Berhasi Masuk', 'Anda berhasil absen Masuk');
    Get.to(HomeView());
  }

  Future<Map<String, dynamic>> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      // return Future.error('Location services are disabled.');
      return {
        'message': 'Tidak di dapat untuk mengambil GPS dari devaces ini',
        'error': true,
      };
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        // return Future.error('Location permissions are denied');
        return {
          'message': 'Izin di tolak',
          'error': true,
        };
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return {
        'message': 'Tidak di izinkam untuk mangakses gps',
        'error': true,
      };
      // return Future.error(
      //     'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition();
    return {
      'position': position,
      'message': 'berhasil mendapatkan posisi',
      'error': false,
    };
  }

  Future<dynamic> updatePosition(Position position, String addres) async {
    String uid = await auth.currentUser!.uid;
    await firestore.collection('user').doc(uid).update({
      'position': {
        'lat': position.latitude,
        'long': position.longitude,
      },
      'address': addres
    });
  }
  
}
