import 'package:flutter/material.dart';
import 'package:venue_sercher/sech_venue_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '会場検索アプリ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SerchVenuePage(),
    );
  }
}
