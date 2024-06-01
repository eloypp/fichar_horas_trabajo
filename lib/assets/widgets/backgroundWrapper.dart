import 'package:flutter/material.dart';

class BackgroundWrapper extends StatelessWidget {
  final Widget child;

  const BackgroundWrapper({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("lib/assets/images/fondo_ficharHoras.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
