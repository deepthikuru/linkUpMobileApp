import 'package:flutter/material.dart';
import '../utils/theme.dart';
import 'mesh_background.dart';

class MeshScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final bool animated;
  final int pointCount;
  final double maxDistance;
  final Color? gradientStart;
  final Color? gradientEnd;
  final AlignmentGeometry gradientBegin;
  final AlignmentGeometry gradientEndAlignment;

  const MeshScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.animated = true,
    this.pointCount = 30,
    this.maxDistance = 150,
    this.gradientStart,
    this.gradientEnd,
    this.gradientBegin = Alignment.topLeft,
    this.gradientEndAlignment = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: appBar,
      body: MeshBackground(
        animated: animated,
        pointCount: pointCount,
        maxDistance: maxDistance,
        gradientStart: gradientStart,
        gradientEnd: gradientEnd,
        gradientBegin: gradientBegin,
        gradientEndAlignment: gradientEndAlignment,
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

