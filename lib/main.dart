// ignore_for_file: deprecated_member_use, depend_on_referenced_packages, use_build_context_synchronously
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

void main() async => runMain();

Future<void> runMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const My());
  FlutterImageCompress.showNativeLog = true;
}

class My extends StatelessWidget {
  const My({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyApp(),
      debugShowCheckedModeBanner: false,
      routes: {MyApp.id: (context) => const MyApp()},
    );
  }
}

class MyApp extends StatefulWidget {
  static const id = "/";

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final controller = TextEditingController();
  String? imagePath;
  File? resultFile;

  void compressImage() async {
    var fileFromImage = File(imagePath ?? "");
    var basename = path.basenameWithoutExtension(fileFromImage.path);
    var pathString = fileFromImage.path.split(
      path.basename(fileFromImage.path),
    )[0];

    var pathStringWithExtension = "$pathString${basename}_image.jpg";

    var result = await FlutterImageCompress.compressAndGetFile(
      imagePath ?? "",
      pathStringWithExtension,
      quality: int.parse(controller.text.trim()),
    );
    setState(() {
      resultFile = File(result!.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
          },
          icon: const Icon(Icons.refresh),
        ),
        title: const Text("Image compressor"),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (imagePath != null)
                  Text(
                    "Selected image size: ${File(imagePath ?? "").lengthSync() ~/ 1000} KB",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                if (imagePath != null)
                  Image.file(File(imagePath ?? ""), height: 300),
                if (imagePath != null) const SizedBox(height: 24),
                if (imagePath != null)
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        hintText: "Enter quality % (0-100)"),
                  ),
                if (imagePath != null) const SizedBox(height: 24),
                if (resultFile != null)
                  Text(
                    "Compressed image size:  ${resultFile!.lengthSync() ~/ 1000} KB",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                if (resultFile != null) Image.file(resultFile!, height: 300),
                if (imagePath == null)
                  ElevatedButton(
                    onPressed: () async {
                      ImagePicker imagePicker = ImagePicker();
                      final image = await imagePicker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (image != null) {
                        setState(() {
                          imagePath = image.path;
                        });
                      }
                    },
                    child: const Text(
                      "Select image",
                    ),
                  ),
                if (imagePath != null && resultFile == null)
                  ElevatedButton(
                    onPressed: () async {
                      compressImage();
                    },
                    child: const Text(
                      "Compress image",
                    ),
                  ),
                if (resultFile != null)
                  ElevatedButton(
                    onPressed: () async {
                      final data =
                          await GallerySaver.saveImage(resultFile!.path);
                      if (data != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Saving status: $data"),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "Save Image",
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
