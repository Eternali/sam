/// Credits to https://gist.github.com/gildaswise/5d1b7bee327a9dd6cc5bcd1bbc72316a
/// which this is heavily based off of.

import 'package:flutter/material.dart';

typedef FancyBottomSheetBuilder = WidgetBuilder Function(AnimationController controller, Color canvasColor);
typedef Animator = double Function(double t);

Future<T> showFancyBottomSheet<T>({
  @required BuildContext context,
  @required FancyBottomSheetBuilder builder,
  Duration duration = const Duration(milliseconds: 200),
  Animator animator,
  Color dimmer,
}) {
  assert(context != null);
  assert(builder != null);
  return Navigator.push<T>(
    context,
    _FancyModalRoute<T>(
      duration: duration,
      builder: builder,
      animator: animator,
      barrierColor: dimmer ?? Colors.black54,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    )
  );
}

class _FancyModalBottomSheetLayout extends SingleChildLayoutDelegate {

  _FancyModalBottomSheetLayout(this.progress);

  final double progress;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: 0.0,
      maxHeight: constraints.maxHeight // * 9.0 / 16.0
    );
  }
  
  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - childSize.height * progress);
  }

  @override
  bool shouldRelayout(_FancyModalBottomSheetLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }

}

class _FancyModalRoute<T> extends PopupRoute<T> {

  _FancyModalRoute({
    this.duration = const Duration(milliseconds: 200),
    this.builder,
    this.barrierLabel,
    Color barrierColor = Colors.black54,
    this.animator,
    RouteSettings settings,
  }) : _barrierColor = barrierColor, super(settings: settings) {
    // Flutter does not allow barrierColor to be transparent. Technically we are using a *modal*
    // sheet which, according to the material design spec, means the user should be focused on it.
    assert(barrierColor != null);
    assert(barrierColor.alpha > 0);
  }

  final Duration duration;
  final FancyBottomSheetBuilder builder;
  AnimationController _controller;
  Animator animator;

  @override
  String barrierLabel;

  @override
  bool get barrierDismissible => true;

  Color _barrierColor;
  @override
  Color get barrierColor => _barrierColor;

  @override
  AnimationController createAnimationController() {
    assert(_controller == null);
    _controller = BottomSheet.createAnimationController(navigator.overlay)..duration = duration;
    return _controller;
  }

  @override
  bool get maintainState => false;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation
  ) {
    final Color canvasColor = Theme.of(context).canvasColor;

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
        child: AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget child) => CustomSingleChildLayout(
            delegate: _FancyModalBottomSheetLayout(animator != null ? animator(animation.value) : animation.value),
            child: BottomSheet(
              animationController: _controller,
              onClosing: () => Navigator.pop(context),
              builder: builder(_controller, canvasColor),
            )
          )
        )
      )
    );
  }

}
