import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:book_buddies_mobile/widgets/left_drawer.dart';
import 'package:book_buddies_mobile/forum/screens/show_reply.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:book_buddies_mobile/widgets/cards.dart';

import '../../user/models/user.dart';
import '../models/forum.dart';
import '../models/reply.dart';

class ReplyFormPage extends StatefulWidget {
  final int forumId;
  const ReplyFormPage({Key? key, required this.forumId}) : super(key: key);

  @override
  State<ReplyFormPage> createState() => _ReplyFormPageState();
}

List<Reply> replies = [];

class _ReplyFormPageState extends State<ReplyFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _content = "";
  User? _thisUser;

  @override
  void initState() {
    super.initState();
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
    await request.get(('https://irfankamil.pythonanywhere.com/user/fetch_user_data/'));

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
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReplyPage(forumId: widget.forumId),
                  ));
            },
          ),
        ],
        title: const Text('Reply'),
      ),
      drawer: const LeftDrawer(),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Create a New Reply',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 350, // Adjust the width of the box
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey), // Add a border for the box
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min, // Allow the column to occupy minimum space
                  children: [
                    TextFormField(
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: "Content",
                        labelText: "Content",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onChanged: (String value) {
                        setState(() {
                          _content = value;
                        });
                      },
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "Content tidak boleh kosong!";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.indigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        minimumSize: Size(double.infinity, 40), // Adjust button height
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // Kirim ke Django dan tunggu respons
                          final response = await request.postJson(
                            "https://irfankamil.pythonanywhere.com/forum/create-reply-flutter/",
                            jsonEncode(<String, String?>{
                              'thisUser': _thisUser?.pk.toString(),
                              'content': _content,
                              'thisForum': widget.forumId.toString(),
                            }),
                          );
                          if (response['status'] == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Forum baru berhasil disimpan!"),
                              ),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReplyPage(forumId: widget.forumId),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Terdapat kesalahan, silakan coba lagi."),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
