import 'dart:math' as math;

import 'package:flutter/animation.dart';

class BallBounce extends Curve {
  @override
  double transform(double t) {
     if (t < 1.0 / 2.75) { //0,36
       double x = t*math.pi*2/(1.0 / 2.75);
      return (math.cos(x)/4)+3/4;
    } else if (t < 2 / 2.75) { //0,72
      t -= 1.5 / 2.75;
      return 7.5625 * t * t + 0.75;
    } else if (t < 2.5 / 2.75) { //0,9
      t -= 2.25 / 2.75;
      return 7.5625 * t * t + 0.9375;
    }
    t -= 2.625 / 2.75;
    return 7.5625 * t * t + 0.984375;
  }

}