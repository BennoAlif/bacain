import 'dart:io';
import 'package:bacain/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? imageFile;
  var isLoading = false;
  var result = 'Pilih gambar melalui galeri atau kamera';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: const Text('Bacain'),
        backgroundColor: purpleColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              imageFile == null
                  ? Container()
                  : Container(
                      child: Image.file(
                        imageFile!,
                        fit: BoxFit.fitWidth,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 3,
                            offset: const Offset(
                              0,
                              1,
                            ),
                          ),
                        ],
                      ),
                    ),
              Container(
                margin: const EdgeInsets.only(top: 24),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: edge,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            imageFile == null
                                ? Container()
                                : Text(
                                    "Hasil:",
                                    style: blackTextStyle.copyWith(
                                      fontSize: 22,
                                    ),
                                  ),
                            const SizedBox(
                              height: 16,
                            ),
                            isLoading
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : SelectableText(
                                    result,
                                    style: greyTextStyle.copyWith(
                                      fontSize: 16,
                                    ),
                                  ),
                            const SizedBox(
                              height: 24,
                            ),
                          ],
                        ))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: purpleColor,
        child: const Icon(Icons.camera_alt),
        onPressed: () async {
          XFile? pickedFile;
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return Wrap(
                  children: [
                    ListTile(
                      onTap: () async {
                        pickedFile = await ImagePicker().pickImage(
                          source: ImageSource.camera,
                        );
                        Navigator.pop(context);
                      },
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('Kamera'),
                    ),
                    ListTile(
                      onTap: () async {
                        pickedFile = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                        );
                        Navigator.pop(context);
                      },
                      leading: const Icon(Icons.photo),
                      title: const Text('Galeri'),
                    ),
                  ],
                );
              }).whenComplete(() async {
            if (pickedFile != null) {
              setState(() {
                isLoading = true;
              });
              imageFile = File(pickedFile!.path);

              final inputImage = InputImage.fromFile(imageFile!);
              final textDetector = GoogleMlKit.vision.textDetector();
              final RecognisedText recognisedText =
                  await textDetector.processImage(inputImage);

              result = recognisedText.text;
              textDetector.close();
              setState(() {
                isLoading = false;
              });
            }
          });
        },
      ),
    );
  }
}
