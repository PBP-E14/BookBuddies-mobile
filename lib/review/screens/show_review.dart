import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:book_buddies_mobile/widgets/left_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:book_buddies_mobile/review/models/review.dart';

class ShowReview extends StatefulWidget {
  const ShowReview({super.key});

  @override
  State<ShowReview> createState() => _ShowReviewState();
}

class _ShowReviewState extends State<ShowReview> {
  Future<List<Review>> fetchProduct() async {
    var url = Uri.parse('http://localhost:8000/review/show_json_review/');
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
          title: const Text('Review'),
        ),
        drawer: const LeftDrawer(),
        body: Expanded(
          child: FutureBuilder(
              future: fetchProduct(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.data == null) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  if (!snapshot.hasData) {
                    return const Column(
                      children: [
                        Text(
                          "No book has been reviewed yet",
                          style:
                              TextStyle(color: Color(0xff59A5D8), fontSize: 20),
                        ),
                        SizedBox(height: 8),
                      ],
                    );
                  } else {
                    return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (_, index) => Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${snapshot.data![index].fields.date}, created by ${snapshot.data![index].fields.user}",
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text("${snapshot.data![index].fields.title}"),
                                  const SizedBox(height: 10),
                                  Text(
                                      "${snapshot.data![index].fields.description.review}")
                                ],
                              ),
                            ));
                  }
                }
              }),
        ));
  }
}
