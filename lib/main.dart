import 'package:book_buddies_mobile/user/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
    Widget build(BuildContext context) {
        return Provider(
            create: (_) {
                CookieRequest request = CookieRequest();
                return request;
            },
            child: MaterialApp(
                title: 'My Wardrobe',
                theme: ThemeData(
                    colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
                    useMaterial3: true,
                ),
                home: const LoginPage()),
        ); 
    }
}