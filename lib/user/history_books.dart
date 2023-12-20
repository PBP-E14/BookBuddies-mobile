import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../book/model.dart';
import '../widgets/left_drawer.dart';
import 'models/user.dart';

class BookHistoryPage extends StatelessWidget {
  final List<int>? bookIds;

  BookHistoryPage({Key? key, this.bookIds}) : super(key: key);

  Future<List<Book>> fetchBooksDetails(CookieRequest request) async {
    List<Book> books = [];
    var bookDataJson = await request.get('https://irfankamil.pythonanywhere.com/book/get-read-book/');

    for (var bookJson in bookDataJson) {
      var book = Book.fromJson(bookJson); 
      books.add(book);
    }
    return books;
  }

  Future<User> fetchUserData(BuildContext context) async {
    final request = context.read<CookieRequest>();
    var response = await request.get('https://irfankamil.pythonanywhere.com/user/fetch_user_data/');

    // Check if the response was successful
    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);

      // Decode the JSON string inside 'user_data' field
      var userDataJson = json.decode(responseData['user_data']);

      // Check if the userDataJson is not empty and is a list
      if (userDataJson.isNotEmpty && userDataJson is List) {
        // Parse the first user object in the list
        var user = User.fromJson(userDataJson.first);
        return user;
      } else {
        throw Exception('User data is empty or invalid');
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
      body: FutureBuilder<List<Book>>(
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
                Book book = snapshot.data![index];
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