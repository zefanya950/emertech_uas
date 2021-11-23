import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NewBerita extends StatefulWidget {
  @override
  NewBeritaState createState() {
    return NewBeritaState();
  }
}

class NewBeritaState extends State<NewBerita> {
  String _judul = "";
  String _penulis = "";
  String _deskripsi = "";
  final _controllerdate = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void submit() async {
    final response = await http.post(
        Uri.parse(
            "https://ubaya.fun/flutter/160418044/flutter/uas/newberita.php"),
        body: {
          'judul': _judul,
          'deskripsi': _deskripsi,
          'penulis': _penulis,
          'tanggal': _controllerdate.text,
        });
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses Menambah Data')));
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("New Berita"),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.all(10),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Judul',
                      ),
                      onChanged: (value) {
                        _judul = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'judul tidak boleh kosong';
                        }
                        return null;
                      },
                    )),
                Padding(
                    padding: EdgeInsets.all(10),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Penulis',
                      ),
                      onChanged: (value) {
                        _penulis = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'penulis tidak boleh kosong';
                        }
                        return null;
                      },
                    )),
                Padding(
                    padding: EdgeInsets.all(10),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi',
                      ),
                      onChanged: (value) {
                        _deskripsi = value;
                      },
                      validator: (value) {
                        if (value!.length < 10) {
                          return 'deskripsi minimal 10 karakter';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.multiline,
                      minLines: 3,
                      maxLines: 12,
                    )),
                Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Tanggal Berita',
                          ),
                          controller: _controllerdate,
                        )),
                        ElevatedButton(
                            onPressed: () {
                              showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2025))
                                  .then((value) {
                                setState(() {
                                  _controllerdate.text =
                                      value.toString().substring(0, 10);
                                });
                              });
                            },
                            child: Icon(
                              Icons.calendar_today_sharp,
                              color: Colors.white,
                              size: 24.0,
                            ))
                      ],
                    )),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Harap Isian diperbaiki')));
                      } else {
                        submit();
                      }
                    },
                    child: Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
