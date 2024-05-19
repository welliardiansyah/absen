import 'package:absen/screen/splashscreen/Splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jiffy/jiffy.dart';

void main() {
  Jiffy.setLocale('id');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: const Color.fromARGB(255, 227, 227, 227),
        statusBarIconBrightness: Brightness.light,
        statusBarColor: const Color.fromARGB(255, 255, 255, 255),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Image Picker',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const SplashScreen(),
    );
  }
}
