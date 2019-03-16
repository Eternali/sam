library sam;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

part 'easing_functions.dart';
part 'fancy_bottom_sheet.dart';
part 'sliding_button.dart';

class _CustomBehavior extends ScrollBehavior {

  @override
  Widget buildViewportChrome(
    BuildContext context,
    Widget child,
    AxisDirection axisDirection
  ) => child;

}

class SAM extends StatefulWidget {

  final Color color;
  final Color background;
  final List<SubFAB> entries;
  final double buttonElevation;

  SAM({ this.color, this.background, this.entries, this.buttonElevation });

  @override
  State<SAM> createState() => _SAMState();

}

class _SAMState extends State<SAM> {

  void _buildSheet(BuildContext context) {
    showFancyBottomSheet(
      context: context,
      duration: Duration(milliseconds: 200 + (widget.entries.length > 50 ? 500 : widget.entries.length * 10)),
      animator: EasingFunctions.easeInOutCubic,
      builder: (AnimationController controller, Color canvasColor) => (BuildContext context) {
        return _SAMSheet(
          controller: controller,
          canvasColor: canvasColor,
          entries: widget.entries,
          background: widget.background,
          color: widget.color,
          buttonElevation: widget.buttonElevation,
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: widget.color,
      child: Icon(Icons.add),
      onPressed: () {
        setState(() {
          // scrollController = ScrollController();
          _buildSheet(context);
        });
      },
    );
  }

}

class _SAMSheet extends StatefulWidget {

  AnimationController controller;
  final Color color;
  final Color background;
  final List<SubFAB> entries;
  final Color canvasColor;
  final double buttonElevation;

  _SAMSheet({ this.controller, this.color, this.background, this.entries, this.canvasColor, this.buttonElevation });
  
  @override
  State<_SAMSheet> createState() => _SAMSheetState(controller: controller);

}

class _SAMSheetState extends State<_SAMSheet> {

  AnimationController controller;
  ScrollController scrollController;

  final transDistance = 35.0;
  bool canDrag = true;

  _SAMSheetState({ this.controller });

  void updateState() { setState(() {  }); }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(updateState);
  }

  @override
  void dispose() {
    scrollController?.removeListener(updateState);
    scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (DragUpdateDetails details) {
        final double dragEnd = controller.value - (details.primaryDelta / MediaQuery.of(context).size.height * 3);
        if (scrollController.offset <= 0 && canDrag && dragEnd <= 1.0) {
          canDrag = false;
          controller
            .animateTo(dragEnd)
            .then((_) => canDrag = true);
        }
        if (scrollController.position.maxScrollExtent > 0 && controller.value >= 1 && (
          (scrollController.offset < scrollController.position.maxScrollExtent && details.primaryDelta < 0) ||
          (scrollController.offset > scrollController.position.minScrollExtent && details.primaryDelta > 0)
        )) {
          scrollController.jumpTo(scrollController.offset - details.primaryDelta);
        }
      },
      onVerticalDragEnd: (DragEndDetails details) {
        if (scrollController.offset <= 0) {
          if (details.primaryVelocity > 0) controller.reverse();
          else controller.forward();
        }
      },
      child: ScrollConfiguration(
        behavior: _CustomBehavior(),
        child: ListView(
          shrinkWrap: true,
          controller: scrollController,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            Container(
              // watch sheet margin bottom cause bottom items shifted up
              padding: EdgeInsets.only(top: transDistance + 10.0, left: 8.0, right: 8.0, bottom: 10.0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.background ?? widget.canvasColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0)
                )
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 6.0,
                runSpacing: 6.0,
                children: List<Widget>.generate(widget.entries.length, (int e) =>
                  SlidingButton(
                    transDistance: transDistance,
                    index: e,
                    fabs: widget.entries,
                    controller: controller,
                    elevation: widget.buttonElevation,
                  )
                ),
              )
            ),
          ]
        ),
      ),
    );
  }

}
