import 'package:absen/core/api_service.dart';
import 'package:absen/screen/home/HomeScreen.dart';
import 'package:absen/screen/login/ByNik.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ByEmailScreen extends StatefulWidget {
  @override
  _ByEmailScreen createState() => _ByEmailScreen();
}

class _ByEmailScreen extends State<ByEmailScreen> {
  bool isEmailValid = false;
  bool isPasswordVisible = false;
  final ApiService _apiService = ApiService();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void _login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showDialog('Login Failed', 'Email atau Password tidak boleh kosong!.');
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      var response = await _apiService.loginByEmail(email, password);
      if (response.statusCode == 200) {
        String token = response.data['data']['token'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', token);
        prefs.setBool('isLoggedIn', true);

        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      } else if (response.statusCode == 401) {
        Navigator.pop(context);
        _showDialog('Login Failed', 'Invalid email or password.');
      } else {
        Navigator.pop(context);
        _showDialog('Error', 'An error occurred. Please try again later.');
      }
    } catch (e) {
      Navigator.pop(context);
      print('Login error: $e');
      _showDialog('Error', 'An error occurred. Please try again later.');
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 6, 103, 155),
                  Color.fromARGB(255, 0, 166, 255)
                ],
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.only(left: 25, top: 180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hai,",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Masuk ke Akun!.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 350.0),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                color: Colors.white,
              ),
              height: double.infinity,
              width: double.infinity,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: emailController,
                      onChanged: (value) {
                        setState(() {
                          isEmailValid = value.isNotEmpty;
                        });
                      },
                      decoration: InputDecoration(
                        suffixIcon: Icon(
                          Icons.check,
                          color: isEmailValid ? Colors.green : Colors.grey,
                        ),
                        labelText: 'Email',
                        labelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 6, 103, 155),
                        ),
                      ),
                    ),
                    TextField(
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      onChanged: (value) {
                        setState(() {
                          isPasswordVisible = value.isNotEmpty;
                        });
                      },
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color:
                                isPasswordVisible ? Colors.green : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                        labelText: 'Password',
                        labelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 6, 103, 155),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    Container(
                      height: 55,
                      width: 350,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 6, 103, 155),
                            Color.fromARGB(255, 0, 166, 255),
                          ],
                        ),
                      ),
                      child: MaterialButton(
                        onPressed: _login,
                        child: const Text(
                          'MASUK',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      height: 55,
                      width: 350,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromRGBO(0, 213, 220, 1),
                            Color.fromRGBO(0, 213, 220, 1),
                          ],
                        ),
                      ),
                      child: MaterialButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ByNikScreen()),
                          );
                        },
                        child: const Text(
                          'MASUK DENGAN NIK',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
