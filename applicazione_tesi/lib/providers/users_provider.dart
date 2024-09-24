import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../services/notification_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService;
  final NotificationService _notificationService;
  User? _user;

  UserProvider(this._userService, this._notificationService);

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  String? get currentName => _user?.name;
  String? get currentSurname => _user?.surname;

  Future<User?> login(String email, String password) async {
    try {
      final user = await _userService.login(email, password);
      if (user != null) {
        _user = user;
        notifyListeners();
      }
      return user;
    } catch (e) {
      print('Login fallito: $e');
      return null;
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }

  Future<int> createUser(User newUser) async {
    try {
      print('Creating user with data: ${newUser.toJson()}');
      final createdUser = await _userService.createUser(newUser);
      print('User created successfully: ${createdUser.toJson()}');
      _user = createdUser;
      notifyListeners();
      return createdUser.id ?? -1; // Ritorna -1 se l'ID è null
    } catch (e) {
      print('Creazione utente fallita: $e');
      rethrow;
    }
  }

  // Nuovo metodo per creare un utente senza effettuare il login
  Future<int> createUserWithoutLogin(User newUser) async {
    try {
      print('Creating user without login: ${newUser.toJson()}');
      final createdUser = await _userService.createUser(newUser);
      print('User created successfully: ${createdUser.toJson()}');
      return createdUser.id ?? -1;
    } catch (e) {
      print('Creazione utente fallita: $e');
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    if (_user != null && _user!.id != null) {
      try {
        await _userService.deleteUser(_user!.id!);
        logout();
      } catch (e) {
        print('Eliminazione account fallita: $e');
        // Gestisci il fallimento dell'eliminazione dell'account
      }
    }
  }

  Future<void> refreshUserData() async {
    if (_user != null && _user!.id != null) {
      try {
        final updatedUser = await _userService.getUserById(_user!.id!);
        _user = updatedUser;
        notifyListeners();
      } catch (e) {
        print('Aggiornamento dati utente fallito: $e');
        // Gestisci il fallimento dell'aggiornamento
      }
    }
  }

  Future<User> getUserByEmail(String email) async {
    try {
      return await _userService.getUser(email);
    } catch (e) {
      print('Recupero utente per email fallito: $e');
      rethrow;
    }
  }

  Future<User> getUserById(int userId) async {
    try {
      return await _userService.getUserById(userId);
    } catch (e) {
      print('Recupero utente per ID fallito: $e');
      rethrow;
    }
  }

  Future<void> deleteUserById(int userId) async {
    try {
      await _userService.deleteUser(userId);
      if (_user?.id == userId) {
        logout();
      }
    } catch (e) {
      print('Eliminazione utente fallita: $e');
      rethrow;
    }
  }

  Future<bool> changePasswordForUser(int userId, String currentPassword, String newPassword) async {
    try {
      return await _userService.changePassword(userId, currentPassword, newPassword);
    } catch (e) {
      print('Cambio password per utente fallito: $e');
      return false;
    }
  }

  Future<List<Notifications>> getNotificationsForCurrentUser() async {
      if (_user != null && _user!.id != null) {
        try {
          final notificationsData = await _notificationService.getNotificationsForUser(_user!.id!);
          return notificationsData.map((data) => Notifications.fromJson(data)).toList();
        } catch (e) {
          print('Failed to fetch notifications: $e');
          return [];
        }
      }
      return [];
    }

  Future<void> createNotification(Notifications notification) async {
    try {
      await _notificationService.createNotification(notification);
      notifyListeners();
    } catch (e) {
      print('Failed to create notification: $e');
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      notifyListeners();
    } catch (e) {
      print('Failed to delete notification: $e');
    }
  }

  Future<void> createNotificationForCurrentUser({
    required String title,
    required String message,
    required String type,
    int? postId,
    int? requesterId,
    String? status,
  }) async {
    if (_user != null && _user!.id != null) {
      final notification = Notifications(
        userId: _user!.id!,
        title: title,
        message: message,
        date: DateTime.now().toIso8601String(),
        type: type,
        postId: postId,
        requesterId: requesterId,
        status: status,
      );
      await createNotification(notification);
    }
  }
}