import 'package:book_buddies_mobile/user/models/user.dart';
import 'package:book_buddies_mobile/widgets/left_drawer.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key}) : super(key: key);

  final List<User> items = [ // edit kalau udah jadi

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Book Buddies',
        ),
      ),
      drawer: const LeftDrawer(),
      );
  }
}

