import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mechanical_clock/Screen.dart';


class TimeClockWidget extends StatefulWidget {
  @override
  _TimeClockWidget createState() => _TimeClockWidget();

}

class _TimeClockWidget extends State<TimeClockWidget> {
  //Timer 是一个可进行一次或重复多次的计时器
  Timer timer;
  @override
  void initState() {
    super.initState();
    //以10毫秒为周期进行重复
    timer = Timer.periodic(Duration(milliseconds: 10), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: CustomPaint(painter: CustomTimeClock()));
  }
}

class CustomTimeClock extends CustomPainter {
  //外大圆
  //画笔
  Paint _outerCirclePaint = Paint() //初始化外层圆参数
    ..style = PaintingStyle.stroke //fill填充，stroke空心
    ..isAntiAlias = true //是否启动抗锯齿
    ..color = Colors.yellow //画笔的颜色，深橘色
    ..strokeWidth = 4; //线的宽度

  //粗刻度线
  Paint _linePaint = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true
    ..color = Colors.yellow
    ..strokeWidth = 4;

  //圆心
  Offset _centerOffset = Offset(0, 0);

  //圆半径
  double _bigCircleRadius =
     min(Screen.screenHeightDp / 3,  Screen.screenWidthDp / 3);

  final int lineHeight = 10;

  /*List<TextPainter> _textPaint = [
    _getTextPainter("12"),
    _getTextPainter("3"),
    _getTextPainter("6"),
    _getTextPainter("9"),
  ];*/

  //文字画笔
  TextPainter _textPainter = new TextPainter(
      textAlign: TextAlign.left, textDirection: TextDirection.rtl);

  @override
  void paint(Canvas canvas, Size size) {
    //print('_bigCircleRadius: ${_bigCircleRadius}');
    //绘制大圆
    canvas.drawCircle(_centerOffset, _bigCircleRadius, _outerCirclePaint);
    //绘制圆心
    _outerCirclePaint.style = PaintingStyle.fill;
    canvas.drawCircle(_centerOffset, _bigCircleRadius / 20, _outerCirclePaint);

    /**
     * 绘制刻度,秒针转一圈需要跳60下,
     * 这里只画6点整的刻度线，
     * 但是由于每画一条刻度线之后，
     * 画布都会旋转60°(转为弧度2*pi/60),
     * 所以画出60条刻度线
     */
    for (int i = 0; i < 60; i++) {
      _linePaint.strokeWidth = i % 5 == 0 ? (i % 3 == 0 ? 10 : 4) : 1; //设置线的粗细
      canvas.drawLine(Offset(0, _bigCircleRadius - lineHeight),
          Offset(0, _bigCircleRadius), _linePaint);
      canvas.rotate(pi / 30); //2 * pi / 60
    }
    //绘制数字,
    for (int i = 0; i < 12; i++) {
      canvas.save(); //与restore配合使用保存当前画布
      canvas.translate(
          0.0, -_bigCircleRadius + 30); //平移画布画点于时钟的12点位置，+30为了调整数字与刻度的间隔
      _textPainter.text = TextSpan(
          style: new TextStyle(color: Colors.yellow, fontSize: 22),
          text: i.toString());
      canvas.rotate(-deg2Rad(30) * i); //保持画数字的时候竖直显示。
      _textPainter.layout();
      _textPainter.paint(
          canvas, Offset(-_textPainter.width / 2, -_textPainter.height / 2));
      canvas.restore(); //画布重置,恢复到控件中心
      canvas.rotate(deg2Rad(30)); //画布旋转一个小时的刻度，把数字和刻度对应起来
    }

    //绘制指针
    int hours = DateTime.now().hour;
    int minutes = DateTime.now().minute;
    int seconds = DateTime.now().second;
    //print("时: ${hours} 分：${minutes} 秒: ${seconds}");
    //时针角度//以下都是以12点为0°参照
    //12小时转360°所以一小时30°
    double hoursAngle =
        (minutes / 60 + hours - 12) * pi / 6; //把分钟转小时之后*（2*pi/360*30）
    //分针走过的角度,同理,一分钟6°
    double minutesAngle = (minutes + seconds / 60) * pi / 30; //(2*pi/360*6)
    //秒针走过的角度,同理,一秒钟6°
    double secondsAngle = seconds * pi / 30;
    //画时针
    _linePaint.strokeWidth = 4;
    canvas.rotate(hoursAngle);
    canvas.drawLine(
        Offset(0, 0), new Offset(0, -_bigCircleRadius + 80), _linePaint);
    //画分针
    _linePaint.strokeWidth = 2;
    canvas.rotate(-hoursAngle); //先把之前画时针的角度还原。
    canvas.rotate(minutesAngle);
    canvas.drawLine(
        Offset(0, 0), new Offset(0, -_bigCircleRadius + 60), _linePaint);
    //画秒针
    _linePaint.strokeWidth = 1;
    canvas.rotate(-minutesAngle);
    canvas.rotate(secondsAngle);
    canvas.drawLine(
        Offset(0, 0), new Offset(0, -_bigCircleRadius + 30), _linePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  static TextPainter _getTextPainter(String msg) {
    return new TextPainter(
        text: TextSpan(
            style: new TextStyle(color: Colors.yellow, fontSize: 22),
            text: msg),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
  }

  //角度转弧度
  num deg2Rad(num deg) => deg * (pi / 180.0);
}
