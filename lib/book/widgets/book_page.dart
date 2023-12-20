import 'package:book_buddies_mobile/book/models/check_superuser.dart';
import 'package:book_buddies_mobile/book/screens/admin_book.dart';
import 'package:book_buddies_mobile/book/screens/list_book.dart';
import 'package:book_buddies_mobile/book/screens/list_request_book.dart';
import 'package:book_buddies_mobile/book/screens/request_form.dart';
import 'package:book_buddies_mobile/widgets/left_drawer.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  int _selectedIndex = 1;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    ListRequestBookPage(),
    ListBookPage(),
    RequestFormPage(),
    AdminBookPage(),
  ];

  get http => null;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<CheckSuperuser> checkUser() async {
    final request = context.read<CookieRequest>();

    var response = await request.get(
      'https://irfankamil.pythonanywhere.com/book/check-superuser/',
    );

    return CheckSuperuser.fromJson(response);
  }

  late Future<CheckSuperuser> _isSuperuser;
  bool _dataFetched = false;

  @override
  void initState() {
    super.initState();
    if (!_dataFetched) {
      _isSuperuser = checkUser();
      _dataFetched = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Book'),
      ),
      drawer: const LeftDrawer(),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: FutureBuilder<CheckSuperuser>(
        future: _isSuperuser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            if (snapshot.data?.isSuperuser == true) {
              return BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.history),
                    label: 'History',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.menu_book_rounded),
                    label: 'Books',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.add_box_rounded),
                    label: 'Request',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Admin',
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: Colors.amber[800],
                unselectedItemColor: Colors.black,
                unselectedLabelStyle: const TextStyle(color: Colors.black),
                onTap: _onItemTapped,
              );
            } else {
              return BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.history),
                    label: 'History',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.menu_book_rounded),
                    label: 'Books',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.add_box_rounded),
                    label: 'Request',
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: Colors.amber[800],
                unselectedItemColor: Colors.black,
                unselectedLabelStyle: const TextStyle(color: Colors.black),
                onTap: _onItemTapped,
              );
            }
          } else {
            return const Text('No data');
          }
        },
      ),
    );
  }
}
