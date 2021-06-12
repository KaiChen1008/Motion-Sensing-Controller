import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'configs.dart';
import 'input.dart';
void main() {
  runApp(InputApp());
}

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
  bool   mode    = false; // false: btn, true: gyro
  double btnSize = 1.5;

  Timer? timer;
  WebSocketChannel? channel;
  final duration = Duration(milliseconds:16); // 1/60 fps = 16.66 milli-sec

  @override
  void initState() {
    super.initState();
    connectToServer();
  }

  @override 
  void dispose() {
    timer?.cancel();
    channel?.sink.close();
    super.dispose();
  }

  void connectToServer() async {
    channel = new WebSocketChannel.connect( Uri.parse('ws://${widget.url}:8080'));//'ws://echo.websocket.org');
    print('connected');

    timer = new Timer.periodic(duration, this.gyroSendMsg);

    listenGyro();
  }
  
  void gyroSendMsg(Timer t) {
    if (mode == true) { // use gyro
      // send data to server
      var msg = '{"x": $x, "y":$y, "z": $z, "__MESSAGE__":"message"}';
      channel?.sink.add(msg);
    }
  }

  void listenGyro() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      if (mode == true) {
        this.setState(() {
          x = event.x;
          y = event.y;
          z = event.z;
        });
      }
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
    var msg;
    switch (direction) {
      case 0: 
        msg = '{"x":${0}, "y":${-sensitivity}, "z":${0},  "__MESSAGE__":"message"}';
        break;
      case 1:
        msg = '{"x":${-sensitivity}, "y":${0}, "z": ${0}, "__MESSAGE__":"message"}';
        break;
      case 2:
        msg = '{"x":$sensitivity, "y":${0}, "z": ${0},    "__MESSAGE__":"message"}';
        break;
      case 3:
        msg = '{"x":${0}, "y":$sensitivity, "z": ${0},    "__MESSAGE__":"message"}';
        break;
    }
    // print(msg);
    channel?.sink.add(msg);

  }

  void handleSwitchBtn() {
    this.setState(() {
      mode = ! mode;
    });

    var msg = '{"m":${(mode)? '1': '0'},  "__MESSAGE__":"message"}';
    channel?.sink.add(msg);
  }

  void handleEnterBtn() { // mimic pressing whitespace on a keyboard
    var msg = '{"w":1,  "__MESSAGE__":"message"}';
    channel?.sink.add(msg);
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
        IconButton(onPressed: this.handleSwitchBtn, icon: Icon(Icons.compare_arrows, size: IconTheme.of(context).size! * btnSize ),),
        IconButton(onPressed: this.handleEnterBtn,  icon: Icon(Icons.not_started, size: IconTheme.of(context).size! * btnSize ),)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( '${widget.title} - ${(mode) ? 'Gyro' : 'n'}'),
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
