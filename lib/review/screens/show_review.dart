import 'dart:convert';
import 'package:book_buddies_mobile/review/screens/review_form.dart';
import 'package:flutter/material.dart';
import 'package:book_buddies_mobile/widgets/left_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:book_buddies_mobile/review/models/review.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../../user/models/user.dart';

enum FilterOptions {
  allReview,
  yourReview,
}

class ShowReview extends StatefulWidget {
  const ShowReview({super.key});

  @override
  State<ShowReview> createState() => _ShowReviewState();
}

class _ShowReviewState extends State<ShowReview> {
  FilterOptions _selectedFilter = FilterOptions.allReview;
  Map<int, User> mapUser = {};
  User? _thisUser;

  @override
  void initState() {
    super.initState();
    fetchUsers().then((users) {
      setState(() {
        mapUser = users;
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

  Future<List<Review>> fetchProduct() async {
    var url = Uri.parse(
        'https://irfankamil.pythonanywhere.com/review/show_json_review/');
    var response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    var data = jsonDecode(utf8.decode(response.bodyBytes));

    List<Review> listProduct = [];
    for (var d in data) {
      if (d != null) {
        listProduct.add(Review.fromJson(d));
      }
    }

    List<Review> listReview = [];
    switch (_selectedFilter) {
      case FilterOptions.allReview:
        {
          for (Review review in listProduct) {
            listReview.add(review);
          }
        }
        break;
      case FilterOptions.yourReview:
        {
          for (Review review in listProduct) {
            if (review.fields.user == _thisUser!.pk) {
              listReview.add(review);
            }
          }
        }
        break;
    }
    return listReview;
  }

  Future<Map<int, User>> fetchUsers() async {
    var url = Uri.parse('http://localhost:8000/user/json/');
    var response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    var data = jsonDecode(utf8.decode(response.bodyBytes));

    List<User> listProduct = [];
    for (var d in data) {
      if (d != null) {
        listProduct.add(User.fromJson(d));
      }
    }

    Map<int, User> mapUser = {};
    for (User user in listProduct) {
      mapUser[user.pk] = user;
    }
    return mapUser;
  }

  Future<User> fetchUserData() async {
    final request = context.read<CookieRequest>();
    var responseJson = await request
        .get(('https://irfankamil.pythonanywhere.com/user/fetch_user_data/'));

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
      ),
      drawer: const LeftDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ToggleButtons(
                borderRadius: BorderRadius.circular(18),
                children: [
                  Container(
                      width: 100,
                      child: Align(
                          alignment: Alignment.center,
                          child: Text("All Review"))),
                  Container(
                      width: 100,
                      child: Align(
                          alignment: Alignment.center,
                          child: Text("Your Review"))),
                ],
                onPressed: (int index) {
                  setState(() {
                    for (int buttonIndex = 0;
                        buttonIndex < _selectedFilterValues.length;
                        buttonIndex++) {
                      if (buttonIndex == index) {
                        _selectedFilterValues[buttonIndex] = true;
                      } else {
                        _selectedFilterValues[buttonIndex] = false;
                      }
                    }
                    _selectedFilter = index == 0
                        ? FilterOptions.allReview
                        : FilterOptions.yourReview;
                  });
                },
                isSelected: _selectedFilterValues,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: fetchProduct(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  if (!snapshot.hasData || snapshot.data.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "No reviews available yet",
                            style: TextStyle(
                              color: Color(0xff59A5D8),
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (_, index) => Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${snapshot.data![index].fields.title}",
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${snapshot.data![index].fields.date.day.toString().padLeft(2, '0')}-${snapshot.data![index].fields.date.month.toString().padLeft(2, '0')}-${snapshot.data![index].fields.date.year.toString().padLeft(4, '0')}",
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Created by: ",
                                        style: const TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        "${mapUser[snapshot.data![index].fields.user]?.fields.username}",
                                        style: const TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                height: 2,
                                color: Colors.grey, // Set the divider color
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "${snapshot.data![index].fields.review}",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SizedBox(
        width: 80.0, // Adjust the width
        height: 50.0, // Adjust the height
        child: FloatingActionButton(
          backgroundColor: Colors.red,
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => ReviewForm()));
          },
          child: const Icon(Icons.create_rounded,
              size: 40.0), // Adjust the icon size
          tooltip: "Add Review",
        ),
      ),
    );
  }

  List<bool> _selectedFilterValues = [
    true,
    false
  ]; // Initialize with "All Review" selected
}
