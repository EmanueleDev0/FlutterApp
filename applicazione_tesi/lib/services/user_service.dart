import 'package:http/http.dart' as http;
import 'dart:convert';

class UserService {
  final String baseUrl = 'http://localhost:3000/api/users';

  Future<User?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      return null; // Credenziali non valide
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<User> createUser(User user) async {
    try {
      print('Sending request to create user: ${user.toJson()}');
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(user.toJson()),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final decodedBody = json.decode(response.body);
        print('Decoded response body: $decodedBody');
        return User.fromJson(decodedBody);
      } else {
        throw Exception('Failed to create user: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in createUser: $e');
      rethrow;
    }
  }

  Future<User> getUser(String email) async {
    final response = await http.get(Uri.parse('$baseUrl/email/$email'));

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<User> getUserById(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/$userId'));

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<void> deleteUser(int userId) async {
    final response = await http.delete(Uri.parse('$baseUrl/$userId'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user');
    }
  }

  Future<bool> changePassword(int userId, String currentPassword, String newPassword) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$userId/change-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}

class User {
  final int? id;
  final String? name;
  final String? surname;
  final String? email;
  final String? password;
  final String? organization;

  User({
    this.id,
    this.name,
    this.surname,
    this.email,
    this.password,
    this.organization,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'email': email,
      'password': password,
      'organization': organization,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      surname: json['surname'],
      email: json['email'],
      password: json['password'],
      organization: json['organization'],
    );
  }
}