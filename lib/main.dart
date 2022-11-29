import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';

import 'pages/viewer.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  static const String _title = 'ARniture';
  List<ARnitureObject> arObjectList = [];
  @override
  void initState() {
    super.initState();
    initFirebase();
  }

  Future<void> initFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('Objects').get();
    if (snapshot.exists) {
      Map objectMap = snapshot.value as Map;
      objectMap.forEach((key, value) {
        Map data = value as Map;
        print(key);
        print(data['scale']);
        arObjectList.add(
            new ARnitureObject(key, data['url'], data['scale'].toDouble()));
      });
    } else {
      print('No data available.');
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(_title),
        ),
        body: Container(
          margin: EdgeInsets.fromLTRB(15, 15, 15, 15),
          child: Column(children: [
            Text(
              'Choose an object to view in Augmented Reality : \n',
              style: TextStyle(fontSize: 20),
            ),
            Expanded(
              child: ExampleList(arObjectList: arObjectList),
            ),
          ]),
        ),
      ),
    );
  }
}

class ExampleList extends StatelessWidget {
  ExampleList({Key? key, required this.arObjectList}) : super(key: key);
  final List<ARnitureObject> arObjectList;
  @override
  Widget build(BuildContext context) {
    return ListView(
      children:
          arObjectList.map((example) => ExampleCard(example: example)).toList(),
    );
  }
}

class ExampleCard extends StatelessWidget {
  ExampleCard({Key? key, required this.example}) : super(key: key);
  final ARnitureObject example;

  @override
  build(BuildContext context) {
    return Card(
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ObjectGesturesWidget(
                      name: example.name,
                      url: example.url,
                      scale: example.scale)));
        },
        child: ListTile(
          title: Text(example.name),
          subtitle: Text("Tap to place in reality"),
        ),
      ),
    );
  }
}

class ARnitureObject {
  ARnitureObject(this.name, this.url, this.scale);
  final String name;
  final String url;
  final double scale;
}
