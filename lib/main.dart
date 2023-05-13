import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:venue_sercher/sech_venue_page.dart';

void main() async {
  await SentryFlutter.init(
    (option) {
      option.dsn =
          'https://ae5b62f603b14aaabc233576b61318b8@o4505174331228160.ingest.sentry.io/4505174341320704';
    },
    appRunner: () => runApp(const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Joyato',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SerchVenuePage(),
    );
  }
}
