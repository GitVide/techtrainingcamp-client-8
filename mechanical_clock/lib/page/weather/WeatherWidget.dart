import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mechanical_clock/page/weather/WeatherData.dart';
import 'package:http/http.dart' as http;

class WeatherWidget extends StatefulWidget {
  String cityName;

  WeatherWidget(this.cityName);

  @override
  State<StatefulWidget> createState() {
    return new WeatherState(this.cityName);
  }
}

class WeatherState extends State<WeatherWidget> {
  String cityName;

  WeatherData weather = WeatherData.empty();

  WeatherState(String cityName) {
    this.cityName = cityName;
    _getWeather();
  }

  void _getWeather() async {
    WeatherData data = await _fetchWeather();
    setState(() {
      weather = data;
    });
  }

  Future<WeatherData> _fetchWeather() async {
    final response = await http.get(
        'https://free-api.heweather.com/s6/weather/now?location=' +
            this.cityName +
            '&key=3c78f4b0812141b68d213ca3a7b17f97');
    if (response.statusCode == 200) {
      return WeatherData.fromJson(json.decode(response.body));
    } else {
      return WeatherData.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            //mainAxisAlignment: MainAxisAlignment.start,
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                //width: double.infinity,
                //margin: EdgeInsets.only(top: 100.0),
                child: Column(
                  children: <Widget>[
                    Text(weather?.tmp,
                        style:
                            new TextStyle(color: Colors.white, fontSize: 80.0)),
                    Text(weather?.cond,
                        style:
                            new TextStyle(color: Colors.white, fontSize: 45.0)),
                    Text(
                      weather?.hum,
                      style: new TextStyle(color: Colors.white, fontSize: 30.0),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
