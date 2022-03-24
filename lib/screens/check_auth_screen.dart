import 'package:flutter/material.dart';
import 'package:product_app/screens/screens.dart';
import 'package:product_app/services/services.dart';
import 'package:provider/provider.dart';

class CheckAuthScreenScreen extends StatelessWidget {
  const CheckAuthScreenScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      body: Center(
          child: FutureBuilder(
              future: authService.readToken(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (!snapshot.hasData) return const Text('Awaiting');

                if (snapshot.hasData.toString() == '') {
                  Future.microtask(() {
                    Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const LoginScreen(),
                            transitionDuration: const Duration(seconds: 0)));
                  });
                } else {
                  Future.microtask(() {
                    Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const HomeScreen(),
                            transitionDuration: const Duration(seconds: 0)));
                  });
                }

                return Container();
              })),
    );
  }
}
