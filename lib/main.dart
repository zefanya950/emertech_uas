import 'package:flutter/material.dart';
import 'package:flutter_uas_160418044/screen/daftarberita.dart';
import 'package:flutter_uas_160418044/screen/login.dart';
import 'package:flutter_uas_160418044/screen/newberita.dart';
import 'package:shared_preferences/shared_preferences.dart';

String active_user = "";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  checkUser().then((String result) {
    if (result == '')
      runApp(MyLogin());
    else {
      active_user = result;
      runApp(MyApp());
    }
  });
}

Future<String> checkUser() async {
  final prefs = await SharedPreferences.getInstance();
  String user_id = prefs.getString("user_name") ?? '';
  return user_id;
}

void doLogout() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove("user_name");
  prefs.remove("user_id");
  main();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beritain',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const MyHomePage(title: 'Beritain Home Page'),
      routes: {
        'daftarberita': (context) => DaftarBerita(),
        'newberita': (context) => NewBerita(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget myDrawer() {
    return Drawer(
        elevation: 16.0,
        child: SingleChildScrollView(
            child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
                accountName: Text(active_user),
                accountEmail: Text("xyz@gmail.com"),
                currentAccountPicture: CircleAvatar(
                    backgroundImage:
                        NetworkImage("https://i.pravatar.cc/300?img=5"))),
            ListTile(
              title: Text("Daftar Berita"),
              leading: Icon(
                Icons.movie,
                color: Colors.orangeAccent,
              ),
              onTap: () {
                // Navigator.push(
                //     context, MaterialPageRoute(builder: (context) => About()));
                Navigator.popAndPushNamed(context, 'daftarberita');
              },
            ),
            ListTile(
              title: Text("New Berita"),
              leading: Icon(
                Icons.movie,
                color: Colors.orangeAccent,
              ),
              onTap: () {
                // Navigator.push(
                //     context, MaterialPageRoute(builder: (context) => About()));
                Navigator.popAndPushNamed(context, 'newberita');
              },
            ),
            ListTile(
              title: Text("Logout"),
              leading: Icon(
                Icons.logout,
                color: Colors.orangeAccent,
              ),
              onTap: () {
                // Navigator.push(
                //     context, MaterialPageRoute(builder: (context) => About()));
                doLogout();
              },
            ),
          ],
        )));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[],
        ),
      ),
      drawer: myDrawer(),
    );
  }
}
