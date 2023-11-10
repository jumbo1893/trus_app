import 'package:flutter/material.dart';

class BodyTweenSequenceComponents {
  final List<double> sequenceItemStart;
  double lastItemEnd;
  final List<double> weight;

  BodyTweenSequenceComponents(this.sequenceItemStart, this.lastItemEnd, {this.weight = const []});

  List<TweenSequenceItem<double>> getTweenComponents() {
    List<TweenSequenceItem<double>> tweenSequenceList = [];
    for(int i = 0; i < sequenceItemStart.length; i++) {
      tweenSequenceList.add(TweenSequenceItem<double>(
        tween: Tween<double>(begin: sequenceItemStart[i], end: (i == sequenceItemStart.length -1 ) ? lastItemEnd : sequenceItemStart[i+1]),
        weight: weight.isEmpty ? 1 : weight[i],
      ));
    }
    return tweenSequenceList;
  }




}