import 'dart:ffi';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'configs.dart';
import 'input.dart';
// const url = '192.168.100.147';       //主機位置
// const url = '192.168.0.164';
// const url = '127.0.0.1';        //主機位置

// var client = MqttServerClient(url, clientID);
var client;

void main() {
  runApp(InputApp());
}

// void main() async {
//   await client.connect(username, password);
//   runApp(MyApp());
// }

class MyApp extends StatelessWidget {

  MyApp({Key? key, required this.url}): super(key:key);

  final String url;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Controller', url: this.url),
    );
  }
}


class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title, required this.url}) : super(key: key);

  final String title;
  final String url;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double x = 0;
  double y = 0;
  double z = 0;

  double btnSize = 1.5;

  final pubTopic = 'test';
  final builder  = MqttClientPayloadBuilder();

  bool  useGyro  = false;
  String useGyroTxt = 'n';

  AccelerometerEvent? eve; 
  Timer? timer;

  @override
  void initState() {
    super.initState();
    
    asyncMethod();
  }

  void asyncMethod() async {
    client = MqttServerClient(widget.url, clientID);
    await client.connect(username, password);

    print('connected');
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
    if (useGyro) {
      builder.addString('{"x":${this.x.toStringAsFixed(2)}, "y":${this.y.toStringAsFixed(2)}, "z": ${this.z.toStringAsFixed(2)}}');
      client.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload);
      builder.payload.clear();
    }
  }

  void listenGyro() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      // print(event);
      if (useGyro == true) {
        this.setState(() {
          x = event.x;
          y = event.y;
          z = event.z;
        });
      }
      // sleep(Duration(milliseconds: 1000));
    });
  }

  void handleBtnSendMsg(int direction) {
    /*
    0: left
    1: up
    2: down
    3: right
    */
    int sensitivity = 3;
    switch (direction) {
      case 0: 
        builder.addString('{"x":${0}, "y":${-sensitivity}, "z":${0}}');
        break;
      case 1:
        builder.addString('{"x":${-sensitivity}, "y":${0}, "z": ${0}}');
        break;
      case 2:
        builder.addString('{"x":$sensitivity, "y":${0}, "z": ${0}}');
        break;
      case 3:
        builder.addString('{"x":${0}, "y":$sensitivity, "z": ${0}}');
        break;
    }
    // builder.addString('{x:${0}, y:${-3}, z: ${0}\n');
    client.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload);
    builder.payload.clear();
  }

  void handleSwitchBtn() {
    this.setState(() {
      useGyro = ! useGyro;
      useGyroTxt = (useGyro) ? 'Gyro' : 'n';
    });
  }

  Widget buildDirectionBtn(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [IconButton(onPressed: () => this.handleBtnSendMsg(0), icon: Icon(Icons.arrow_back, size: IconTheme.of(context).size! * btnSize,))],
        ),
        Column(
          mainAxisAlignment:  MainAxisAlignment.center,
          children: [
            IconButton(onPressed: () => this.handleBtnSendMsg(1), icon: Icon(Icons.arrow_upward, size: IconTheme.of(context).size! * btnSize),),
            IconButton(onPressed: () => this.handleBtnSendMsg(2), icon: Icon(Icons.arrow_downward, size: IconTheme.of(context).size! * btnSize),)
          ],
        ),
        Column(
          mainAxisAlignment:  MainAxisAlignment.center,
          children: [IconButton(onPressed: () => this.handleBtnSendMsg(3), icon: Icon(Icons.arrow_forward, size: IconTheme.of(context).size! * btnSize),)],
        ),
      ],
    );
  }

  Widget buildSwitchBtn(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(onPressed: this.handleSwitchBtn, icon: Icon(Icons.compare_arrows, size: IconTheme.of(context).size! * btnSize ),)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( '${widget.title} - $useGyroTxt'),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            buildDirectionBtn(context),
            buildSwitchBtn(context),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
