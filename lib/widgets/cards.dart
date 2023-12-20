// ignore_for_file: use_build_context_synchronously

import 'package:book_buddies_mobile/book/widgets/book_page.dart';
import 'package:book_buddies_mobile/forum/screens/show_forums.dart';
import 'package:book_buddies_mobile/review/screens/show_review.dart';
import 'package:book_buddies_mobile/user/history_books.dart';
import 'package:book_buddies_mobile/user/profile.dart';
import 'package:book_buddies_mobile/wishlist/screens/show_wishlist.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../user/screens/login.dart';

class Item {
  final String name;
  final IconData icon;

  Item(this.name, this.icon);
}

class BookBuddiesCard extends StatelessWidget {
  final Item item;

  const BookBuddiesCard(this.item, {super.key}); // Constructor

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Material(
      color: Colors.redAccent,
      child: InkWell(
        // Area responsive terhadap sentuhan
        onTap: () async {
          // Memunculkan SnackBar ketika diklik
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
                content: Text("Kamu telah menekan tombol ${item.name}!")));

          // Navigate ke route yang sesuai (tergantung jenis tombol)
          if (item.name == "User Profile Page") {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ProfilePage()));
          } else if (item.name == "Book Page") {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const BookPage()));
          } else if (item.name == "User History Books") {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => BookHistoryPage()));
          } else if (item.name == "Forum") {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ShowForum()));
          } else if (item.name == "Wishlist") {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ShowWishlist()));
          } else if (item.name == "Review") {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ShowReview()));
          } else if (item.name == "Logout") {
            final response = await request.logout(
                "https://irfankamil.pythonanywhere.com/auth/logout/"); // Ganti URL
            String message = response["message"];
            if (response['status']) {
              String uname = response["username"];
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("$message Sampai jumpa, $uname."),
              ));
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("$message"),
              ));
            }
          }
        },
        child: Container(
          // Container untuk menyimpan Icon dan Text
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  color: Colors.white,
                  size: 30.0,
                ),
                const Padding(padding: EdgeInsets.all(3)),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
