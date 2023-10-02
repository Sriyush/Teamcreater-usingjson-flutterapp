import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heliverse/users/homescreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Heliverse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        useMaterial3: true,
      ),
      initialRoute: '/',
          routes: {
            '/': (context) => HomeScreen(),
          },
    );
  }
}

