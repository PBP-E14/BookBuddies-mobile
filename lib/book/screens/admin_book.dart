import 'package:book_buddies_mobile/book/models/request_book.dart';
import 'package:book_buddies_mobile/book/widgets/book_page.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class AdminBookPage extends StatefulWidget {
  const AdminBookPage({Key? key}) : super(key: key);

  @override
  _AdminBooktate createState() => _AdminBooktate();
}

class _AdminBooktate extends State<AdminBookPage> {
  Future<List<RequestBook>> fetchRequestBook() async {
    final request = context.read<CookieRequest>();
    var response =
        await request.get('http://127.0.0.1:8000/book/get-all-request-book/');

    // melakukan konversi data json menjadi object Product
    List<RequestBook> listRequestBook = [];
    for (var d in response) {
      if (d != null && !d["fields"]["is_accepted"]) {
        listRequestBook.add(RequestBook.fromJson(d));
      }
    }
    return listRequestBook;
  }

  Future<void> acceptRequest(
      BuildContext context, AsyncSnapshot snapshot, int index) async {
    await http.get(
      Uri.parse(
          'http://127.0.0.1:8000/book/accept-request/${snapshot.data![index].pk}/'),
    );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Permintaan berhasil diterima!"),
    ));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => BookPage()),
    );
  }

  Future<void> declineRequest(
      BuildContext context, AsyncSnapshot snapshot, int index) async {
    await http.delete(
      Uri.parse(
          'http://127.0.0.1:8000/book/cancel-request/${snapshot.data![index].pk}/'),
    );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Permintaan berhasil ditolak!"),
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
            future: fetchRequestBook(),
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
                  return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (_, index) => Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Center(
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(12)),
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                // height: 100,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image(
                                        height: 300,
                                        image: NetworkImage(
                                            "${snapshot.data![index].fields.imageCover}"),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "${snapshot.data![index].fields.title}",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "by: ${snapshot.data![index].fields.author}",
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "publisher: ${snapshot.data![index].fields.publisher}",
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "year: ${snapshot.data![index].fields.yearPublication}",
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 10),
                                      ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.green),
                                          ),
                                          onPressed: () async {
                                            await acceptRequest(
                                                context, snapshot, index);
                                          },
                                          child: const Text(
                                            'Accepted Request',
                                            style:
                                                TextStyle(color: Colors.black),
                                          )),
                                      const SizedBox(height: 10),
                                      ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.red),
                                          ),
                                          onPressed: () async {
                                            await declineRequest(
                                                context, snapshot, index);
                                          },
                                          child: const Text(
                                            'Decline Request',
                                            style:
                                                TextStyle(color: Colors.black),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )));
                }
              }
            }));
  }
}
