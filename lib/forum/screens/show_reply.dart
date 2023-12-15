import 'dart:convert';

import 'package:book_buddies_mobile/forum/models/reply.dart';
import 'package:book_buddies_mobile/forum/screens/show_forums.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  @override
  void initState() {
    super.initState();
    replies = fetchReplies();
    thisForum = fetchForum();
    
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
                              'Posted by: ${forum.fields.user}',
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                // Logic to add a reply goes here
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
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(replyList[index].fields.content),
                            subtitle: Text(
                              'Replied by: ${replyList[index].fields.user} - Replied on: ${replyList[index].fields.createdAt.day.toString().padLeft(2, '0')}/${replyList[index].fields.createdAt.month.toString().padLeft(2, '0')}/${replyList[index].fields.createdAt.year.toString().padLeft(4, '0')}'
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                // Logic to delete a reply goes here
                              },
                            ),
                          ),
                        );
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

