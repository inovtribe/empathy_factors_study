import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Used to indicate how an animation should be played 
enum AnimationAction {
  /// Used to indicate that an animation should be played forwards
  forward,
  /// Used to indicate that an animation should be played backwards
  reverse,
  /// Used to indicate that an animation should be played repeatedly
  repeat,
  /// Used to indicate that an animation should be played reversed repeatedly
  reverseRepeat,
}

@optionalTypeArgs
mixin TickedAnimatedWidget<T, S extends StatefulWidget> on State<S>, TickerProvider {
  @protected
  Duration get animationDuration;
  
  @protected
  T get animationBegin;
  
  @protected
  T get animationEnd;

  @protected
  AnimationAction get animationAction;

  @protected
  AnimationController controller;

  @protected
  Animation<T> animation;

  @protected
  T get animationValue => animation?.value ?? animationBegin;

  /// Initializes the animation. If you override the initState method, be sure
  /// to call this manually.
  @protected
  void initStateAnimation() {
    controller = AnimationController(duration: animationDuration, vsync: this);
    animation = Tween(begin: animationBegin, end: animationEnd).animate(controller)
      ..addListener(() {
        setState(() {});
      });

    switch (animationAction) {
      case AnimationAction.forward:
        controller.forward();
        break;
      case AnimationAction.reverse:
        controller.reverse();
        break;
      case AnimationAction.repeat:
        controller.repeat();
        break;
      case AnimationAction.reverseRepeat:
        controller.repeat(reverse: true);
        break;
    }
  }

  /// Disposes of the animation. If you override the initState method, be sure
  /// to call this manually.
  @protected
  void disposeAnimation() {
    controller.stop();
  }
}

@optionalTypeArgs
mixin AutoTickedAnimatedWidget<T, S extends StatefulWidget> on TickedAnimatedWidget<T, S> {
  /// Indicates whether it is safe for this `AutoTickedAnimatedWidget` to be initialized in `initState`
  @protected
  bool get initStateSafe => true;

  @override
  void initState() {
    super.initState();
    
    if (initStateSafe) initStateAnimation();
    else WidgetsBinding.instance.addPostFrameCallback((_) => setState(initStateAnimation));
  }

  @override
  void dispose() {
    disposeAnimation();
    super.dispose();
  }
}
