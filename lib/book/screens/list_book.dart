import 'package:book_buddies_mobile/book/models/check_superuser.dart';
import 'package:book_buddies_mobile/book/models/processed_book.dart';
import 'package:book_buddies_mobile/book/widgets/book_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ListBookPage extends StatefulWidget {
  const ListBookPage({Key? key}) : super(key: key);

  @override
  _ListBookPageState createState() => _ListBookPageState();
}

class _ListBookPageState extends State<ListBookPage> {
  Future<Map<String, dynamic>> fetchBook() async {
    final request = context.read<CookieRequest>();

    var response = await request.get(
      'http://127.0.0.1:8000/book/get-book-flutter/',
    );

    // melakukan konversi data json menjadi object Product
    List<ProcessedBook> listBook = [];
    for (var d in response) {
      if (d != null) {
        listBook.add(ProcessedBook.fromJson(d));
      }
    }

    var responseSuperuser = await request.get(
      'http://127.0.0.1:8000/book/check-superuser/',
    );

    return {
      'isSuperuser': CheckSuperuser.fromJson(responseSuperuser),
      'listBook': listBook
    };
  }

  Future<void> readBook(
      BuildContext context, AsyncSnapshot snapshot, int index) async {
    final request = context.read<CookieRequest>();

    if (!snapshot.data["listBook"]![index].fields.isRead) {
      final http.Client _client = http.Client();
      dynamic c = _client;
      c.withCredentials = true;
      await _client.get(Uri.parse(
          'http://127.0.0.1:8000/book/read-book/${snapshot.data["listBook"]![index].pk}/'));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Ubahan tersimpan!"),
      ));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BookPage()),
      );
    }
  }

  Future<void> toogleWishlist(
      BuildContext context, AsyncSnapshot snapshot, int index) async {
    final request = context.read<CookieRequest>();

    if (!snapshot.data["listBook"]![index].fields.isWishlist) {
      await request.post(
          'http://127.0.0.1:8000/wishlist/create-ajax/${snapshot.data["listBook"]![index].pk}/',
          {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Buku sudah disimpan diwishlist!"),
      ));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BookPage()),
      );
    } else {
      final http.Client _client = http.Client();
      dynamic c = _client;
      c.withCredentials = true;
      await _client.delete(
        Uri.parse(
            'http://127.0.0.1:8000/wishlist/remove_wishlist/${snapshot.data["listBook"]![index].fields.wishlistPk}/'),
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Buku sudah dihapus dari diwishlist!"),
      ));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BookPage()),
      );
    }
  }

  Future<void> deleteBook(
      BuildContext context, AsyncSnapshot snapshot, int index) async {
    final http.Client _client = http.Client();
    dynamic c = _client;
    c.withCredentials = true;
    await _client.delete(
      Uri.parse(
          'http://127.0.0.1:8000/book/delete-book/${snapshot.data["listBook"]![index].pk}/'),
    );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Buku sudah dihapus!"),
    ));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => BookPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
            future: fetchBook(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return const Center(child: CircularProgressIndicator());
              } else {
                if (!snapshot.hasData) {
                  return const Column(
                    children: [
                      Text(
                        "Tidak ada data buku.",
                        style:
                            TextStyle(color: Color(0xff59A5D8), fontSize: 20),
                      ),
                      SizedBox(height: 8),
                    ],
                  );
                } else {
                  if (snapshot.data['isSuperuser'].isSuperuser) {
                    return ListView.builder(
                        itemCount: snapshot.data["listBook"]!.length,
                        itemBuilder: (_, index) => Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Center(
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12)),
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  // height: 100,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image(
                                          height: 300,
                                          image: NetworkImage(
                                              "${snapshot.data["listBook"]![index].fields.imageCover}"),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          "${snapshot.data["listBook"]![index].fields.title}",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "by: ${snapshot.data["listBook"]![index].fields.author}",
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "publisher: ${snapshot.data["listBook"]![index].fields.publisher}",
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "year: ${snapshot.data["listBook"]![index].fields.yearPublication}",
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 10),
                                        ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      snapshot
                                                              .data[
                                                                  "listBook"]![
                                                                  index]
                                                              .fields
                                                              .isWishlist
                                                          ? Colors.red
                                                          : Colors.yellow),
                                            ),
                                            onPressed: () async {
                                              await toogleWishlist(
                                                  context, snapshot, index);
                                            },
                                            child: Text(
                                              snapshot.data["listBook"]![index]
                                                      .fields.isWishlist
                                                  ? 'Remove From Wishlist'
                                                  : 'Add to Wishlist',
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            )),
                                        const SizedBox(height: 10),
                                        ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      snapshot
                                                              .data[
                                                                  "listBook"]![
                                                                  index]
                                                              .fields
                                                              .isRead
                                                          ? Colors.grey
                                                          : Colors.green),
                                            ),
                                            onPressed: () async {
                                              await readBook(
                                                  context, snapshot, index);
                                            },
                                            child: Text(
                                              snapshot.data["listBook"]![index]
                                                      .fields.isRead
                                                  ? 'Already Read'
                                                  : 'Read Book',
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            )),
                                        const SizedBox(height: 10),
                                        ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.red),
                                            ),
                                            onPressed: () async {
                                              await deleteBook(
                                                  context, snapshot, index);
                                            },
                                            child: const Text(
                                              'Delete Book',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )));
                  } else {
                    return ListView.builder(
                        itemCount: snapshot.data["listBook"]!.length,
                        itemBuilder: (_, index) => Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Center(
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12)),
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  // height: 100,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image(
                                          height: 300,
                                          image: NetworkImage(
                                              "${snapshot.data["listBook"]![index].fields.imageCover}"),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          "${snapshot.data["listBook"]![index].fields.title}",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "by: ${snapshot.data["listBook"]![index].fields.author}",
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "publisher: ${snapshot.data["listBook"]![index].fields.publisher}",
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "year: ${snapshot.data["listBook"]![index].fields.yearPublication}",
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 10),
                                        ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      snapshot
                                                              .data[
                                                                  "listBook"]![
                                                                  index]
                                                              .fields
                                                              .isWishlist
                                                          ? Colors.red
                                                          : Colors.yellow),
                                            ),
                                            onPressed: () async {
                                              await toogleWishlist(
                                                  context, snapshot, index);
                                            },
                                            child: Text(
                                              snapshot.data["listBook"]![index]
                                                      .fields.isWishlist
                                                  ? 'Remove From Wishlist'
                                                  : 'Add to Wishlist',
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            )),
                                        const SizedBox(height: 10),
                                        ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      snapshot
                                                              .data[
                                                                  "listBook"]![
                                                                  index]
                                                              .fields
                                                              .isRead
                                                          ? Colors.grey
                                                          : Colors.green),
                                            ),
                                            onPressed: () async {
                                              await readBook(
                                                  context, snapshot, index);
                                            },
                                            child: Text(
                                              snapshot.data["listBook"]![index]
                                                      .fields.isRead
                                                  ? 'Already Read'
                                                  : 'Read Book',
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )));
                  }
                }
              }
            }));
  }
}
