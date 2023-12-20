import 'dart:convert';
import 'package:book_buddies_mobile/review/screens/review_form.dart';
import 'package:flutter/material.dart';
import 'package:book_buddies_mobile/widgets/left_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:book_buddies_mobile/review/models/review.dart';

class ShowReview extends StatefulWidget {
  const ShowReview({super.key});

  @override
  State<ShowReview> createState() => _ShowReviewState();
}

class _ShowReviewState extends State<ShowReview>
    with SingleTickerProviderStateMixin {
  Future<List<Review>> fetchProduct() async {
    var url = Uri.parse('http://127.0.0.1:8000/review/show_json_review/');
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
    return listProduct;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
      ),
      drawer: const LeftDrawer(),
      body: FutureBuilder(
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
                      style: TextStyle(color: Color(0xff59A5D8), fontSize: 20),
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
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${snapshot.data![index].fields.date}",
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Created by: ${snapshot.data![index].fields.user}",
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "${snapshot.data![index].fields.title}",
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 80.0, // Adjust the width
        height: 50.0, // Adjust the height
        child: FloatingActionButton(
          backgroundColor: Colors.red,
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => ReviewForm()));
          },
          child: const Icon(Icons.add, size: 40.0), // Adjust the icon size
          tooltip: "Add Review",
        ),
      ),
    );
  }
}
