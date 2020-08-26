// Copyright 2019 Valerii Kuznietsov. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:digital_clock/day_night_animation_controller.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:intl/intl.dart';
import 'package:mechanical_clock/anim_bg_page.dart';
import 'package:mechanical_clock/main.dart';
import 'package:mechanical_clock/mechanical.dart';
import 'package:mechanical_clock/page/city/CityData.dart';
import 'package:mechanical_clock/page/city/CityWidget.dart';
import 'package:mechanical_clock/Screen.dart';
import 'package:mechanical_clock/page/weather/WeatherData.dart';
import 'package:mechanical_clock/page/weather/WeatherWidget.dart';
import 'time_model.dart';
import 'spinner_text.dart';

enum _Element {
  background,
  text,
  shadow,
}

final _lightTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
};

class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime;
  TimeModel _timeModel;
  Timer _timer;

  bool _shouldResetAnimationState = false;
  DayNightAnimationController _dayNightController;

  @override
  void initState() {
    super.initState();
    _timeModel = TimeModel();
    _dateTime = DateTime.now();
    int timeOffset = getTimeOffset(widget.model.timeZone);
    if (timeOffset != 100) {
      _dateTime = DateTime.now().toUtc().add(Duration(hours: timeOffset));
    }
    _timeModel.hour = _dateTime.hour;
    _timeModel.minute = _dateTime.minute;
    _timeModel.second = _dateTime.second;

    _dayNightController = DayNightAnimationController(_dateTime);
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      DateTime  currentTime = DateTime.now();
      int timeOffset = getTimeOffset(widget.model.timeZone);
      if (timeOffset != 100) {
        currentTime = DateTime.now().toUtc().add(Duration(hours: timeOffset));
      }
      // we need to reset the animation when daylight saving time happens
      _shouldResetAnimationState =
          currentTime.difference(_dateTime).inMinutes > 2;

      _dateTime = currentTime;

      _timeModel.second = _dateTime.second;
      _timeModel.minute = _dateTime.minute;
      _timeModel.hour = _dateTime.hour;

      // Update once per minute.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var model = widget.model;

    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final fontSizeDivider = model.is24HourFormat ? 4 : 5;
    final mediaWidth = MediaQuery.of(context).size.width;
    final fontSize = mediaWidth / fontSizeDivider - 20;

    final weatherAnimationSize = MediaQuery.of(context).size.height / 4;
    final defaultStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'Baloo',
      fontSize: fontSize,
    );

    DateFormat minutesFormatter = DateFormat('mm');

    final hoursFormatterPattern = model.is24HourFormat ? 'HH' : 'hh';
    DateFormat hoursFormatter = DateFormat(hoursFormatterPattern);
    DateFormat secondsFormatter = DateFormat("ss");

    final hour = hoursFormatter.format(_dateTime);
    final minute = minutesFormatter.format(_dateTime);
    final second = secondsFormatter.format(_dateTime);
    List<Widget> timeWidgets = _createTimeWidgets(hour, minute, fontSize);

    if (_shouldResetAnimationState) {
      _dayNightController.resetAnimationTo(_dateTime);
    }

    final weatherArtboardName =
        _provideWeatherArtboardName(model.weatherCondition);

    // Widget stackClock() {
    //   return Stack(
    //     children: [
    //       Positioned(
    //           left: mediaWidth / 6,
    //           child: Container(
    //             padding: EdgeInsets.symmetric(horizontal: 2),
    //             margin: EdgeInsets.only(bottom: 0, left: 4, right: 2),
    //             child: SpinnerText(
    //               text: hour,
    //               animationStyle: Curves.easeInOut,
    //               textStyle: defaultStyle,
    //             ),
    //           )),

    //       Positioned(
    //         left: mediaWidth / 2 - fontSize / 2,
    //         child: Container(
    //             padding: EdgeInsets.symmetric(horizontal: 2),
    //             child: SpinnerText(text: ":", textStyle: defaultStyle)),
    //       ),
    //       // SizedBox(
    //       //   child: Text(":"),
    //       // ),
    //       Positioned(
    //         left: mediaWidth / 2 + fontSize / 2,
    //         child: Container(
    //             padding: EdgeInsets.symmetric(horizontal: 2),
    //             child: SpinnerText(
    //               text: minute,
    //               animationStyle: Curves.easeInOut,
    //               textStyle: defaultStyle,
    //             )),
    //       ),
    //       // width: fontSize / 3,
    //       // height: fontSize / 3,
    //       Positioned(
    //           right: mediaWidth / 6,
    //           child: Container(
    //             width: fontSize / 1.5,
    //             margin: EdgeInsets.only(bottom: 0, left: 4, right: 2),
    //             child: SpinnerText(
    //               text: second,
    //               animationStyle: Curves.easeInOut,
    //               textStyle: defaultStyle.copyWith(fontSize: fontSize / 3),
    //             ),
    //           )),

    //       model.is24HourFormat ? SizedBox() : SizedBox()
    //     ],
    //   );
    // }

    Widget rowClock() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2),
            margin: EdgeInsets.only(bottom: 0, left: 4, right: 2),
            child: SpinnerText(
              text: hour,
              animationStyle: Curves.easeInOut,
              textStyle: defaultStyle,
            ),
          ),

          Container(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: SpinnerText(text: ":", textStyle: defaultStyle)),
          // SizedBox(
          //   child: Text(":"),
          // ),

          Container(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: SpinnerText(
                text: minute,
                animationStyle: Curves.easeInOut,
                textStyle: defaultStyle,
              )),
          // width: fontSize / 3,
          // height: fontSize / 3,
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: mediaWidth / 7,
              ),
              Container(
                width: fontSize / 2,
                child: SpinnerText(
                  text: second,
                  animationStyle: Curves.easeInOut,
                  textStyle: defaultStyle.copyWith(fontSize: fontSize / 3),
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              !model.is24HourFormat
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: fontSize / 2,
                          child: SpinnerText(
                            text: _createMeridianString(),
                            animationStyle: Curves.easeInOut,
                            textStyle:
                                defaultStyle.copyWith(fontSize: fontSize / 3),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(),
            ],
          ),
        ],
      );
    }

    return Container(
      color: colors[_Element.background],
      child: Stack(
        children: <Widget>[
          FlareActor(
            "daily.flr",
            shouldClip: false,
            alignment: Alignment.center,
            fit: BoxFit.cover,
            controller: _dayNightController,
          ),
          Positioned(right:30,top:20,child: FlatButton(
            child: Text("AnalogClock"),
            textColor: Colors.purple,
            onPressed: () {
              //导航到新路由
              Navigator.push( context,
                  MaterialPageRoute(builder: (context) {
                    Screen.init();
                    return MyApp();
                  }));
            },
          ),),
          Semantics(
            readOnly: true,
            label: "Weather and Temperature",
            value: "${model.weatherString} ${model.temperatureString}",
            child: SizedBox(
              width: weatherAnimationSize,
              height: weatherAnimationSize,
              child: FlareActor(
                "daily.flr",
                animation: "anim",
                artboard: weatherArtboardName,
                shouldClip: false,
                alignment: Alignment.center,
                sizeFromArtboard: false,
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: MergeSemantics(
              child: DefaultTextStyle(
                style: defaultStyle,
                child: Container(
                    width: mediaWidth,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.baseline,
                    // textBaseline: TextBaseline.alphabetic,
                    // children: timeWidgets,
                    child: rowClock()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _createSecondWidget(String second, textStyle) => Container(
        padding: EdgeInsets.symmetric(horizontal: 2),
        margin: EdgeInsets.only(bottom: 0, left: 4, right: 2),
        child: SpinnerText(
          text: second,
          animationStyle: Curves.easeInOut,
          textStyle: textStyle,
        ),
      );
  Widget _createMinuteWidget(String minute, textStyle) => Container(
        padding: EdgeInsets.symmetric(horizontal: 2),
        child: SpinnerText(
          text: minute,
          animationStyle: Curves.easeInOut,
          textStyle: textStyle,
        ),
      );
  Widget _createHourWidget(String hour, textStyle) => Container(
        padding: EdgeInsets.symmetric(horizontal: 2),
        child: SpinnerText(
          text: hour,
          animationStyle: Curves.easeInOut,
          textStyle: textStyle,
        ),
      );

  List<Widget> _createTimeWidgets(String hour, String minute, double fontSize) {
    List<Widget> timeWidgets = [];
    timeWidgets.add(Text("$hour"));
    timeWidgets.add(Text(":"));
    timeWidgets.add(Text("$minute"));

    if (!widget.model.is24HourFormat) {
      Text meridianText = _createMeridianText(fontSize);
      timeWidgets.add(meridianText);
    }

    return timeWidgets;
  }

  String _createMeridianString() {
    final _meridianFormatter = DateFormat('a');
    final meridian = _meridianFormatter.format(_dateTime);
    return meridian;
  }

  Text _createMeridianText(double fontSize) {
    final _meridianFormatter = DateFormat('a');
    final meridian = _meridianFormatter.format(_dateTime);
    var meridianTextWidget = Text(
      "$meridian",
      style: TextStyle(
        fontFamily: 'Baloo',
        fontSize: fontSize / 2,
      ),
    );

    return meridianTextWidget;
  }

  String _provideWeatherArtboardName(WeatherCondition weatherCondition) {
    switch (weatherCondition) {
      case WeatherCondition.cloudy:
        return "weather-cloudy";
      case WeatherCondition.foggy:
        return "weather-foggy";
      case WeatherCondition.rainy:
        return "weather-rainy";
      case WeatherCondition.snowy:
        return "weather-snowy";
      case WeatherCondition.sunny:
        return "weather-sunny";
      case WeatherCondition.thunderstorm:
        return "weather-thunderstorm";
      case WeatherCondition.windy:
        return "weather-windy";
    }

    return "weather-sunny";
  }
}
