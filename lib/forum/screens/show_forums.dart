import 'package:book_buddies_mobile/forum/screens/forum_form.dart';
import 'package:book_buddies_mobile/forum/screens/show_reply.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:book_buddies_mobile/forum/models/forum.dart';
import 'package:book_buddies_mobile/widgets/left_drawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../../user/models/user.dart';

enum FilterOptions {
  all,
  replied,
  notReplied,
  yourForum,
}

class ShowForum extends StatefulWidget {
  const ShowForum({Key? key}) : super(key: key);

  @override
  ShowForumState createState() => ShowForumState();
}

class ShowForumState extends State<ShowForum> {
  FilterOptions _selectedFilter = FilterOptions.all; // Initially set to show all forums
  Map<int, User> mapUser = {};
  User? _thisUser;
  bool? isAdmin;

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

  void deleteForum(int forumId) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/forum/delete-forum-flutter/');

    var response = await http.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'forum_id': forumId,
      }),
    );

    if (response.statusCode == 204) {
      // Handle successful deletion
      setState(() {
        fetchProduct(); // Refresh the forum list after deletion
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Forum deleted successfully')),
      );
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete Forum: ${response.body}')),
      );
    }
  }

  Future<List<Forum>> fetchProduct() async {
    var url = Uri.parse(
        'http://localhost:8000/forum/show_json_forum/');
    var response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    // melakukan decode response menjadi bentuk json
    var data = jsonDecode(utf8.decode(response.bodyBytes));

    // melakukan konversi data json menjadi object Product
    List<Forum> listForum = [];
    for (var d in data) {
      if (d != null) {
        listForum.add(Forum.fromJson(d));
      }
    }

    List<Forum> listProduct = [];
    switch (_selectedFilter) {
      case FilterOptions.replied:
        {
          for (Forum forum in listForum) {
            if (forum.fields.totalReply > 0) {
              listProduct.add(forum);
            }
          }
        }
      case FilterOptions.notReplied:
        {
          for (Forum forum in listForum) {
            if (forum.fields.totalReply == 0) {
              listProduct.add(forum);
            }
          }
        }
      case FilterOptions.all:
        {
          for (Forum forum in listForum) {
            listProduct.add(forum);
          }
        }
      case FilterOptions.yourForum:
        for (Forum forum in listForum) {
          if (forum.fields.user == _thisUser!.pk) {
            listProduct.add(forum);
          }
        }
    }
    return listProduct;
  }

  Future<Map<int, User>> fetchUsers() async {
    var url = Uri.parse(
        'http://localhost:8000/user/json/');
    var response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    // melakukan decode response menjadi bentuk json
    var data = jsonDecode(utf8.decode(response.bodyBytes));

    // melakukan konversi data json menjadi object Product
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

  Future<Map<String, dynamic>> fetchUserAdminStatus() async {
    // Replace 'your_server_url' with your actual server URL
    var url = Uri.parse('http://127.0.0.1:8000/user/user_admin_status/${_thisUser?.pk}/');
    // Make a GET request to the server
    var response = await http.get(url);

    if (response.statusCode == 200) {
      // If the server returns a successful response, parse the JSON
      Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      // If the server returns an error response, throw an exception
      throw Exception('Failed to fetch user admin status');
    }
  }

  Future<bool> getUserAdminStatus() async {
    try {
      Map<String, dynamic> userData = await fetchUserAdminStatus();
      bool isAdmin = userData['is_admin'];
      return isAdmin;
      // Use the isAdmin value as needed
    } catch (e) {
      return false;
      // Handle errors if any
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final isSmallScreen = MediaQuery.of(context).size.width < 600; // Define a threshold for small screens

    getUserAdminStatus().then((admin) {
      setState(() {
        isAdmin = admin;
      });
    }).catchError((error) {
      print("Error fetching user data: $error");
      // Handle error appropriately, perhaps set _thisUser to a default value or handle UI accordingly
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum'),
      ),
      drawer: const LeftDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Forum Discussion',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
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
                      value: FilterOptions.replied,
                      groupValue: _selectedFilter,
                      onChanged: (value) {
                        setState(() {
                          _selectedFilter = value as FilterOptions;
                        });
                      },
                    ),
                    const Text('Replied'),
                    Radio(
                      value: FilterOptions.notReplied,
                      groupValue: _selectedFilter,
                      onChanged: (value) {
                        setState(() {
                          _selectedFilter = value as FilterOptions;
                        });
                      },
                    ),
                    const Text('No Reply'),
                    Radio(
                      value: FilterOptions.yourForum,
                      groupValue: _selectedFilter,
                      onChanged: (value) {
                        setState(() {
                          _selectedFilter = value as FilterOptions;
                        });
                      },
                    ),
                    const Text('Your Forum'),
                  ],
                ),
              ],
            ),
          ),
          const Divider(
            thickness: 1,
            // Adjust the thickness as needed
            color: Colors
                .black, // Define the color of the divider
          ),
          Expanded(
            child: FutureBuilder(
              future: fetchProduct(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.data == null) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  if (snapshot.data!.isEmpty) {
                    return Column(
                      children: [
                        const Text(
                          "Belum ada forum.",
                          style:
                          TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ForumFormPage()
                                ));
                              },
                              child: Text('Add Forum'),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length + 1, // +1 for the button
                      itemBuilder: (context, index) {
                        if (index == snapshot.data!.length) {
                          // Return a button for the last item in the list
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8.0),
                            // Adjust vertical padding
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => ForumFormPage()
                                      ));
                                    },
                                    child: Text('Add Forum'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        else {
                          return Container(
                            height: 160,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFFE0E0E0)),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ReplyPage(
                                      forumId: snapshot.data![index].pk),
                                ));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "${snapshot.data![index].fields
                                                .title}",
                                            style: const TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Text("Total Reply: ${snapshot
                                            .data![index].fields.totalReply}"),
                                        const SizedBox(width: 10, height: 0,),
                                        Visibility(
                                          visible: isAdmin!,
                                          child: IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () {
                                              setState(() {
                                                deleteForum(snapshot.data![index].pk);
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(
                                      thickness: 1,
                                      // Adjust the thickness as needed
                                      color: Colors
                                          .grey, // Define the color of the divider
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                        "Posted by ${mapUser[snapshot.data![index]
                                            .fields.user]?.fields.username} at ${snapshot
                                            .data![index]
                                            .fields.createdAt.day.toString()
                                            .padLeft(2, '0')}/${snapshot
                                            .data![index].fields.createdAt.month
                                            .toString().padLeft(
                                            2, '0')}/${snapshot.data![index]
                                            .fields.createdAt.year.toString()
                                            .padLeft(4, '0')}"),
                                    const SizedBox(height: 10),
                                    Text(
                                      "${snapshot.data![index].fields.content}",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}