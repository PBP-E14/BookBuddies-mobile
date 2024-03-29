import 'package:book_buddies_mobile/book/widgets/book_page.dart';
import 'package:book_buddies_mobile/homepage.dart';
import 'package:book_buddies_mobile/review/screens/show_review.dart';
import 'package:book_buddies_mobile/user/history_books.dart';
import 'package:book_buddies_mobile/user/profile.dart';
import 'package:flutter/material.dart';
import 'package:book_buddies_mobile/forum/screens/show_forums.dart';
import 'package:book_buddies_mobile/wishlist/screens/show_wishlist.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.redAccent,
            ),
            child: Column(
              children: [
                Text(
                  'Book Buddies',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Padding(padding: EdgeInsets.all(10)),
                Text(
                  "Your go to book app!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color.fromRGBO(255, 205, 210, 1),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Halaman Utama'),
            // Bagian redirection ke MyHomePage
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(),
                  ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_rounded),
            title: const Text('Book Page'),
            // Bagian redirection ke ListBookPage
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BookPage(),
                  ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_circle_rounded),
            title: const Text('User Profile Page'),
            // Bagian redirection ke MyHomePage
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(),
                  ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.book_rounded),
            title: const Text('User History Books'),
            // Bagian redirection ke MyHomePage
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookHistoryPage(),
                  ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.forum_rounded),
            title: const Text('Forum'),
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShowForum(),
                  ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.star_border_purple500_rounded),
            title: const Text('Wishlist'),
            // Bagian redirection ke MyHomePage
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShowWishlist(),
                  ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.reviews),
            title: const Text('Review'),
            onTap: () {
              // Route menu ke halaman produk
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShowReview()),
              );
            },
          ),
        ],
      ),
    );
  }
}
