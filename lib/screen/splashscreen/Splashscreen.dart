import 'dart:async';
import 'package:absen/screen/home/HomeScreen.dart';
import 'package:absen/screen/login/ByEmail.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashscreenState createState() => _SplashscreenState();
}

class _SplashscreenState extends State<SplashScreen> {
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      Dio dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      Response response =
          await dio.get('http://68.183.234.187:8080/api/v1/auth/profile');
      if (response.statusCode == 200) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        prefs.remove('token');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ByEmailScreen()),
        );
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => ByEmailScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ByEmailScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 5, 81, 122),
              Color.fromARGB(255, 0, 166, 255)
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'logoAnimation',
              child: Image.asset(
                "images/logo.png",
                scale: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Selamat Datang',
              style: TextStyle(
                fontSize: 24,
                color: Color.fromARGB(217, 0, 0, 0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
