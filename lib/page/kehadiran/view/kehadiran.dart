import 'dart:io';

import 'package:absen_try_app/page/camera/camera_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/kehadiran_controller.dart';

class KehadiranView extends GetView<KehadiranController> {
  const KehadiranView({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(KehadiranController());

    return Scaffold(
        appBar: AppBar(
          title: Text('Kehadiran'),
          leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(Icons.arrow_back_ios_new)),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
          child: ListView(
            children: [
              SizedBox(
                height: 50,
              ),
              GetBuilder<KehadiranController>(builder: (c2) {
                return Row(
                  children: [
                    Text(
                      c2.pilihan == null ? 'Pilih Absen' : '${c2.pilihan}',
                      style: TextStyle(
                          color: c2.pilihan == null
                              ? Colors.white
                              : c2.pilihan == 'Masuk'
                                  ? Colors.greenAccent
                                  : Colors.redAccent),
                    ),
                    PopupMenuButton(
                      icon: Icon(Icons.arrow_drop_down),
                      onSelected: (value) {
                        controller.isPilihan(value);
                      },
                      itemBuilder: (context) {
                        return controller.itemAbsenLog
                            .map<PopupMenuItem>((String e) =>
                                PopupMenuItem(value: e, child: Text(e)))
                            .toList();
                      },
                    )
                  ],
                );
              }),
              SizedBox(
                height: 20,
              ),
              GetBuilder<KehadiranController>(builder: (c) {
                if (c.photo != null) {
                  return Container(
                      height: 250,
                      width: double.infinity,
                      child: Image.file(
                        c.finalImage,
                        fit: BoxFit.cover,
                      ));
                } else {
                  return Container(height: 250, color: Colors.grey[800]);
                }
              }),
              ElevatedButton(
                onPressed: () {
                  // Get.to(CameraPage());
                  // controller.takePicture(context);
                  controller.picImage();
                  // controller.drawTextOnImage();
                },
                child: Text('Ambil Gambar'),
              ),
              TextField(
                controller: controller.placeC,
                decoration: InputDecoration(
                    hintText: 'Nama Tempat Kunjungan',
                    border: OutlineInputBorder()),
              ),
              SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: () {
                  controller.isAbsen();
                },
                child: Text('Absen Sekarang'),
              ),
            ],
          ),
        ));
  }
}
