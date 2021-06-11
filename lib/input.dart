import 'dart:ffi';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'main.dart';
import 'configs.dart';

class InputApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gyro Controller',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: InputPage(title: 'Controller'),
    );
  }
}

class InputPage extends StatefulWidget {
  InputPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final TextEditingController _controller = new TextEditingController();

  @override
  void initState(){
    super.initState();
  }

  @override 
  void dispose() {
    super.dispose();
  }

  void handleBtn() async {
    String url =  _controller.text;
    print(url);

    runApp(MyApp(url:url));

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title}'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(hintText: 'ip'),
            ),
            ElevatedButton(
              child: Text('enter'),
              onPressed: this.handleBtn,
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}