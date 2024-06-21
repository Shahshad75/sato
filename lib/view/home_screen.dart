import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sato/controller/home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController controller = Get.put(HomeController());
  @override
  void initState() {
    controller.loadImage();
    controller.handleSharedImage();
    HomeController.platform.setMethodCallHandler((call) async {
      if (call.method == "newIntent") {
        await controller.handleSharedImage();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    controller.image = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: const Text(
          "Sato",
          style: TextStyle(color: Color.fromARGB(255, 89, 89, 89)),
        ),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: ListView(
            children: [
              GetBuilder<HomeController>(builder: (controller) {
                return controller.image == null
                    ? Container(
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(221, 187, 187, 187),
                            borderRadius: BorderRadius.circular(30)),
                        width: double.infinity,
                        height: 200,
                        child: controller.image != null
                            ? TextButton(
                                onPressed: () {
                                  controller.removeImage();
                                },
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.red),
                                ))
                            : const Center(
                                child: Text("Upload image now"),
                              ),
                      )
                    : Container(
                        alignment: Alignment.topRight,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: FileImage(controller.image!)),
                            // color: const Color.fromARGB(221, 116, 116, 116),
                            borderRadius: BorderRadius.circular(30)),
                        width: double.infinity,
                        height: 200,
                        child: TextButton(
                            onPressed: () {
                              controller.removeImage();
                            },
                            child: const Text(
                              "Delete",
                              style: TextStyle(color: Colors.red),
                            )),
                      );
              }),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    await controller.imagepicked(ImageSource.gallery);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black, // Text color
                  ),
                  child: const Text("Upload"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
