import 'dart:async';
import 'package:flutter/material.dart';

import 'time_model.dart';
import 'spinner_text.dart';

class DigitalClock extends StatefulWidget {
  DigitalClock({
    this.is24HourTimeFormat,
    this.showSecondsDigit,
    this.areaWidth,
    this.areaHeight,
    this.areaDecoration,
    this.areaAligment,
    this.hourMinuteDigitDecoration,
    this.secondDigitDecoration,
    this.digitAnimationStyle,
    this.hourMinuteDigitTextStyle,
    this.secondDigitTextStyle,
    this.amPmDigitTextStyle,
  });

  final bool is24HourTimeFormat;
  final bool showSecondsDigit;
  final double areaWidth;
  final double areaHeight;
  final BoxDecoration areaDecoration;
  final AlignmentDirectional areaAligment;
  final BoxDecoration hourMinuteDigitDecoration;
  final BoxDecoration secondDigitDecoration;
  final Curve digitAnimationStyle;
  final TextStyle hourMinuteDigitTextStyle;
  final TextStyle secondDigitTextStyle;
  final TextStyle amPmDigitTextStyle;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime;
  TimeModel _timeModel;

  @override
  void initState() {
    super.initState();
    _dateTime = DateTime.now();
    _timeModel = TimeModel();
    _timeModel.is24HourFormat =
        widget.is24HourTimeFormat != null ? widget.is24HourTimeFormat : true;

    _dateTime = DateTime.now();
    _timeModel.hour = _dateTime.hour;
    _timeModel.minute = _dateTime.minute;
    _timeModel.second = _dateTime.second;

    Timer.periodic(Duration(seconds: 1), (timer) {
      _dateTime = DateTime.now();
      _timeModel.hour = _dateTime.hour;
      _timeModel.minute = _dateTime.minute;
      _timeModel.second = _dateTime.second;

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.areaWidth != null
          ? widget.areaWidth
          : widget.hourMinuteDigitTextStyle != null
              ? widget.hourMinuteDigitTextStyle.fontSize * 7
              : 180,
      height: widget.areaHeight != null ? widget.areaHeight : null,
      child: Container(
        alignment: widget.areaAligment != null
            ? widget.areaAligment
            : AlignmentDirectional.bottomCenter,
        decoration: widget.areaDecoration != null
            ? widget.areaDecoration
            : BoxDecoration(
                border: Border.all(color: Colors.transparent),
                borderRadius: BorderRadius.circular(20),
                color: Color.fromARGB(255, 3, 12, 84),
              ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            _hour(),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 2),
                child: SpinnerText(
                  text: ":",
                  textStyle: widget.hourMinuteDigitTextStyle == null
                      ? null
                      : widget.hourMinuteDigitTextStyle,
                )),
            _minute,
            _second,
            _amPm,
          ],
        ),
      ),
    );
  }

  Widget _hour() => Container(
        decoration: widget.hourMinuteDigitDecoration != null
            ? widget.hourMinuteDigitDecoration
            : BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(5)),
        child: SpinnerText(
          text: _timeModel.is24HourTimeFormat
              ? hTOhh_24hTrue(_timeModel.hour)
              : hTOhh_24hFalse(_timeModel.hour)[0],
          animationStyle: widget.digitAnimationStyle,
          textStyle: widget.hourMinuteDigitTextStyle == null
              ? null
              : widget.hourMinuteDigitTextStyle,
        ),
      );

  Widget get _minute => Container(
        decoration: widget.hourMinuteDigitDecoration != null
            ? widget.hourMinuteDigitDecoration
            : BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(5)),
        child: SpinnerText(
          text: mTOmm(_timeModel.minute),
          animationStyle: widget.digitAnimationStyle,
          textStyle: widget.hourMinuteDigitTextStyle == null
              ? null
              : widget.hourMinuteDigitTextStyle,
        ),
      );

  Widget get _second => widget.showSecondsDigit != false
      ? Container(
          margin: EdgeInsets.only(
              bottom: widget.secondDigitTextStyle != null ? 0 : 0,
              left: 4,
              right: 2),
          decoration: widget.secondDigitDecoration != null
              ? widget.secondDigitDecoration
              : BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(5)),
          child: SpinnerText(
            text: sTOss(_timeModel.second),
            animationStyle: widget.digitAnimationStyle,
            textStyle: widget.secondDigitTextStyle == null
                ? TextStyle(
                    fontSize: widget.hourMinuteDigitTextStyle != null
                        ? widget.hourMinuteDigitTextStyle.fontSize / 2
                        : 15,
                    color: widget.hourMinuteDigitTextStyle != null
                        ? widget.hourMinuteDigitTextStyle.color
                        : Colors.white)
                : widget.secondDigitTextStyle,
          ),
        )
      : Text("");

  Widget get _amPm => _timeModel.is24HourTimeFormat
      ? Text("")
      : Container(
          padding: EdgeInsets.symmetric(horizontal: 2),
          margin: EdgeInsets.only(
              bottom: widget.hourMinuteDigitTextStyle != null
                  ? widget.hourMinuteDigitTextStyle.fontSize / 2
                  : 15),
          child: Text(
            " " + hTOhh_24hFalse(_timeModel.hour)[1],
            style: widget.amPmDigitTextStyle != null
                ? widget.amPmDigitTextStyle
                : TextStyle(
                    fontSize: widget.hourMinuteDigitTextStyle != null
                        ? widget.hourMinuteDigitTextStyle.fontSize / 2
                        : 15,
                    color: widget.hourMinuteDigitTextStyle != null
                        ? widget.hourMinuteDigitTextStyle.color
                        : Colors.white),
          ),
        );
}
