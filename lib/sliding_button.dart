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

  double get fabDuration => 8 / fabs.length;
  double get fabSpawnTime => (1 - fabDuration) / (fabs.length - 1);


  SlidingButton({ @required this.transDistance, this.index, this.fabs, this.controller, Key key }) : super(key: key);

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
        widget.index * widget.fabSpawnTime,
        widget.index * widget.fabSpawnTime + widget.fabDuration,
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
          transform: Matrix4.translation(Vector3(0.0, -animation.value * widget.transDistance, 0.0)),
          margin: EdgeInsets.all(4.0),
          child: FloatingActionButton.extended(
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
