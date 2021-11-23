import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_uas_160418044/class/berita.dart';
import 'package:flutter_uas_160418044/class/kategori.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../main.dart';

class EditBerita extends StatefulWidget {
  int idberita;
  EditBerita({Key? key, required this.idberita}) : super(key: key);
  @override
  EditBeritaState createState() {
    return EditBeritaState();
  }
}

class EditBeritaState extends State<EditBerita> {
  final _formKey = GlobalKey<FormState>();

  File? _image = null;
  File? _imageProses = null;

  Berita beritas = new Berita(
      id: 0,
      judul: "title",
      deskripsi: "homepage",
      tanggal: "01-01-2000",
      penulis: "penulis",
      kategoris: []);
  TextEditingController _judulCont = new TextEditingController();
  TextEditingController _deskripsiCont = new TextEditingController();
  TextEditingController _penulisCont = new TextEditingController();
  TextEditingController _tanggalCont = new TextEditingController();

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

  void submit() async {
    print(beritas.judul);
    print(beritas.deskripsi);
    print(beritas.penulis);
    print(beritas.tanggal);
    print(widget.idberita.toString());
    final response = await http.post(
        Uri.parse(
            "https://ubaya.fun/flutter/160418044/flutter/uas/updateberita.php"),
        body: {
          'judul': beritas.judul,
          'deskripsi': beritas.deskripsi,
          'penulis': beritas.penulis,
          'tanggal': beritas.tanggal,
          'idberita': widget.idberita.toString()
        });
    if (response.statusCode == 200) {
      print(response.body);
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses mengubah Data')));
      }
    } else {
      throw Exception('Failed to read API');
    }
    List<int> imageBytes = _imageProses!.readAsBytesSync();
    print(imageBytes);
    String base64Image = base64Encode(imageBytes);
    final response2 = await http.post(
        Uri.parse(
          'https://ubaya.fun/flutter/160418044/flutter/uas/uploadberitaposter.php',
        ),
        body: {
          'idberita': widget.idberita.toString(),
          'image': base64Image,
        });
    if (response2.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(response2.body)));
    }
  }

  bacaData() {
    fetchData().then((value) {
      Map json = jsonDecode(value);
      beritas = Berita.fromJson(json['data']);
      setState(() {
        _judulCont.text = beritas.judul;
        _deskripsiCont.text = beritas.deskripsi;
        _penulisCont.text = beritas.penulis;
        _tanggalCont.text = beritas.tanggal;
      });
    });
  }

  Future<List> daftarKategori() async {
    Map json;
    final response = await http.post(
        Uri.parse(
            "https://ubaya.fun/flutter/160418044/flutter/uas/kategorilist.php"),
        body: {'idberita': widget.idberita.toString()});
    if (response.statusCode == 200) {
      print(response.body);
      json = jsonDecode(response.body);
      return json['data'];
    } else {
      throw Exception('Failed to read API');
    }
  }

  Widget comboKategori = Text('tambah kategori');

  void generatecomboKategori() {
    //widget function for city list
    List<Kategori> kategoris;
    var data = daftarKategori();
    data.then((value) {
      kategoris = List<Kategori>.from(value.map((i) {
        return Kategori.fromJSON(i);
      }));

      comboKategori = DropdownButton(
          dropdownColor: Colors.grey[100],
          hint: Text("tambah kategori"),
          isDense: false,
          items: kategoris.map((kat) {
            return DropdownMenuItem(
              child: Column(children: <Widget>[
                Text(kat.nama, overflow: TextOverflow.visible),
              ]),
              value: kat.idkategori,
            );
          }).toList(),
          onChanged: (value) {
            addKategori(value);
          });
    });
  }

  void addKategori(idkategori) async {
    final response = await http.post(
        Uri.parse(
            "https://ubaya.fun/flutter/160418044/flutter/uas/addkategori.php"),
        body: {
          'idkategori': idkategori.toString(),
          'idberita': widget.idberita.toString()
        });
    if (response.statusCode == 200) {
      print(response.body);
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses menambah kategori')));
        setState(() {
          bacaData();
        });
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              color: Colors.white,
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      tileColor: Colors.white,
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Galeri'),
                      onTap: () {
                        _imgGaleri();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Kamera'),
                    onTap: () {
                      _imgKamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  _imgGaleri() async {
    final picker = ImagePicker();
    final image = await picker.getImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxHeight: 600,
        maxWidth: 600);
    // setState(() {
    _image = File(image!.path);
    // });
    prosesFoto();
  }

  _imgKamera() async {
    final picker = ImagePicker();
    final image =
        await picker.getImage(source: ImageSource.camera, imageQuality: 20);
    // setState(() {
    _image = File(image!.path);
    // });
    prosesFoto();
  }

  void prosesFoto() {
    Future<Directory?> extDir = getExternalStorageDirectory();
    extDir.then((value) {
      String _timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
      final String filePath = value!.path + '/${_timestamp()}.jpg';
      _imageProses = File(filePath);
      img.Image temp = img.readJpg(_image!.readAsBytesSync());
      img.Image temp2 = img.copyResize(temp, width: 480, height: 640);
      img.drawString(temp2, img.arial_24, 4, 4, 'Beritain',
          color: img.getColor(250, 100, 100));
      img.drawString(temp2, img.arial_24, 4, 40, active_user,
          color: img.getColor(250, 100, 100));
      img.drawString(temp2, img.arial_24, 4, 80, DateTime.now().toString(),
          color: img.getColor(250, 100, 100));
      setState(() {
        _imageProses!.writeAsBytesSync(img.writeJpg(temp2));
      });
    });
  }

  void deleteKategori(idkategori) async {
    final response = await http.post(
        Uri.parse(
            "https://ubaya.fun/flutter/160418044/flutter/uas/deletekategori.php"),
        body: {
          'idkategori': idkategori.toString(),
          'idberita': widget.idberita.toString()
        });
    if (response.statusCode == 200) {
      print(response.body);
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses menghapus kategori')));
        setState(() {
          bacaData();
        });
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bacaData();
    setState(() {
      generatecomboKategori();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Edit Berita"),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.all(10),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Judul',
                      ),
                      onChanged: (value) {
                        beritas.judul = value;
                      },
                      controller: _judulCont,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'judul harus diisi';
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
                        beritas.deskripsi = value;
                      },
                      controller: _deskripsiCont,
                      keyboardType: TextInputType.multiline,
                      minLines: 3,
                      maxLines: 12,
                    )),
                Padding(
                    padding: EdgeInsets.all(10),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Penulis',
                      ),
                      onChanged: (value) {
                        beritas.penulis = value;
                      },
                      controller: _penulisCont,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'penulis harus diisi';
                        }
                        return null;
                      },
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
                          controller: _tanggalCont,
                        )),
                        ElevatedButton(
                            onPressed: () {
                              showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2200))
                                  .then((value) {
                                setState(() {
                                  _tanggalCont.text =
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
                    padding: EdgeInsets.all(10),
                    child: GestureDetector(
                      onTap: () {
                        _showPicker(context);
                      },
                      child: _imageProses != null
                          ? Image.file(_imageProses!)
                          : Image.network("https://ubaya.fun/blank.jpg"),
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
                Padding(padding: EdgeInsets.all(10), child: Text('Kategori:')),
                Padding(
                    padding: EdgeInsets.all(10),
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: beritas.kategoris!.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return Container(
                              child: Row(
                            children: [
                              new Text(beritas.kategoris![index]['nama']),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    deleteKategori(beritas.kategoris![index]
                                        ['idkategori']);
                                  },
                                  child: Text('Delete'),
                                ),
                              ),
                            ],
                          ));
                        })),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: comboKategori),
              ],
            ),
          ),
        ));
  }
}
