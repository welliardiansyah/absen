import 'dart:ffi';
import 'dart:io';
import 'dart:ui';
import 'package:absen/core/api_service.dart';
import 'package:absen/screen/home/HomeScreen.dart';
import 'package:absen/screen/profile/ProfileScreen.dart';
import 'package:absen/screen/splashscreen/Splashscreen.dart';
import 'package:absen/util/CustomSnackBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:jiffy/jiffy.dart';
import 'package:geocoding/geocoding.dart';

class Absenscreen extends StatefulWidget {
  const Absenscreen({super.key});
  @override
  _AbsenScreen createState() => _AbsenScreen();
}

class _AbsenScreen extends State<Absenscreen> {
  final ApiService _apiService = ApiService();
  File? imageFile;
  final imagePicker = ImagePicker();

  Future<void> getFromCamera() async {
    final pickedFile = await imagePicker.pickImage(
      source: ImageSource.camera,
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

  bool isHomeScreen = true;
  String userName = '';
  String userId = '';
  String userMasuk = '';
  String userPulang = '';
  bool _isLoading = true;
  String address = '';

  //** INSERT ABSEN */
  late String users;
  String absensiType = "PULANG";
  String time = Jiffy.now().format(pattern: 'EEEE, dd MMMM yyyy HH:mm:ss.SSS');
  String timeStart = "";
  String timeEnd = "";
  double latitude = 0.0;
  double longitude = 0.0;
  String description = "";
  //** END INSERT ABSEN */

  @override
  void initState() {
    super.initState();
    getFromCamera();
    _fetchProfileData();
    getLocation();
    getCurrentLocation();
  }

  void getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });
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

