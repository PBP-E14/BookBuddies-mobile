import 'dart:convert';

import 'package:book_buddies_mobile/forum/models/reply.dart';
import 'package:book_buddies_mobile/forum/screens/reply_forum.dart';
import 'package:book_buddies_mobile/forum/screens/show_forums.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../../user/models/user.dart';
import '../../widgets/left_drawer.dart';
import '../models/forum.dart';

class ReplyPage extends StatefulWidget {
  final int forumId;
  const ReplyPage({Key? key, required this.forumId}) : super(key: key);

  @override
  _ReplyPageState createState() => _ReplyPageState();
}

class _ReplyPageState extends State<ReplyPage> {
  late Future<List<Reply>> replies;
  late Future<Forum?> thisForum;
  late final User user;
  Map<int, User> mapUser = {};
  User? _thisUser;
  bool? isAdmin;

  @override
  void initState() {
    super.initState();
    replies = fetchReplies();
    thisForum = fetchForum();
    fetchUserData().then((user) {
      setState(() {
        _thisUser = user;
      });
    }).catchError((error) {
      print("Error fetching user data: $error");
      // Handle error appropriately, perhaps set _thisUser to a default value or handle UI accordingly
    });
    fetchUsers().then((users) {
      setState(() {
        mapUser = users;
      });
    }).catchError((error) {
      print("Error fetching user data: $error");
      // Handle error appropriately, perhaps set _thisUser to a default value or handle UI accordingly
    });
    getUserAdminStatus().then((users) {
      setState(() {
        isAdmin = users;
      });
    }).catchError((error) {
      print("Error fetching user data: $error");
      // Handle error appropriately, perhaps set _thisUser to a default value or handle UI accordingly
    });
  }

  Future<Map<String, dynamic>> fetchUserAdminStatus() async {
    // Replace 'your_server_url' with your actual server URL
    var url = Uri.parse('https://your_server_url/user_admin_status');

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

  Future<Forum?> fetchForum() async {
    var url = Uri.parse(
        'http://localhost:8000/forum/show_json_forum/');
    var response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    // melakukan decode response menjadi bentuk json
    var data = jsonDecode(utf8.decode(response.bodyBytes));

    // melakukan konversi data json menjadi object Product
    List<Forum> listProduct = [];
    for (var d in data) {
      if (d != null) {
        listProduct.add(Forum.fromJson(d));
      }
    }

    for (Forum forum in listProduct) {
      if (forum.pk == widget.forumId) {
        return forum;
      }
    }
    return null;
  }

  Future<List<Reply>> fetchReplies() async {
    var url = Uri.parse(
        'http://localhost:8000/forum/show_json_reply/');
    var response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    // melakukan decode response menjadi bentuk json
    var data = jsonDecode(utf8.decode(response.bodyBytes));

    // melakukan konversi data json menjadi object Product
    List<Reply> listProduct = [];
    for (var d in data) {
      if (d != null) {
        listProduct.add(Reply.fromJson(d));
      }
    }

    List<Reply> listReply = [];
    for (Reply reply in listProduct) {
      if (reply.fields.forumId == widget.forumId) {
        listReply.add(reply);
      }
    }
    return listReply;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShowForum(),
                  ));
            },
          ),
        ],
        title: const Text('Forum'),
      ),
      drawer: const LeftDrawer(),
      body: FutureBuilder<List<Reply>>(
        future: replies,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Reply> replyList = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Forum details section
                    FutureBuilder<Forum?>(
                      future: thisForum,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          Forum? forum = snapshot.data!;
                          return ListTile(
                            title: Text(
                              forum.fields.title ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24.0,
                              ),
                            ),
                            subtitle: Text(
                              'Posted by: ${mapUser[forum.fields.user]?.fields.username}',
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ReplyFormPage(forumId: widget.forumId)
                                ));
                              },
                              child: Text('Reply'),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }
                        return CircularProgressIndicator();
                      },
                    ),
                    const Divider(
                      thickness: 1, // Adjust the thickness as needed
                      color: Colors.grey, // Define the color of the divider
                    ),
                    FutureBuilder<Forum?>(
                      future: thisForum,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          Forum? forum = snapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                thisForum != null ? forum.fields.content ?? '' : '',
                                  style: TextStyle(fontSize: 16.0),
                              ),
                              Container(
                                width: double.infinity, // Ensure the container takes the full width
                                child: Text(
                                  'Posted On: ${forum.fields.createdAt.day.toString().padLeft(2, '0')}/${forum.fields.createdAt.month.toString().padLeft(2, '0')}/${forum.fields.createdAt.year.toString().padLeft(4, '0')}',
                                  style: TextStyle(fontSize: 12.0),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ]
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }
                        return CircularProgressIndicator();
                      },
                    ),
                    const Divider(
                      thickness: 1, // Adjust the thickness as needed
                      color: Colors.grey, // Define the color of the divider
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      '${replyList.length} Replies',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    // Displaying replies
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: replyList.length,
                      itemBuilder: (context, index) {
                        if (_thisUser?.pk == mapUser[replyList[index].fields.user]?.pk) {
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(replyList[index].fields.content),
                              subtitle: Text(
                                  'Replied by: ${mapUser[replyList[index].fields.user]?.fields.username} (You) - Replied on: ${replyList[index].fields.createdAt.day.toString().padLeft(2, '0')}/${replyList[index].fields.createdAt.month.toString().padLeft(2, '0')}/${replyList[index].fields.createdAt.year.toString().padLeft(4, '0')}'
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  // Logic to delete a reply goes here
                                },
                              ),
                            ),
                          );
                        } else {
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(replyList[index].fields.content),
                              subtitle: Text(
                                  'Replied by: ${mapUser[replyList[index].fields.user]?.fields.username} - Replied on: ${replyList[index].fields.createdAt.day.toString().padLeft(2, '0')}/${replyList[index].fields.createdAt.month.toString().padLeft(2, '0')}/${replyList[index].fields.createdAt.year.toString().padLeft(4, '0')}'
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

