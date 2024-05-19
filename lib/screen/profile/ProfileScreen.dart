import 'dart:ui';
import 'package:absen/core/api_service.dart';
import 'package:absen/screen/absen/AbsenScreen.dart';
import 'package:absen/screen/home/HomeScreen.dart';
import 'package:absen/screen/splashscreen/Splashscreen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  bool isHomeScreen = true;
  bool _isLoading = true;
  String? userId;
  String? userNik;
  String? userName;
  String? userAddress;
  String? userEmail;
  String? userPhone;
  String? userDivision;
  String? userMasuk;
  String? userPulang;
  List<String> userRoles = [];

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
          setState(() {
            userId = responseData['id'].toString();
            userNik = responseData['nik'].toString();
            userName = responseData['fullname'].toString();
            userAddress = responseData['address'].toString();
            userEmail = responseData['email'].toString();
            userPhone = responseData['phone'].toString();
            userMasuk = responseData['shift'][0]['time_start'].toString();
            userPulang = responseData['shift'][0]['time_end'].toString();
            userDivision =
                responseData['shift'][0]['divisions']['name'].toString();
            userRoles = List<String>.from(responseData['roles'] ?? []);

            if (userRoles.contains('USER')) {
              userRoles[userRoles.indexOf('USER')] = 'KARYAWAN';
            }

            _isLoading = true;
          });
        } else {
          print('Failed to load profile data: ${response.statusCode}');
          setState(() {
            _isLoading = true;
          });
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SplashScreen()),
        );
      }
    } catch (e) {
      print('Error fetching profile data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi Logout"),
          content: Text("Anda yakin ingin keluar?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  String? token = prefs.getString('token');

                  if (token != null) {
                    Dio dio = Dio();
                    dio.options.headers['Authorization'] = 'Bearer $token';

                    Response response = await dio
                        .post('http://68.183.234.187:8080/api/v1/auth/logout');
                    if (response.statusCode == 200) {
                      await prefs.remove('token');
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => SplashScreen()),
                        (route) => false,
                      );
                    } else {
                      print('Failed to log out: ${response.statusCode}');
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Gagal Logout"),
                            content: Text(
                                "Gagal melakukan logout. Silakan coba lagi."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Tutup"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  } else {
                    print('Token not available');
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  print('Error logging out: $e');
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Error"),
                        content: Text(
                            "Terjadi kesalahan saat melakukan logout. Silakan coba lagi."),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Tutup dialog
                            },
                            child: Text("Tutup"),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text("Keluar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 0, 166, 255),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 45),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.white,
                        ),
                        onPressed: _logout,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: height * 0.5,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double innerHeight = constraints.maxHeight;
                        double innerWidth = constraints.maxWidth;
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: innerHeight * 0.80,
                                width: innerWidth,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 150,
                                    ),
                                    Text(
                                      userName.toString(),
                                      style: TextStyle(
                                        color: Color.fromRGBO(39, 105, 171, 1),
                                        fontFamily: 'Nunito',
                                        fontSize: 24,
                                      ),
                                    ),
                                    Text(
                                      userNik.toString(),
                                      style: TextStyle(
                                        color: Color.fromRGBO(39, 105, 171, 1),
                                        fontFamily: 'Nunito',
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              'DIVISION',
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontFamily: 'Nunito',
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              userDivision != null &&
                                                      userDivision!.isNotEmpty
                                                  ? userDivision!
                                                  : 'Tidak ada divisi',
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    39, 105, 171, 1),
                                                fontFamily: 'Nunito',
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 25,
                                            vertical: 8,
                                          ),
                                          child: Container(
                                            height: 50,
                                            width: 1,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              'JABATAN',
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontFamily: 'Nunito',
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              userRoles != null &&
                                                      userRoles!.isNotEmpty
                                                  ? userRoles!.join(', ')
                                                  : 'Tidak ada jabatan',
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    39, 105, 171, 1),
                                                fontFamily: 'Nunito',
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "PT. INDOENSIA MAJU TERUS",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black.withOpacity(0.5)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: ClipOval(
                                  child: Container(
                                    width: innerWidth * 0.5,
                                    height: innerWidth * 0.5,
                                    child: Image.asset(
                                      'images/profile.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Column(
                    children: [
                      Center(
                        child: SizedBox(
                          width: 390,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              textStyle: TextStyle(fontSize: 15),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  Icons.account_circle,
                                  color: Color.fromARGB(255, 0, 166, 255),
                                ),
                                Text(
                                  'Perbarui Profile',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 0, 166, 255),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Color.fromARGB(255, 0, 166, 255),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: SizedBox(
                          width: 390,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              textStyle: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  Icons.lock_reset,
                                  color: Color.fromARGB(255, 0, 166, 255),
                                ),
                                Text(
                                  'Perbarui Password',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 0, 166, 255),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Color.fromARGB(255, 0, 166, 255),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          //** NAVBAR BUTTON */
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 5, top: 5),
            child: FloatingActionButton(
              backgroundColor:
                  isHomeScreen ? Color.fromARGB(255, 0, 166, 255) : Colors.grey,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Absenscreen()),
                );
              },
              shape: const CircleBorder(),
              child: const Icon(
                Icons.fingerprint_rounded,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          extendBody: true,
          bottomNavigationBar: BottomAppBar(
            height: MediaQuery.of(context).size.height / 10,
            shape: const CircularNotchedRectangle(),
            notchMargin: 3,
            color: const Color.fromARGB(255, 238, 236, 236),
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
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
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
                    label: 'DATA ABSENSI',
                  ),
                ],
                selectedLabelStyle: const TextStyle(fontSize: 12),
                unselectedLabelStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          //** END NAVBAR BUTTON */
        ),
      ],
    );
  }
}
