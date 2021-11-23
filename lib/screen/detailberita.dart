import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_uas_160418044/class/berita.dart';
import 'package:flutter_uas_160418044/screen/editberita.dart';
import 'package:http/http.dart' as http;

class DetailBerita extends StatefulWidget {
  final int idberita;
  DetailBerita({Key? key, required this.idberita}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _DetailBeritaState();
  }
}

class _DetailBeritaState extends State<DetailBerita> {
  var beritas;
  var _poster;
  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse(
            "https://ubaya.fun/flutter/160418044/flutter/uas/detailberita.php"),
        body: {'id': widget.idberita.toString()});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  Future<Widget> CheckImage() async {
    final response = await http.get(Uri.parse(
        "https://ubaya.fun/flutter/160418044/flutter/uas/images/" +
            widget.idberita.toString() +
            ".jpg"));
    if (response.statusCode == 200) {
      setState(() {
        _poster = Image.network(
            "https://ubaya.fun/flutter/160418044/flutter/uas/images/" +
                widget.idberita.toString() +
                ".jpg");
      });
    } else {
      setState(() {
        _poster = Image.network("https://ubaya.fun/blank.jpg");
      });
    }
    return _poster;
  }

  bacaData() {
    fetchData().then((value) {
      Map json = jsonDecode(value);
      beritas = Berita.fromJson(json['data']);
      setState(() {
        CheckImage();
      });
    });
  }

  onGoBack(dynamic value) {
    print("masuk goback");
    setState(() {
      bacaData();
    });
  }

  void deleteBerita() async {
    final response = await http.post(
        Uri.parse(
            "http://ubaya.fun/flutter/160418044/flutter/uas/deleteberita.php"),
        body: {'id': widget.idberita.toString()});
    if (response.statusCode == 200) {
      print(response.body);
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses menghapus berita')));
        setState(() {
          bacaData();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hapus Kategori Berita Terlebih Dahulu !')));
        setState(() {
          bacaData();
        });
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  void initState() {
    super.initState();
    bacaData();
    CheckImage();
  }

  Widget tampilData(BuildContext context) {
    if (beritas != null) {
      return Card(
          elevation: 10,
          margin: EdgeInsets.all(10),
          child: Column(children: <Widget>[
            Text(
              beritas.judul,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                beritas.tanggal,
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(padding: EdgeInsets.all(10), child: _poster),
            Padding(
                padding: EdgeInsets.all(10),
                child: Text(beritas.deskripsi, style: TextStyle(fontSize: 15))),
            Padding(padding: EdgeInsets.all(10), child: Text("Kategori:")),
            Padding(
                padding: EdgeInsets.all(10),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: beritas.kategoris.length,
                    itemBuilder: (BuildContext ctxt, int index) {
                      return new Text(beritas.kategoris[index]['nama']);
                    })),
            ElevatedButton(
                onPressed: () {
                  deleteBerita();
                  setState(() {
                    bacaData();
                  });
                },
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 24.0,
                )),
            Padding(
                padding: EdgeInsets.all(10),
                child: ElevatedButton(
                  child: Text('Edit'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditBerita(idberita: widget.idberita),
                      ),
                    ).then(onGoBack);
                  },
                )),
          ]));
    } else {
      return CircularProgressIndicator();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Berita'),
        ),
        body: ListView(children: <Widget>[tampilData(context)]));
  }
}
