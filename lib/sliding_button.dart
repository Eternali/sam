part of sam;

class SubFAB {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final GlobalKey key;
  double animValue = 1.0;

  SubFAB({ this.icon, this.label, this.color, this.onPressed, this.key });
}

class SlidingButton extends StatefulWidget {

  final AnimationController controller;
  final int index;
  final List<SubFAB> fabs;
  final double transDistance;
  final double elevation;

  final double fabDuration = 0.25;
  double fabSpawnTime;

  SlidingButton({
    @required this.transDistance,
    this.index,
    @required this.fabs,
    this.controller,
    this.elevation,
    Key key
  }) : super(key: key) {
    fabSpawnTime = (0.75 / fabs.length) * index;
  }

  @override
  State<SlidingButton> createState() => _SlidingButtonState();

}

class _SlidingButtonState extends State<SlidingButton> {

  SubFAB get fab => widget.fabs[widget.index];

  CurvedAnimation animation;

  @override
  void initState() {
    super.initState();
    animation = CurvedAnimation(
      curve: Interval(
        widget.fabSpawnTime,
        widget.fabSpawnTime + widget.fabDuration,
        curve: Curves.easeInOut
      ),
      parent: widget.controller
    );
  }

  @override
  void dispose() {
    // widget.controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Opacity(
        opacity: animation.value,
        child: Container(
          transform: Matrix4.translation(Vector3(0, -animation.value * widget.transDistance, 0)),
          margin: EdgeInsets.all(4.0),
          child: FloatingActionButton.extended(
            elevation: widget.elevation ?? 0,
            heroTag: null,
            tooltip: fab.label,
            label: Text(
              fab.label,
            ),
            backgroundColor: fab.color,
            icon: Icon(fab.icon),
            onPressed: () {
              // _controller.reverse();
              fab.onPressed();
            },
          ),
        )
      )
    );
  }
}
