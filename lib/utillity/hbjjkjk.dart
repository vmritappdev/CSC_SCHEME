import 'package:flutter/material.dart';

class BouncingDotsLoader extends StatefulWidget {
  final Color color;
  final double size;

  const BouncingDotsLoader({
    Key? key,
    this.color = const Color(0xFF002970), // Paytm Blue
    this.size = 10.0,
  }) : super(key: key);

  @override
  _BouncingDotsLoaderState createState() => _BouncingDotsLoaderState();
}

class _BouncingDotsLoaderState extends State<BouncingDotsLoader>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      4,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      ),
    );

    _animations = _controllers
        .map((controller) => Tween(begin: 0.0, end: -10.0)
            .chain(CurveTween(curve: Curves.easeInOut))
            .animate(controller))
        .toList();

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size * 3,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(4, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                transform: Matrix4.translationValues(
                  0.0,
                  _animations[index].value,
                  0.0,
                ),
                child: Dot(
                  color: widget.color,
                  size: widget.size,
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

class Dot extends StatelessWidget {
  final double size;
  final Color color;

  const Dot({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
