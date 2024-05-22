import 'dart:io';
import 'dart:ui';

import 'package:absen/screen/absen/AbsenScreen.dart';
import 'package:absen/screen/home/HomeScreen.dart';
import 'package:absen/screen/profile/ProfileScreen.dart';
import 'package:absen/screen/splashscreen/Splashscreen.dart';
import 'package:absen/util/CustomSnackBar.dart';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class Izinscreen extends StatefulWidget {
  const Izinscreen({super.key});
  @override
  _Izinscreen createState() => _Izinscreen();
}

class _Izinscreen extends State<Izinscreen> {
  final TextEditingController startController = TextEditingController();
  final TextEditingController endController = TextEditingController();
  final TextEditingController izinController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final List<DropdownMenuItem<String>> dropdownItems = [
    const DropdownMenuItem(value: 'SAKIT', child: Text('SAKIT')),
    const DropdownMenuItem(value: 'MELAHIRKAN', child: Text('MELAHIRKAN')),
    const DropdownMenuItem(value: 'KEGUGURAN', child: Text('KEGUGURAN')),
    const DropdownMenuItem(value: 'HAID', child: Text('HAID')),
    const DropdownMenuItem(value: 'MENIKAH', child: Text('MENIKAH')),
    const DropdownMenuItem(value: 'PENTING', child: Text('PENTING')),
    const DropdownMenuItem(value: 'BERDUKA', child: Text('BERDUKA')),
  ];

  bool isLoading = false;
  File? imageFile;
  final imagePicker = ImagePicker();
  ImageSource? source;

