import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

void main() => runApp(
      MaterialApp(
        theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: Center(child: Container(
          child: Speedometer(speed: 65))),
      ),
    );

















class Speedometer extends LeafRenderObjectWidget {
  const Speedometer({Key key, @required this.speed}) : super(key: key);

  final num speed;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSpeedometer(speed: speed);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderSpeedometer renderObject) {
    renderObject..speed = speed;
  }
}

class RenderSpeedometer extends RenderBox {
    static final totalAngle = 260.radians;
    static const tickDivisions = 5.2;
    Color trackColor = Color(0xFF3b2440);
    Color arcColor = Color(0xFFe71c6c);


  RenderSpeedometer({num speed}) : _speed = speed;
  num get speed => _speed;
  num _speed;
  set speed(num value) {
    if (_speed == value) {
      return;
    }
    _speed = value;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    final desiredWidth = constraints.maxWidth;  
    final desiredHeight = constraints.maxHeight;
    final desiredSize = Size(desiredWidth, desiredHeight);
    size = constraints.constrain(desiredSize); 
  }



  @override
  void paint(PaintingContext context, Offset offset) {

    final  startAngle = -220.0 * pi / 180;
    final sweepAngle = 260 * pi / 180;

    final canvas = context.canvas;
    canvas.translate(offset.dx, offset.dy);
    final rect = Rect.fromCenter(center: Offset(size.width/2,size.height/2),width: 380,height: 380);
    String text =  "0 10 20 30 40 50 60 70 80 90 100";

    final bounds = offset & size;
    final radius = bounds.radius;
    final center = bounds.center;

    //dot paint
    drawGuide(canvas, rect,startAngle,sweepAngle);
    drawArc(canvas, rect,startAngle,);
    drawTracks(canvas, rect, radius,startAngle,sweepAngle);
    // double angle = 0;
    drawLetter(canvas, text,center , startAngle,radius-35);
    drawTextCentered(canvas, center, "${speed..toInt()}");
    drawKilometerTextCentered(canvas, center, "km/h");
  }

  drawTextCentered(Canvas canvas, Offset position, String text){
    final tp = measureText(text,TextStyle(fontSize: 90,));
    tp.paint(canvas, position + Offset(-tp.width/2,-tp.height/2));
  }

  drawKilometerTextCentered(Canvas canvas, Offset position, String text){
    final tp = measureText(text,TextStyle(fontSize: 22));
    tp.paint(canvas, position + Offset(-tp.width/2,tp.height*2.2));
  }

  drawGuide(Canvas canvas, Rect rect, double startAngle,double sweepAngle){
    final dotpaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = trackColor
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    // canvas.drawPaint(Paint()..color = Colors.grey);
    canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        false,
        dotpaint);
  }

  drawArc(Canvas canvas, Rect rect, double startAngle){
    final sweepAngle =  260 * speed/100 * pi / 180;
    final dotpaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = arcColor
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    // canvas.drawPaint(Paint()..color = Colors.grey);
    canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        false,
        dotpaint);
  }

  drawTracks(Canvas canvas, Rect rect, num radius, double startAngle, double sweepAngle){
    
    // final outerPadding = radius  * .12;
    final knobRadius = radius * .8;
    final trackHeight = radius - knobRadius;
    final tickHeight = trackHeight / 2;

    // final startAngle = -220.0 * pi / 180;
    final dotpaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = trackColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i <= totalAngle.degrees / tickDivisions; i++) {
      final angle = startAngle + (i * tickDivisions).radians;
      var heightOffset = tickHeight * .7;
      final startOffset = Offset(size.width/2,size.height/2) + Offset.fromDirection(angle, radius);
      var endOffset = startOffset + Offset.fromDirection(angle, -tickHeight + heightOffset);
      if(i % 5 == 0){
       endOffset = startOffset + Offset.fromDirection(angle, -11-tickHeight + heightOffset );

      }
      canvas.drawLine(
        startOffset,
        endOffset,
        dotpaint
      );
      // canvas.drawCircle(Offset(size.width/2,size.height/2), 181, dotpaint);
      
    }
    canvas.drawArc(
        Rect.fromCenter(center: Offset(size.width/2,size.height/2),width: 361,height: 361),
        startAngle,
        sweepAngle,
        false,
        dotpaint);
    
  }

  TextPainter measureText(String letter, TextStyle textStyle){
    final _textPainter = TextPainter(text: TextSpan(text: letter ,style: textStyle),textDirection: TextDirection.ltr,);
    _textPainter.layout(minWidth: 0, maxWidth: double.maxFinite,
    );
    return _textPainter;
  }
  
    drawLetter(Canvas canvas, String letters,Offset arcCenter, double startAngle, double radius) {
     letters.split(" ").forEach((element) {
     final _textPainter = measureText(element,TextStyle(fontSize: 18));
     final startOffset =  Offset(-_textPainter.width/2,-_textPainter.height/2)+Offset.fromDirection(startAngle, radius);
    if (element == "0"){
    _textPainter.paint(canvas, startOffset);
    }
    final double d =   38 - tickDivisions;
    final double alpha = 2 * asin(d / (2 * radius ));
    

    // final newAngle = _calculateRotationAngle(startAngle, alpha);
    canvas.save();
    canvas.translate(arcCenter.dx, arcCenter.dy);

    startAngle +=alpha*2;
    // canvas.rotate(startAngle);
    // startAngle +=alpha;
    // var endOffset = startOffset + Offset.fromDirection(alpha, -tickHeight + heightOffset);
    _textPainter.paint(canvas, startOffset);
    canvas.restore();
      });
  }
}

  


extension RectX on ui.Rect {
  double get radius => shortestSide / 2;
}

extension CanvasX on Canvas {
  Rect drawText(
    String text, {
    @required Offset center,
    TextStyle style = const TextStyle(fontSize: 14.0, color: Color(0xFF333333), fontWeight: FontWeight.normal),
  }) {
    final textPainter = TextPainter(textAlign: TextAlign.center, textDirection: TextDirection.ltr)
      ..text = TextSpan(text: text, style: style)
      ..layout();
    final bounds = (center & textPainter.size).translate(-textPainter.width / 2, -textPainter.height / 2);
    textPainter.paint(this, bounds.topLeft);
    return bounds;
  }
}

extension NumX<T extends num> on T {
  static double twoPi = pi * 2.0;

  double get degrees => (this * 180.0) / pi;

  double get radians => (this * pi) / 180.0;

  T normalize(T max) => (this % max + max) % max as T;

  double get normalizeAngle => normalize(twoPi as T).toDouble();

  bool between(double min, double max) {
    return this <= max && this >= min;
  }
}
