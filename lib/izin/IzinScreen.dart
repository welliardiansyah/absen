import 'dart:ui';
import 'package:absen/core/api_service.dart';
import 'package:absen/screen/absen/AbsenScreen.dart';
import 'package:absen/screen/home/HomeScreen.dart';
import 'package:absen/screen/profile/ProfileScreen.dart';
import 'package:absen/screen/splashscreen/Splashscreen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IzinScreen extends StatefulWidget {
  const IzinScreen({super.key});
  @override
  State<IzinScreen> createState() => _IzinScreen();
}

class _IzinScreen extends State<IzinScreen> {
  final _productController = TextEditingController();
  final _productDesController = TextEditingController();

  final ApiService _apiService = ApiService();
  bool isHomeScreen = true;
  bool _isLoading = true;
  String? userId;
  String? userNik;
  String? userNames;

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
            userNames = responseData['fullname'].toString();
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

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  @override
  void dispose() {
    _productController.dispose();
    _productDesController.dispose();
    super.dispose();
    _fetchProfileData();
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
                      Text(
                        "FORM IZIN",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ],
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
                                height: innerHeight * 0.95,
                                width: innerWidth,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 20),
                                      child: Column(
                                        children: [
                                          const Text(
                                            "PENGAJUAN IZIN",
                                            style: TextStyle(
                                              color:
                                                  Color.fromARGB(134, 0, 0, 0),
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 10.0),
                                          MyTextField(
                                            myController: _productController,
                                            fieldName: "Jenis izin",
                                            myIcon: Icons.book_rounded,
                                            prefixIconColor:
                                                const Color.fromARGB(
                                                    255, 203, 203, 203),
                                          ),
                                          const SizedBox(height: 10.0),
                                          MyTextField(
                                            myController: _productController,
                                            fieldName: "Tanggal izin",
                                            myIcon: Icons.account_balance,
                                            prefixIconColor:
                                                const Color.fromARGB(
                                                    255, 0, 166, 255),
                                            isDate: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              textStyle: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            child: const Row(
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

  OutlinedButton myBtn(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
          minimumSize: const Size(200, 50), backgroundColor: Colors.blue),
      onPressed: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) {
        //     return Details(
        //       productName: _productController.text,
        //       productDescription: _productDesController.text,
        //     );
        //   }),
        // );
      },
      child: Text(
        "Submit Form".toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 0, 166, 255),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class MyTextField extends StatelessWidget {
  final TextEditingController myController;
  final String fieldName;
  final IconData myIcon;
  final Color prefixIconColor;
  final bool isDate;

  MyTextField({
    Key? key,
    required this.fieldName,
    required this.myController,
    this.myIcon = Icons.verified_user_outlined,
    this.prefixIconColor = const Color.fromARGB(255, 0, 166, 255),
    this.isDate = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 49,
      child: TextFormField(
        controller: myController,
        readOnly: isDate,
        onTap: isDate
            ? () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  myController.text =
                      DateFormat('yyyy-MM-dd').format(pickedDate);
                }
              }
            : null,
        decoration: InputDecoration(
          labelText: fieldName,
          prefixIcon: Icon(myIcon, color: prefixIconColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Color.fromARGB(255, 0, 166, 255),
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.red,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.red,
            ),
          ),
          labelStyle: TextStyle(
            fontSize: 16,
            color: Color.fromARGB(255, 0, 166, 255),
          ),
        ),
      ),
    );
  }
}
