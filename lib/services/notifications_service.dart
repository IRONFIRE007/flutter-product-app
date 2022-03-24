import 'package:flutter/material.dart';

class NotificationsService {
  static GlobalKey<ScaffoldMessengerState> messageKey =
      new GlobalKey<ScaffoldMessengerState>();

  static showSnackbar(String message) {
    final snackBar = new SnackBar(
      content:
          Text(message, style: TextStyle(color: Colors.white, fontSize: 20)),
    );

    messageKey.currentState!.showSnackBar(snackBar);
  }
}
