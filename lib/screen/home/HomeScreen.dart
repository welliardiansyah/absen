import 'dart:ui';
import 'package:absen/core/api_service.dart';
import 'package:absen/screen/absen/AbsenScreen.dart';
import 'package:absen/screen/izin/IzinScreen.dart';
import 'package:absen/screen/profile/ProfileScreen.dart';
import 'package:absen/screen/splashscreen/Splashscreen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jiffy/jiffy.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
  String tanggal = Jiffy.now().format(pattern: 'd MMMM yyyy');
  String hari = Jiffy.now().format(pattern: 'EEEE');

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
            _isLoading = false;
          });
        } else {
          print('Failed to load profile data: ${response.statusCode}');
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const SplashScreen()),
        );
      }
    } catch (e) {
      print('Error fetching profile data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
      ),
      body: Stack(
        children: [
          ClipPath(
            clipper: ClipPathClass(),
            child: Container(
              height: 250,
              color: const Color.fromARGB(255, 0, 166, 255),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                SizedBox(
                  height: 200,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        height: 200,
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, top: 20, bottom: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 255, 255, 255),
                              Color.fromARGB(255, 235, 235, 235),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.work,
                                        color: Colors.black.withOpacity(0.6),
                                        size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Regular $userDivision",
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(0.6),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  hari.toString(),
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.6),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.access_time,
                                        color: Colors.black.withOpacity(0.6),
                                        size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$userMasuk - $userPulang WIB',
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(0.6),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  tanggal.toString(),
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.6),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.login,
                                        color: const Color.fromARGB(
                                                255, 0, 148, 189)
                                            .withOpacity(0.6),
                                        size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Masuk: $userMasuk WIB',
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                                255, 0, 148, 189)
                                            .withOpacity(0.6),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.logout,
                                        color: Color.fromARGB(255, 0, 148, 189),
                                        size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Pulang: $userPulang WIB',
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 0, 148, 189),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Divider(
                              color: Color.fromARGB(255, 195, 195, 195),
                              height: 1,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icon(Icons.event_note,
                                //     color: Colors.black.withOpacity(0.5),
                                //     size: 16),
                                // SizedBox(width: 4),
                                Text(
                                  "Rekap Absen Bulan ini",
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.5),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.check_circle,
                                            color: Colors.green, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          "HADIR",
                                          style: TextStyle(
                                              color: Colors.black
                                                  .withOpacity(0.5)),
                                        ),
                                      ],
                                    ),
                                    const Text(
                                      "11 Hari",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 28,
                                ),
                                Container(
                                  height: 40,
                                  width: 1,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                const SizedBox(
                                  width: 25,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time,
                                            color:
                                                Color.fromARGB(255, 0, 30, 255),
                                            size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          "IZIN",
                                          style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Text(
                                      "1 Hari",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Color.fromARGB(255, 0, 30, 255),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 30,
                                ),
                                Container(
                                  height: 40,
                                  width: 1,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                const SizedBox(
                                  width: 25,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.sick,
                                            color: Color.fromARGB(
                                                255, 255, 179, 0),
                                            size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          "SAKIT",
                                          style: TextStyle(
                                              color: Colors.black
                                                  .withOpacity(0.5)),
                                        ),
                                      ],
                                    ),
                                    const Text(
                                      "1 Hari",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Color.fromARGB(255, 255, 179, 0),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Menu",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 0, 166, 255)
                              .withOpacity(0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          wordSpacing: 2,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ItemKategori(
                            title: "IZIN",
                            icon: "images/papers.png",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Izinscreen(),
                                ),
                              );
                            },
                          ),
                          ItemKategori(
                            title: "LEMBUR",
                            icon: "images/clock_0.png",
                            onTap: () {},
                          ),
                          ItemKategori(
                            title: "SHIFT",
                            icon: "images/clock.png",
                            onTap: () {},
                          ),
                          ItemKategori(
                            title: "REIMBURSE",
                            icon: "images/document.png",
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ItemKategori(
                            title: "SLIP GAJI",
                            icon: "images/Coins.png",
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Berita (Cooming soon)",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 0, 166, 255)
                              .withOpacity(0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          wordSpacing: 2,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Column(
                        children: [
                          Container(
                            decoration:
                                const BoxDecoration(color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
      //** END NAVBAR BUTTON */
    );
  }
}

class ClipPathClass extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 80);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class ItemKategori extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback onTap;

  const ItemKategori({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Column(
            children: [
              Container(
                width: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(255, 219, 219, 219),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Image.asset(
                  icon,
                  scale: 1.4,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                title,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