  Future<void> getFromCamera(ImageSource? source) async {
    final pickedFile = await imagePicker.pickImage(
      source: source!,
      preferredCameraDevice: CameraDevice.front,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  bool isHomeScreen = false;
  String userName = '';
  String userId = '';
  String userMasuk = '';
  String userPulang = '';
  bool _isLoading = true;
  String address = '';
  late String users;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token != null) {
        Dio dio = Dio();
        dio.options.headers['Authorization'] = 'Bearer $token';

        Response response =
            await dio.get('http://68.183.234.187:8080/api/v1/auth/profile');
        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = response.data['data'];
          String name = responseData['fullname'];
          String masuk = responseData['shift'][0]['time_start'].toString();
          String pulang = responseData['shift'][0]['time_end'].toString();
          String id = responseData['id'];

          setState(() {
            userName = name;
            userMasuk = masuk;
            userPulang = pulang;
            userId = id;
            users = id;
          });
        } else {
          print('Failed to load profile data: ${response.statusCode}');
          _isLoading = false;
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SplashScreen()),
        );
      }
    } catch (e) {
      print('Error fetching profile data: $e');
      _isLoading = false;
    }
  }

  Future<void> submitForm() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token != null) {
        String url = 'http://68.183.234.187:8080/api/v1/izin';

        var request = http.MultipartRequest('POST', Uri.parse(url));
        request.headers['Authorization'] = 'Bearer $token';
        request.fields['name'] = izinController.text;
        request.fields['dateStart'] = startController.text;
        request.fields['dateEnd'] = endController.text;
        request.fields['description'] = descriptionController.text;
        request.fields['users'] = userId; // assuming userId is the correct ID
        request.fields['is_actived'] = 'true';

        if (imageFile != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'photo',
            imageFile!.path,
            contentType: MediaType.parse('image/png'),
          ));
        }

        var response = await request.send();
        if (response.statusCode == 200) {
          setState(() {
            isLoading = false;
          });
          CustomSnackBar.show(context, 'Izin berhasil diajukan!.');
          print('Izin berhasil diajukan.');

          // Navigate to HomeScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          setState(() {
            isLoading = false;
          });
          CustomSnackBar.show(
              context, 'Gagal mengajukan izin: ${response.statusCode}');
          print('Gagal mengajukan izin: ${response.statusCode}');
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print('Token tidak ditemukan.');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error mengirim data izin: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    text: "Hai, ",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(
                        text: userName,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Row(
              children: [
                Text(
                  "PT. INDONESIA MAJU TERUS, ",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              height: 30,
              width: 30,
              child: const Icon(
                Icons.account_circle,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 0, 166, 255),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: ListView(
          children: [
            const Center(
              child: Text(
                "FORM PENGAJUHAN IZIN",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(128, 0, 0, 0),
                ),
              ),
            ),
            const SizedBox(
              height: 35,
            ),
            MyTextField(
              fieldName: 'Jenis Izin',
              myController: izinController,
              myIcon: Icons.book_outlined,
              isDropdown: true,
              dropdownItems: dropdownItems,
            ),
            const SizedBox(
              height: 15,
            ),
            MyTextField(
              fieldName: 'Tanggal Mulai Izin',
              myController: startController,
              myIcon: Icons.date_range_outlined,
              inputType: TextInputType.datetime,
            ),
            const SizedBox(
              height: 15,
            ),
            MyTextField(
              fieldName: 'Tanggal Selesai Izin',
              myController: endController,
              myIcon: Icons.date_range_outlined,
              inputType: TextInputType.datetime,
            ),
            const SizedBox(
              height: 15,
            ),
            MyTextField(
              fieldName: 'Deskripsi',
              myController: descriptionController,
              myIcon: Icons.description_outlined,
              maxLines: 2,
            ),
            const SizedBox(
              height: 15,
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Pilih Sumber Gambar'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            getFromCamera(ImageSource.camera); // Buka kamera
                          },
                          child: const Text('Kamera'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            getFromCamera(ImageSource.gallery); // Buka galeri
                          },
                          child: const Text('Galeri'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Container(
                constraints:
                    const BoxConstraints(maxHeight: 180, maxWidth: 700),
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(12),
                  color: Colors.blueGrey,
                  strokeWidth: 1,
                  dashPattern: const [3, 3],
                  child: SizedBox.expand(
                    child: FittedBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          imageFile != null
                              ? Image.file(File(imageFile!.path),
                                  fit: BoxFit.cover)
                              : const Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.blueGrey,
                                  size: 30,
                                ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Tekan untuk membuka Kamera',
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            ElevatedButton(
              onPressed: () {
                submitForm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: const TextStyle(fontSize: 15),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.confirmation_num_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  Text(
                    'Konnfrimasi Izin',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      //** NABAR BUTTON */
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.only(bottom: 5, top: 5),
      //   child: FloatingActionButton(
      //     backgroundColor: isHomeScreen
      //         ? const Color.fromARGB(255, 0, 166, 255)
      //         : Colors.grey,
      //     onPressed: () {
      //       getFromCamera();
      //     },
      //     shape: const CircleBorder(),
      //     child: const Icon(
      //       Icons.fingerprint_rounded,
      //       size: 30,
      //       color: Colors.white,
      //     ),
      //   ),
      // ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: BottomAppBar(
          height: MediaQuery.of(context).size.height / 10,
          shape: const CircularNotchedRectangle(),
          notchMargin: 3,
          color: const Color.fromARGB(255, 255, 255, 255),
          elevation: 0,
          clipBehavior: Clip.hardEdge,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 3,
              sigmaY: 3,
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color.fromARGB(255, 0, 166, 255),
              unselectedItemColor: Colors.grey,
              currentIndex: isHomeScreen ? 0 : 1,
              elevation: 0,
              onTap: (index) {
                setState(() {
                  isHomeScreen = index == 0;
                });
                if (index == 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                } else if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Absenscreen()),
                  );
                }
              },
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home), label: 'BERANDA'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.bookmark_outline_rounded),
                    label: 'DATA ABSENSI'),
              ],
              selectedLabelStyle: const TextStyle(fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  const MyTextField({
    super.key,
    required this.fieldName,
    required this.myController,
    this.myIcon = Icons.verified_user_outlined,
    this.prefixIconColor = Colors.blueAccent,
    this.inputType = TextInputType.text,
    this.isDropdown = false,
    this.dropdownItems,
    this.maxLines = 1,
  });

  final TextEditingController myController;
  final String fieldName;
  final IconData myIcon;
  final Color prefixIconColor;
  final TextInputType inputType;
  final bool isDropdown;
  final List<DropdownMenuItem<String>>? dropdownItems;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return isDropdown
        ? DropdownButtonFormField<String>(
            value: myController.text.isEmpty ? null : myController.text,
            items: dropdownItems,
            onChanged: (value) {
              myController.text = value!;
            },
            decoration: InputDecoration(
              labelText: fieldName,
              prefixIcon: Icon(myIcon, color: prefixIconColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              labelStyle: const TextStyle(color: Colors.grey),
              contentPadding: const EdgeInsets.all(10.0),
            ),
          )
        : TextFormField(
            controller: myController,
            keyboardType: inputType,
            maxLines: maxLines,
            onTap: () async {
              if (inputType == TextInputType.datetime) {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2101),
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: ThemeData.light(),
                      child: child!,
                    );
                  },
                );

                if (pickedDate != null) {
                  myController.text = pickedDate.toString().substring(0, 10);
                }
              }
            },
            decoration: InputDecoration(
              labelText: fieldName,
              prefixIcon: Icon(myIcon, color: prefixIconColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              labelStyle: const TextStyle(color: Colors.grey),
              contentPadding: const EdgeInsets.all(10.0),
            ),
          );
  }
}
