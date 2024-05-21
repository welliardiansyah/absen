import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:absen/core/api_service.dart';
import 'package:absen/screen/splashscreen/Splashscreen.dart';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IzinScreen extends StatefulWidget {
  const IzinScreen({super.key});
  @override
  State<IzinScreen> createState() => _IzinScreen();
}

class _IzinScreen extends State<IzinScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController izinController = TextEditingController();
  final TextEditingController startController = TextEditingController();
  final TextEditingController endController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController photoController = TextEditingController();
  final TextEditingController usersController = TextEditingController();

  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? userId;
  String? userNik;
  String? userNames;

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
            userNames = responseData['fullname'].toString();
            usersController.text = responseData['id'].toString();
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

  Future<Response> _createIzin(
    String name,
    String dateStart,
    String dateEnd,
    String description,
    String photo,
    String users,
    String isActived,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token != null) {
        Dio dio = Dio();
        dio.options.headers['Authorization'] = 'Bearer $token';

        final response = await dio.post(
          'http://68.183.234.187:8080/api/v1/izin',
          data: {
            'name': name,
            'dateStart': dateStart,
            'dateEnd': dateEnd,
            'description': description,
            'photo': photo,
            'users': users,
            'isActived': isActived,
          },
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to create izin: ${response.statusMessage}');
        }

        return response;
      } else {
        throw Exception('Token is null. Failed to create izin.');
      }
    } catch (e) {
      throw Exception('Failed to create izin: ${e.toString()}');
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        photoController.text = pickedFile.path;
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        photoController.text = pickedFile.path;
      });
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImageFromCamera();
              },
            ),
          ],
        ),
      ),
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
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 0, 166, 255),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
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
                        onPressed: () {},
                      ),
                    ],
                  ),
                  SizedBox(
                    height: height * 0.7,
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
                                height: innerHeight * 0.92,
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
                                          const SizedBox(height: 40.0),
                                          MyTextField(
                                            myController: izinController,
                                            fieldName: "Jenis Izin",
                                            myIcon: Icons.note_outlined,
                                            prefixIconColor: Colors.grey,
                                            isDropdown: true,
                                            dropdownItems: const [
                                              'SAKIT',
                                              'MELAHIRKAN',
                                              'KEGUGURAN',
                                              'HAID',
                                              'MENIKAH',
                                              'PENTING',
                                              'BERDUKA'
                                            ],
                                          ),
                                          const SizedBox(height: 15),
                                          MyTextField(
                                            myController: startController,
                                            fieldName: "Tanggal Mulai izin",
                                            myIcon: Icons.date_range_outlined,
                                            prefixIconColor:
                                                const Color.fromARGB(
                                                    255, 203, 203, 203),
                                            isDate: true,
                                          ),
                                          const SizedBox(height: 15),
                                          MyTextField(
                                            myController: endController,
                                            fieldName: "Tanggal Selesai izin",
                                            myIcon: Icons.date_range_outlined,
                                            prefixIconColor:
                                                const Color.fromARGB(
                                                    255, 203, 203, 203),
                                            isDate: true,
                                          ),
                                          const SizedBox(height: 15),
                                          MyTextField(
                                            myController: descriptionController,
                                            fieldName: "Description",
                                            myIcon: Icons.chat_outlined,
                                            prefixIconColor:
                                                const Color.fromARGB(
                                                    255, 203, 203, 203),
                                            isMultiline: true,
                                          ),
                                          const SizedBox(height: 15),
                                          GestureDetector(
                                            onTap: () {
                                              _showImageSourceActionSheet(
                                                  context);
                                            },
                                            child: Container(
                                              constraints: const BoxConstraints(
                                                maxHeight: 180,
                                              ),
                                              margin:
                                                  const EdgeInsets.all(0.10),
                                              child: DottedBorder(
                                                borderType: BorderType.RRect,
                                                radius:
                                                    const Radius.circular(12),
                                                color: Colors.blueGrey,
                                                strokeWidth: 1,
                                                dashPattern: const [5, 5],
                                                child: SizedBox.expand(
                                                  child: FittedBox(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        _imageFile != null
                                                            ? Image.file(
                                                                File(_imageFile!
                                                                    .path),
                                                                fit: BoxFit
                                                                    .cover,
                                                              )
                                                            : const Icon(
                                                                Icons
                                                                    .camera_alt_outlined,
                                                                color: Colors
                                                                    .blueGrey,
                                                                size: 80,
                                                              ),
                                                        const SizedBox(
                                                            height: 10),
                                                        const Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      10),
                                                          child: Text(
                                                            'Tekan untuk membuka Kamera atau Galeri',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .blueGrey,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
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
                  const SizedBox(
                    height: 30,
                  ),
                  Column(
                    children: [
                      Center(
                        child: SizedBox(
                          width: 390,
                          child: ElevatedButton(
                            onPressed: () {
                              _createIzin(
                                izinController.text,
                                startController.text,
                                endController.text,
                                descriptionController.text,
                                photoController.text,
                                usersController.text,
                                'ture',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 62, 218, 0),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              textStyle: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  Icons.confirmation_number_outlined,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  size: 20,
                                ),
                                Text(
                                  'KONFRIMASI IZIN',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_outlined,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  size: 20,
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
        ),
      ],
    );
  }
}

class MyTextField extends StatefulWidget {
  final TextEditingController myController;
  final String fieldName;
  final IconData myIcon;
  final Color prefixIconColor;
  final bool isDate;
  final bool isMultiline;
  final bool isDropdown;
  final List<String>? dropdownItems;

  MyTextField({
    Key? key,
    required this.fieldName,
    required this.myController,
    this.myIcon = Icons.verified_user_outlined,
    this.prefixIconColor = const Color.fromARGB(255, 0, 166, 255),
    this.isDate = false,
    this.isMultiline = false,
    this.isDropdown = false,
    this.dropdownItems,
  })  : assert(!isDropdown || dropdownItems != null,
            'dropdownItems must be provided if isDropdown is true'),
        super(key: key);

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  String? _selectedItem;

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder commonBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: Colors.grey,
      ),
    );

    const TextStyle commonLabelStyle = TextStyle(
      fontSize: 14,
      color: Colors.grey,
    );

    if (widget.isDropdown) {
      return DropdownButtonFormField<String>(
        value: _selectedItem,
        onChanged: (String? newValue) {
          setState(() {
            _selectedItem = newValue;
          });
        },
        items:
            widget.dropdownItems!.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: widget.fieldName,
          labelStyle: commonLabelStyle,
          prefixIcon: Icon(widget.myIcon, color: widget.prefixIconColor),
          border: commonBorder,
          enabledBorder: commonBorder,
          focusedBorder: commonBorder.copyWith(
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 0, 166, 255),
            ),
          ),
          errorBorder: commonBorder.copyWith(
            borderSide: const BorderSide(
              color: Colors.red,
            ),
          ),
          focusedErrorBorder: commonBorder.copyWith(
            borderSide: const BorderSide(
              color: Colors.red,
            ),
          ),
        ),
      );
    } else if (widget.isMultiline) {
      return TextField(
        maxLines: 1,
        textAlignVertical: TextAlignVertical.top,
        controller: widget.myController,
        decoration: InputDecoration(
          border: commonBorder,
          enabledBorder: commonBorder,
          focusedBorder: commonBorder.copyWith(
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 0, 166, 255),
            ),
          ),
          labelText: widget.fieldName,
          labelStyle: commonLabelStyle,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Align(
              alignment: Alignment.center,
              widthFactor: 0.9,
              heightFactor: 1.0,
              child: Icon(
                widget.myIcon,
                size: 25,
                color: widget.prefixIconColor,
              ),
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        height: 49,
        child: TextFormField(
          controller: widget.myController,
          readOnly: widget.isDate,
          onTap: widget.isDate
              ? () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2025),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      widget.myController.text =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                    });
                  }
                }
              : null,
          decoration: InputDecoration(
            labelText: widget.fieldName,
            labelStyle: commonLabelStyle,
            prefixIcon: Icon(widget.myIcon, color: widget.prefixIconColor),
            border: commonBorder,
            enabledBorder: commonBorder,
            focusedBorder: commonBorder.copyWith(
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 0, 166, 255),
              ),
            ),
            errorBorder: commonBorder.copyWith(
              borderSide: const BorderSide(
                color: Colors.red,
              ),
            ),
            focusedErrorBorder: commonBorder.copyWith(
              borderSide: const BorderSide(
                color: Colors.red,
              ),
            ),
          ),
        ),
      );
    }
  }
}
