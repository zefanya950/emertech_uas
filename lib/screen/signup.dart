import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_uas_160418044/screen/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../main.dart';

class MySignup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beritain Signup Page',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: Signup(),
      routes: {
        'login': (context) => MyLogin(),
      },
    );
  }
}

class Signup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SignupState();
  }
}

class _SignupState extends State<Signup> {
  String _user_id = "";
  String user_password = "";
  String user_name = "";
  String error_Signup = "";

  void doSignup() async {
    final response = await http.post(
        Uri.parse("https://ubaya.fun/flutter/160418044/flutter/uas/signup.php"),
        body: {
          'user_id': _user_id,
          'user_name': user_name,
          'user_password': user_password
        });
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Sukses mendaftar ke Beritain, Silahkan melakukan proses login')));
      } else {
        setState(() {
          error_Signup = "User id atau password error";
        });
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Signup'),
        ),
        body: Container(
          height: 400,
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              color: Colors.white,
              boxShadow: [BoxShadow(blurRadius: 15)]),
          child: Column(children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Name',
                    hintText: 'Enter your name'),
                onChanged: (v) {
                  user_name = v;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Username',
                    hintText: 'Enter valid username'),
                onChanged: (v) {
                  _user_id = v;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter secure password'),
                onChanged: (v) {
                  user_password = v;
                },
              ),
            ),
            if (error_Signup != "")
              Text(error_Signup, style: TextStyle(color: Colors.red)),
            Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  height: 50,
                  width: 300,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20)),
                  child: ElevatedButton(
                    onPressed: () {
                      doSignup();
                    },
                    child: Text(
                      'Signup',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                )),
          ]),
        ));
  }
}