  Future<void> _submitAbsensi() async {
    if (imageFile == null) {
      CustomSnackBar.show(
          context, 'Harap selfie terlebih dahulu sebelum melakukan absensi!');
      return;
    }

    getLocation();

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
      DateTime now = DateTime.now();
      String formattedTime = DateFormat('HH:mm').format(now);

      DateTime userMasukDateTime;
      if (userMasuk is String) {
        userMasukDateTime = DateFormat('HH:mm').parse(userMasuk);
      } else if (userMasuk is DateTime) {
        userMasukDateTime = userMasuk as DateTime;
      } else {
        throw Exception('userMasuk is not a DateTime or a valid String object');
      }

      DateTime userPulangDateTime;
      if (userPulang is String) {
        userPulangDateTime = DateFormat('HH:mm').parse(userPulang);
      } else if (userPulang is DateTime) {
        userPulangDateTime = userPulang as DateTime;
      } else {
        throw Exception(
            'userPulang is not a DateTime or a valid String object');
      }

      DateTime startTimeMasuk =
          DateTime(now.year, now.month, now.day, 7, 0); // 7:00 AM
      DateTime endTimeMasuk =
          DateTime(now.year, now.month, now.day, 9, 0); // 9:00 AM
      DateTime startTimeTelat =
          DateTime(now.year, now.month, now.day, 10, 0); // 10:00 AM
      DateTime endTimeTelat =
          DateTime(now.year, now.month, now.day, 15, 0); // 3:00 PM
      DateTime startTimePulang =
          DateTime(now.year, now.month, now.day, 15, 0); // 3:00 PM
      DateTime endTimePulang =
          DateTime(now.year, now.month, now.day, 19, 0); // 7:00 PM
      DateTime startTimeLembur =
          DateTime(now.year, now.month, now.day, 19, 0); // 7:00 PM

      String absenType;
      if (now.isAfter(startTimeMasuk) && now.isBefore(endTimeMasuk)) {
        absenType = 'MASUK';
      } else if (now.isAfter(startTimeTelat) && now.isBefore(endTimeTelat)) {
        absenType = 'TELAT';
      } else if (now.isAfter(startTimePulang) && now.isBefore(endTimePulang)) {
        absenType = 'PULANG';
      } else if (now.isAfter(startTimeLembur)) {
        absenType = 'LEMBUR';
      } else {
        CustomSnackBar.show(context, 'Waktu absen tidak memenuhi syarat');
        return;
      }

      Response response = await _apiService.createAbsensi(
        users,
        absenType,
        time,
        timeStart,
        timeEnd,
        latitude.toString(),
        longitude.toString(),
        description,
      );
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        CustomSnackBar.show(context, 'Absensi berhasil dibuat');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        CustomSnackBar.show(
            context, 'Gagal membuat absensi: ${response.statusMessage}');
      }
    } catch (e) {
      Navigator.of(context).pop();
      CustomSnackBar.show(context, 'Gagal membuat absensi: $e');
    }
  }

  bool isAbsenMasuk() {
    DateTime now = DateTime.now();
    DateTime startTimeMasuk =
        DateTime(now.year, now.month, now.day, 7, 0); // 7:00 AM
    DateTime endTimeMasuk =
        DateTime(now.year, now.month, now.day, 9, 0); // 9:00 AM
    DateTime startTimeTelat =
        DateTime(now.year, now.month, now.day, 10, 0); // 10:00 AM
    DateTime endTimeTelat =
        DateTime(now.year, now.month, now.day, 15, 0); // 3:00 PM
    DateTime startTimePulang =
        DateTime(now.year, now.month, now.day, 15, 0); // 3:00 PM
    DateTime endTimePulang =
        DateTime(now.year, now.month, now.day, 19, 0); // 7:00 PM
    DateTime startTimeLembur =
        DateTime(now.year, now.month, now.day, 19, 0); // 7:00 PM

    return now.isAfter(startTimeMasuk) && now.isBefore(endTimeMasuk);
  }

  Color getButtonColor() {
    DateTime now = DateTime.now();
    DateTime startTimeMasuk =
        DateTime(now.year, now.month, now.day, 7, 0); // 7:00 AM
    DateTime endTimeMasuk =
        DateTime(now.year, now.month, now.day, 9, 0); // 9:00 AM
    DateTime startTimeTelat =
        DateTime(now.year, now.month, now.day, 10, 0); // 10:00 AM
    DateTime endTimeTelat =
        DateTime(now.year, now.month, now.day, 15, 0); // 3:00 PM
    DateTime startTimePulang =
        DateTime(now.year, now.month, now.day, 15, 0); // 3:00 PM
    DateTime endTimePulang =
        DateTime(now.year, now.month, now.day, 19, 0); // 7:00 PM
    DateTime startTimeLembur =
        DateTime(now.year, now.month, now.day, 19, 0); // 7:00 PMg

    return now.isAfter(startTimeMasuk) && now.isBefore(endTimeMasuk)
        ? Colors.green // Warna hijau jika jam masuk
        : Colors.red; // Warna merah jika jam pulang
  }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });
      await getAddressFromLatLng(latitude, longitude);
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<void> getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];
      setState(() {
        address = "${place.street}, ${place.locality}, ${place.country}";
      });
    } catch (e) {
      print("Error getting address: $e");
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: () {
              getFromCamera();
            },
            child: Container(
              constraints: const BoxConstraints(maxHeight: 385, maxWidth: 500),
              margin: const EdgeInsets.all(20),
              child: DottedBorder(
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),
                color: Colors.blueGrey,
                strokeWidth: 1,
                dashPattern: const [5, 5],
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
                                size: 80,
                              ),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'Tekan untuk membuka Kamera',
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
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
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
                width: MediaQuery.of(context).size.width * 25.0,
                decoration: BoxDecoration(
                  color:
                      const Color.fromARGB(255, 255, 255, 255).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 20,
                                color: Color.fromARGB(255, 85, 85, 85),
                              ),
                              SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Lokasi Saat ini",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    address,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 205, 205, 205),
                      height: 1,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.work_outline,
                                size: 20,
                                color: Color.fromARGB(255, 85, 85, 85),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (DateTime.now().weekday ==
                                                DateTime.saturday ||
                                            DateTime.now().weekday ==
                                                DateTime.sunday)
                                        ? "Hari ini Libur"
                                        : "Jam Kerja $userMasuk - $userPulang WIB",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    (DateTime.now().weekday ==
                                                DateTime.saturday ||
                                            DateTime.now().weekday ==
                                                DateTime.sunday)
                                        ? "Hari ini anda libur tidak dapat melakukan absensi!"
                                        : isAbsenMasuk()
                                            ? "Lakukan absen masuk pada jam $userMasuk"
                                            : "Lakukan absen pulang pada jam $userPulang",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: (DateTime.now().weekday ==
                                                  DateTime.saturday ||
                                              DateTime.now().weekday ==
                                                  DateTime.sunday)
                                          ? Colors.red
                                          : Colors.black,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),

                              //** START ABSENNSI BUTTON */
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: buildButton(),
                              ),
                              //** END ABSENNSI BUTTON */
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      //** NABAR BUTTON */
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 5, top: 5),
        child: FloatingActionButton(
          backgroundColor: isHomeScreen
              ? const Color.fromARGB(255, 0, 166, 255)
              : Colors.grey,
          onPressed: () {
            getFromCamera();
          },
          shape: const CircleBorder(),
          child: const Icon(
            Icons.fingerprint_rounded,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3), // changes position of shadow
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

  Widget buildButton() {
    if (DateTime.now().weekday == DateTime.saturday ||
        DateTime.now().weekday == DateTime.sunday) {
      return const SizedBox.shrink();
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
        ),
        child: Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: getButtonColor(),
            ),
            child: Material(
              borderRadius: BorderRadius.circular(20),
              color: Colors.transparent,
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    _submitAbsensi();
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(width: 10),
                    Text(
                      isAbsenMasuk() ? 'Masuk' : 'Pulang',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_circle_right_rounded,
                      color: Colors.white,
                      size: 25,
                    ),
                    const SizedBox(width: 5),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}
