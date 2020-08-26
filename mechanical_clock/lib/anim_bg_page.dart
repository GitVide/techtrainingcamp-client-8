import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mechanical_clock/page/weather/WeatherData.dart';
import 'package:simple_animations/simple_animations/controlled_animation.dart';
import 'package:simple_animations/simple_animations/multi_track_tween.dart';
import 'package:http/http.dart' as http;

class GradBackground extends StatelessWidget {
  String cityName = '上海';
  WeatherData weather = WeatherData.empty();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(child: AnimatedBackground()),
          onBottom(AnimatedWave(
            height: 180,
            speed: 1.0,
          )),
          onBottom(AnimatedWave(
            height: 120,
            speed: 0.9,
            offset: pi,
          )),
          onBottom(AnimatedWave(
            height: 220,
            speed: 1.2,
            offset: pi / 2,
          )),
          Positioned.fill(
              child: FutureBuilder<WeatherData>(
            future: _getWeather(),
            builder: (context, snapshot) {
              if (snapshot.data != null)
                return Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 40.0),
                  child: Column(
                    children: <Widget>[
                      Text(cityName,
                          style: new TextStyle(
                              color: Colors.orange, fontSize: 40.0)),
                      Text(snapshot.data?.tmp,
                          style: new TextStyle(
                              color: Colors.orange, fontSize: 50.0)),
                      Text(snapshot.data?.cond,
                          style: new TextStyle(
                              color: Colors.orange, fontSize: 38.0)),
                      Text(
                        snapshot.data?.hum,
                        style:
                            new TextStyle(color: Colors.orange, fontSize: 25.0),
                      ),
                    ],
                  ),
                );
              else
                return Text('');
            },
          )),
        ],
      ),
    );
  }

  onBottom(Widget child) => Positioned.fill(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: child,
        ),
      );

//以下是天气函数
  Future<WeatherData> _getWeather() async {
    return await _fetchWeather();
  }

//获取气象数据
  Future<WeatherData> _fetchWeather() async {
    final response = await http.get(
        'https://free-api.heweather.com/s6/weather/now?location=' +
            this.cityName +
            '&key=3c78f4b0812141b68d213ca3a7b17f97');
    if (response.statusCode == 200) {
      WeatherData data = WeatherData.fromJson(json.decode(response.body));
      return data;
    } else {
      return WeatherData.empty();
    }
  }
}

class AnimatedWave extends StatelessWidget {
  final double height;
  final double speed;
  final double offset;

  AnimatedWave({this.height, this.speed, this.offset = 0.0});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        height: height,
        width: constraints.biggest.width,
        child: ControlledAnimation(
            playback: Playback.LOOP,
            duration: Duration(milliseconds: (5000 / speed).round()),
            tween: Tween(begin: 0.0, end: 2 * pi),
            builder: (context, value) {
              return CustomPaint(
                foregroundPainter: CurvePainter(value + offset),
              );
            }),
      );
    });
  }
}

class CurvePainter extends CustomPainter {
  final double value;

  CurvePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final white = Paint()..color = Colors.white.withAlpha(60);
    final path = Path();

    final y1 = sin(value);
    final y2 = sin(value + pi / 2);
    final y3 = sin(value + pi);

    final startPointY = size.height * (0.5 + 0.4 * y1);
    final controlPointY = size.height * (0.5 + 0.4 * y2);
    final endPointY = size.height * (0.5 + 0.4 * y3);

    path.moveTo(size.width * 0, startPointY);
    path.quadraticBezierTo(
        size.width * 0.5, controlPointY, size.width, endPointY);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, white);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class AnimatedBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tween = MultiTrackTween([
      Track("color1").add(Duration(seconds: 3),
          ColorTween(begin: Color(0xffD38312), end: Colors.lightBlue.shade900)),
      Track("color2").add(Duration(seconds: 3),
          ColorTween(begin: Color(0xffA83279), end: Colors.blue.shade600))
    ]);

    return ControlledAnimation(
      playback: Playback.MIRROR,
      tween: tween,
      duration: tween.duration,
      builder: (context, animation) {
        return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [animation["color1"], animation["color2"]])),
        );
      },
    );
  }
}
