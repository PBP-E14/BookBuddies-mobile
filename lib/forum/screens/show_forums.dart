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
}

class ShowForum extends StatefulWidget {
  const ShowForum({Key? key}) : super(key: key);

  @override
  ShowForumState createState() => ShowForumState();
}

class ShowForumState extends State<ShowForum> {
  FilterOptions _selectedFilter = FilterOptions.all; // Initially set to show all forums
  Map<int, User> mapUser = {};

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

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum'),
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
            ],
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
                            height: 150,
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