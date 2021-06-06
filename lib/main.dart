import 'dart:ffi';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

const url = '192.168.100.147';       //主機位置
// const url = '127.0.0.1';        //主機位置
const port = 1883;              //MQTT port
const clientID = 'Client01';    //Mqtt Client
const username = 'Client01';    //Mqtt username
const password = 'password';    //Mqtt password
final client = MqttServerClient(url, clientID);

void main() async {
  await client.connect(username, password);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}




class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int _counter = 0;
  double x = 0;
  double y = 0;
  double z = 0;

  final pubTopic = 'test';
  final builder = MqttClientPayloadBuilder();

  AccelerometerEvent? eve; 
  Timer? timer;

  @override
  void initState(){
    super.initState();
    const duration = const Duration(milliseconds:100);
    timer = new Timer.periodic(duration, this.sendMsg);

    listenGyro();
  }

  @override 
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void btnEvent() {
    print('sended');
  } 

  void sendMsg(Timer t) {
    builder.addString('{x:${this.x.toStringAsFixed(2)}, y:${this.y.toStringAsFixed(2)}, z: ${this.z.toStringAsFixed(2)}}\n');
    client.publishMessage(pubTopic, MqttQos.atMostOnce, builder.payload);
  }

  void listenGyro() {

    accelerometerEvents.listen((AccelerometerEvent event) {
      // print(event);
      this.setState(() {
        x = event.x;
        y = event.y;
        z = event.z;
      });
      // sleep(Duration(milliseconds: 1000));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'gyro listening....',
            ),
            Text(
              'y: ${y.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              'x: ${x.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headline4,
            ),
            FloatingActionButton(onPressed: this.btnEvent)
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
