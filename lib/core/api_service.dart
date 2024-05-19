import 'dart:convert';
import 'dart:ffi';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<Response> loginByNik(String nik, String password) async {
    try {
      final response = await _dio.post(
        'http://68.183.234.187:8080/api/v1/auth/nik',
        data: {
          'nik': nik,
          'password': password,
        },
      );

      if (response.statusCode == 401) {
        throw Exception('Failed to login: Invalid nik or password');
      }

      return response;
    } catch (e) {
      throw Exception('Failed to login: ${e.toString()}');
    }
  }

  Future<Response> loginByEmail(String email, String password) async {
    try {
      final response = await _dio.post(
        'http://68.183.234.187:8080/api/v1/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 401) {
        throw Exception('Failed to login: Invalid email or password');
      }

      return response;
    } catch (e) {
      throw Exception('Failed to login: ${e.toString()}');
    }
  }

  Future<Response> createAbsensi(
    String users,
    String absensiType,
    String time,
    String timeStart,
    String timeEnd,
    String latitude,
    String longitude,
    String description,
  ) async {
    try {
      final response = await _dio.post(
        'http://68.183.234.187:8080/api/v1/absension/create',
        data: {
          'users': users,
          'absensiType': absensiType,
          'time': time,
          'time_start': timeStart,
          'time_end': timeEnd,
          'latitude': latitude,
          'longitude': longitude,
          'description': description,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create absensi: ${response.statusMessage}');
      }

      return response;
    } catch (e) {
      throw Exception('Failed to create absensi: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> fetchUserProfile(String token) async {
    try {
      final response = await _dio.get(
        'http://68.183.234.187:8080/api/v1/auth/profile',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return response.data;
    } catch (error) {
      print('Error fetching profile: $error');
      throw error;
    }
  }
}
