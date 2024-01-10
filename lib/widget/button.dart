import 'package:flutter/material.dart';


class ShapeBezierTop extends CustomClipper<Path> {
  final double height;

  ShapeBezierTop({this.height = 0.0});  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - height);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 30);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class ShapeBezierRightToLeft extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const double curveHeight = 20.0;

    path.lineTo(size.width - curveHeight, 0.0);
    path.quadraticBezierTo(size.width, 0.0, size.width, curveHeight);
    path.lineTo(size.width, size.height - curveHeight);
    path.quadraticBezierTo(size.width, size.height, size.width - curveHeight, size.height);
    path.lineTo(0.0, size.height);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class ShapeBezierLeftToRight extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width, 0);
    path.quadraticBezierTo(size.width / 2, size.height, 0, size.height - 100);
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


class ShapeBezierBottom extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 30);
    path.quadraticBezierTo(size.width / 2, 0, size.width, 30);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class DiagonalClipper extends CustomClipper<Path> {
  final DiagonalPosition position;
  final double angle;
  final DiagonalDirection direction;

  DiagonalClipper({
    required this.position,
    required this.angle,
    required this.direction,
  });

  @override
  Path getClip(Size size) {
    final diagHeight = size.height;

    var path = Path();

    if (direction == DiagonalDirection.right) {
      path.lineTo(0, position == DiagonalPosition.top ? diagHeight : 10);

      path.lineTo(size.width,
          position == DiagonalPosition.top ? size.height : diagHeight);
    } else {
      path.lineTo(size.width, position == DiagonalPosition.top ? diagHeight : size.height);

      path.lineTo(0,
          position == DiagonalPosition.top ? size.height : diagHeight);
    }

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

enum DiagonalPosition {
  top,
  bottom,
}

enum DiagonalDirection {
  left,
  right
}
