import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:book_buddies_mobile/book/model.dart';
import 'package:book_buddies_mobile/widgets/left_drawer.dart';
import '../models/wishlist.dart';

class WishlistPage extends StatelessWidget {
  final List<int>? bookIds;

  WishlistPage({Key? key, this.bookIds}) : super(key: key);

  Future<List<Wishlist>> fetchBooksDetails(CookieRequest request) async {
    List<Wishlist> books = [];
    var bookDataJson = await request.get('http://127.0.0.1:8000/wishlist/get_wishlist_json/');
    print('Received JSON: $bookDataJson');

    for (var bookJson in bookDataJson) {
      print('Parsing book: $bookJson');
      var book = Wishlist.fromJson(bookJson); // Ensure this method matches your JSON structure
      books.add(book);
    }
    return books;
  }

  Future<Wishlist> fetchBookData(BuildContext context) async {
    final request = context.read<CookieRequest>();
    var response = await request.get('http://127.0.0.1:8000/user/fetch_user_data/');

    // Check if the response was successful
    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);

      // Decode the JSON string inside 'user_data' field
      var userDataJson = json.decode(responseData['user_data']);

      // Check if the userDataJson is not empty and is a list
      if (userDataJson.isNotEmpty && userDataJson is List) {
        // Parse the first user object in the list
        var user = Wishlist.fromJson(userDataJson.first);
        return user;
      } else {
        throw Exception('Book data is empty or invalid');
      }
    } else {
      throw Exception('Failed to load user data with status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.read<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: Text('User Book History'),
      ),
      drawer: const LeftDrawer(),
      body: FutureBuilder<List<Wishlist>>(
        future: fetchBooksDetails(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Wishlist book = snapshot.data![index];
                return Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: ListTile(
                    leading: Image.network(
                      book.fields.imageCover,
                      width: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                        // Log the error, show a placeholder, etc.
                        return Image.asset('assets/placeholder-image.png', width: 50, fit: BoxFit.cover);
                      },
                    ),
                    title: Text(book.fields.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Author: ${book.fields.author}'),
                        Text('Publisher: ${book.fields.publisher}'),
                        Text('Year: ${book.fields.yearPublication}'),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text('No books found.'),
            );
          }
        },
      ),
    );
  }
}