import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_uas_160418044/class/berita.dart';
import 'package:http/http.dart' as http;
import 'detailberita.dart';

class DaftarBerita extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DaftarBeritaState();
  }
}

class _DaftarBeritaState extends State<DaftarBerita> {
  String _temp = 'waiting API respond…';
  String _txtcari = '';

  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse(
            "https://ubaya.fun/flutter/160418044/flutter/uas/listberita.php"),
        body: {'cari': _txtcari});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  bacaData() {
    Beritas.clear();
    Future<String> data = fetchData();
    data.then((value) {
      Map json = jsonDecode(value);
      for (var mov in json['data']) {
        Berita pm = Berita.fromJson(mov);
        Beritas.add(pm);
      }
      setState(() {
        _temp = Beritas[2].judul;
      });
    });
  }

  Widget DaftarBerita(ListBeritas) {
    if (ListBeritas != null) {
      return ListView.builder(
          itemCount: ListBeritas.length,
          itemBuilder: (BuildContext ctxt, int index) {
            // ignore: unnecessary_new
            return new Card(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.format_align_left, size: 30),
                  title: GestureDetector(
                      child: Text(Beritas[index].judul),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailBerita(idberita: Beritas[index].id),
                          ),
                        );
                      }),
                  subtitle: Column(children: [
                    Text(ListBeritas[index].tanggal),
                  ]),
                ),
              ],
            ));
          });
    } else {
      return CircularProgressIndicator();
    }
  }

  @override
  void initState() {
    super.initState();
    bacaData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Daftar Berita')),
        body: ListView(children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              icon: Icon(Icons.search),
              labelText: 'Judul berita mengandung kata:',
            ),
            onFieldSubmitted: (value) {
              _txtcari = value;
              bacaData();
            },
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            child: DaftarBerita(Beritas),
          ),
        ]));
  }
}
