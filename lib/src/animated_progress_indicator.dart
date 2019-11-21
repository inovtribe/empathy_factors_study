import 'package:flutter/material.dart';

const double kLinearProgressIndicatorHeight = 6.0;
const int kIndeterminateLinearDuration = 1800;

class FixedProgressIndicator extends StatelessWidget {
  const FixedProgressIndicator({Key key, this.value, this.color, this.backgroundColor, this.inFlex = false, this.padded = false,}) : super(key: key);

  final double value;
  final Color color;
  final Color backgroundColor;
  final bool inFlex;
  final bool padded;

  @override
  Widget build(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);

    final content = Container(
      constraints: inFlex ? const BoxConstraints(
        minWidth: 0,
        minHeight: kLinearProgressIndicatorHeight,
      ) : const BoxConstraints(
        minWidth: double.infinity,
        minHeight: kLinearProgressIndicatorHeight,
      ),
      child: CustomPaint(
        painter: AnimatedProgressIndicatorPainter(
          backgroundColor: backgroundColor,
          color: color,
          value: value,
          padded: padded,
          textDirection: textDirection,
        ),
      ),
    );

    return inFlex ? Expanded(child: content) : content;
  }
}

class AnimatedProgressIndicatorPainter extends CustomPainter {
  const AnimatedProgressIndicatorPainter({
    this.backgroundColor,
    this.color,
    this.value,
    this.padded = false,
    @required this.textDirection,
  }) : assert(value != null && value >= 0, 'value must be non-null and greator than or equal to 0.'), assert(textDirection != null, 'textDirection must not be null.');

  final Color backgroundColor;
  final Color color;
  final double value;
  final bool padded;
  final TextDirection textDirection;

  double get leftPaddedValue => (value * 0.9) + 0.05;
  double get paddedValue => padded ? (leftPaddedValue >= 0.95 ? 1 : leftPaddedValue) : value;

  // The indeterminate progress animation displays two lines whose leading (head)
  // and trailing (tail) endpoints are defined by the following four curves.
  static const Curve line1Head = Interval(
    0.0,
    750.0 / kIndeterminateLinearDuration,
    curve: Cubic(0.2, 0.0, 0.8, 1.0),
  );
  static const Curve line1Tail = Interval(
    333.0 / kIndeterminateLinearDuration,
    (333.0 + 750.0) / kIndeterminateLinearDuration,
    curve: Cubic(0.4, 0.0, 1.0, 1.0),
  );
  static const Curve line2Head = Interval(
    1000.0 / kIndeterminateLinearDuration,
    (1000.0 + 567.0) / kIndeterminateLinearDuration,
    curve: Cubic(0.0, 0.0, 0.65, 1.0),
  );
  static const Curve line2Tail = Interval(
    1267.0 / kIndeterminateLinearDuration,
    (1267.0 + 533.0) / kIndeterminateLinearDuration,
    curve: Cubic(0.10, 0.0, 0.45, 1.0),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, paint);

    paint.color = color;

    void drawBar(double x, double width) {
      if (width <= 0.0) return;

      double left;
      switch (textDirection) {
        case TextDirection.rtl:
          left = size.width - width - x;
          break;
        case TextDirection.ltr:
          left = x;
          break;
      }
      canvas.drawRect(Offset(left, 0.0) & Size(width, size.height), paint);
    }

    if (paddedValue != null) {
      drawBar(0.0, paddedValue.clamp(0.0, 1.0) * size.width);
    } else {
      final double x1 = size.width * line1Tail.transform(paddedValue);
      final double width1 = size.width * line1Head.transform(paddedValue) - x1;

      final double x2 = size.width * line2Tail.transform(paddedValue);
      final double width2 = size.width * line2Head.transform(paddedValue) - x2;

      drawBar(x1, width1);
      drawBar(x2, width2);
    }
  }

  @override
  bool shouldRepaint(AnimatedProgressIndicatorPainter oldPainter) {
    return oldPainter.backgroundColor != backgroundColor || oldPainter.color != color || oldPainter.paddedValue != paddedValue || oldPainter.textDirection != textDirection;
  }
}
