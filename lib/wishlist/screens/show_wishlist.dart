import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:book_buddies_mobile/book/model.dart';
import 'package:book_buddies_mobile/widgets/left_drawer.dart';
import '../../user/models/user.dart';
import '../models/wishlist.dart';
import 'package:http/http.dart' as http;

enum FilterOptions {
  all,
  read,
  notRead,
}

class ShowWishlist extends StatefulWidget {
  const ShowWishlist({Key? key}) : super(key: key);

  @override
  ShowWishlistState createState() => ShowWishlistState();
}

class ShowWishlistState extends State<ShowWishlist> {
  FilterOptions _selectedFilter = FilterOptions.all; // Initially set to show all forums
  Map<int, Book> mapBook = {};
  User? _thisUser;

  @override
  void initState() {
    super.initState();
    fetchBooks().then((books) {
      setState(() {
        mapBook = books;
      });
    }).catchError((error) {
      print("Error fetching user data: $error");
      // Handle error appropriately, perhaps set _thisUser to a default value or handle UI accordingly
    });
    fetchUserData().then((user) {
      setState(() {
        _thisUser = user;
      });
    }).catchError((error) {
      print("Error fetching user data: $error");
      // Handle error appropriately, perhaps set _thisUser to a default value or handle UI accordingly
    });
  }

  Future<User> fetchUserData() async {
    final request = context.read<CookieRequest>();
    var responseJson =
    await request.get(('http://127.0.0.1:8000/user/fetch_user_data/'));

    if (responseJson != null && responseJson['user_data'] != null) {
      // Decode the JSON string inside 'user_data' field
      var userDataJson = json.decode(responseJson['user_data']);

      if (userDataJson.isNotEmpty && userDataJson is List) {
        // Parse the first user object in the list
        var user = User.fromJson(userDataJson.first);
        return user;
      } else {
        throw Exception('User data is empty or invalid');
      }
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<List<Wishlist>> fetchWishlist() async {
    var url = Uri.parse(
        'http://localhost:8000/wishlist/get_wishlist_json/');
    var response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    // melakukan decode response menjadi bentuk json
    var data = jsonDecode(utf8.decode(response.bodyBytes));

    // melakukan konversi data json menjadi object Product
    List<Wishlist> listWishlistAll = [];
    for (var d in data) {
      if (d != null) {
        listWishlistAll.add(Wishlist.fromJson(d));
      }
    }

    List<Wishlist> listWishlist = [];
    for (Wishlist wishlist in listWishlistAll) {
      if (wishlist.fields.user == _thisUser?.pk) {
        listWishlist.add(wishlist);
      }
    }

    List<Wishlist> listFilter = [];
    switch (_selectedFilter) {
      case FilterOptions.read:
        {
          for (Wishlist wishlist in listWishlist) {
            if (_thisUser!.fields.historyBooks!.contains(wishlist.fields.book)) {
              listFilter.add(wishlist);
            }
          }
        }
      case FilterOptions.notRead:
        {
          for (Wishlist wishlist in listWishlist) {
            if (!(_thisUser!.fields.historyBooks!.contains(wishlist.fields.book))) {
              listFilter.add(wishlist);
            }
          }
        }
      case FilterOptions.all:
        {
          for (Wishlist wishlist in listWishlist) {
            listFilter.add(wishlist);
          }
        }
    }
    return listFilter;
  }

  Future<Map<int, Book>> fetchBooks() async {
    var url = Uri.parse(
        'http://localhost:8000/book/get-book/');
    var response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    // melakukan decode response menjadi bentuk json
    var data = jsonDecode(utf8.decode(response.bodyBytes));

    // melakukan konversi data json menjadi object Product
    List<Book> listBook = [];
    for (var d in data) {
      if (d != null) {
        listBook.add(Book.fromJson(d));
      }
    }

    Map<int, Book> mapBook = {};
    for (Book book in listBook) {
      mapBook[book.pk] = book;
    }
    return mapBook;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
      ),
      drawer: const LeftDrawer(),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Radio(
                value: FilterOptions.all,
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value as FilterOptions;
                  });
                },
              ),
              const Text('All'),
              Radio(
                value: FilterOptions.read,
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value as FilterOptions;
                  });
                },
              ),
              const Text('Already read'),
              Radio(
                value: FilterOptions.notRead,
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value as FilterOptions;
                  });
                },
              ),
              const Text('Not read yet'),
            ],
          ),
          Expanded(
            child: FutureBuilder<List<Wishlist>>(
              future: fetchWishlist(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Wishlist wishlist = snapshot.data![index];
                      return Card(
                        elevation: 4.0,
                        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: ListTile(
                          leading: Image.network(
                            mapBook[wishlist.fields.book]!.fields.imageCover,
                            width: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                              // Log the error, show a placeholder, etc.
                              return Image.asset('assets/placeholder-image.png', width: 50, fit: BoxFit.cover);
                            },
                          ),
                          title: Text(mapBook[wishlist.fields.book]!.fields.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Author: ${mapBook[wishlist.fields.book]!.fields.author}'),
                              Text('Publisher: ${mapBook[wishlist.fields.book]!.fields.publisher}'),
                              Text('Year: ${mapBook[wishlist.fields.book]!.fields.yearPublication}'),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text('No wishlist found.'),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}