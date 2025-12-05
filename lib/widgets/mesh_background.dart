import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/theme.dart';

// Structure to hold globe data
class GlobeData {
  final Offset center;
  final double radius;
  final double baseOpacity;
  final List<Offset> points;
  final int latRings;
  final int lonLines;

  GlobeData({
    required this.center,
    required this.radius,
    required this.baseOpacity,
    required this.points,
    required this.latRings,
    required this.lonLines,
  });
}

class MeshPainter extends CustomPainter {
  final double maxDistance;
  final List<GlobeData>? fixedGlobes; // For animation consistency
  final double animationOffset; // For parallax effect
  final double opacityMultiplier; // Multiplier for mesh opacity (0.0 to 1.0)

  MeshPainter({
    this.maxDistance = 150,
    this.fixedGlobes,
    this.animationOffset = 0.0,
    this.opacityMultiplier = 1.0,
  });

  final Random _random = Random(42); // Fixed seed for consistency

  // Generate points for a single globe at a specific center and size
  List<Offset> _generateGlobePoints({
    required Offset center,
    required double radius,
    required int latRings,
    required int lonLines,
  }) {
    final List<Offset> points = [];
    
    for (int lat = 0; lat <= latRings; lat++) {
      final double theta = (lat / latRings) * pi; // 0 to π
      final double y = cos(theta);
      final double ringRadius = sin(theta);
      
      // Points per latitude ring (fewer at poles)
      final int pointsPerRing = (lat == 0 || lat == latRings) 
          ? 1 
          : (lonLines * ringRadius).round().clamp(3, lonLines);
      
      for (int lon = 0; lon < pointsPerRing; lon++) {
        final double phi = (lon / pointsPerRing) * 2 * pi; // 0 to 2π
        final double x = cos(phi) * ringRadius;
        final double z = sin(phi) * ringRadius;
        
        // Project 3D sphere point to 2D (orthographic projection)
        final double projectedX = center.dx + x * radius;
        final double projectedY = center.dy + y * radius;
        
        // Add subtle variation for more organic look
        final double variation = 0.08;
        final double finalX = projectedX + (x * radius * variation * _random.nextDouble() - variation * radius * 0.5);
        final double finalY = projectedY + (y * radius * variation * _random.nextDouble() - variation * radius * 0.5);
        
        points.add(Offset(finalX, finalY));
      }
    }
    
    return points;
  }

  // Check if a globe would overlap with existing globes
  bool _wouldOverlap({
    required Offset center,
    required double radius,
    required List<GlobeData> existingGlobes,
    required double minSpacing,
  }) {
    for (final existing in existingGlobes) {
      final distance = (center - existing.center).distance;
      final requiredDistance = radius + existing.radius + minSpacing;
      if (distance < requiredDistance) {
        return true;
      }
    }
    return false;
  }

  // Calculate globe count based on page height
  int _calculateGlobeCount(Size size) {
    // Base calculation: approximately 1 globe per 120 pixels of height
    // This ensures dense distribution with many visible globes
    final double baseHeight = 120.0;
    final int baseCount = (size.height / baseHeight).round();
    
    // Also consider width to ensure good coverage
    final double baseWidth = 120.0;
    final int widthCount = (size.width / baseWidth).round();
    
    // Use the average of height and width based counts for better distribution
    final int totalCount = ((baseCount + widthCount) / 2).round();
    
    // Ensure minimum of 10 and maximum of 50 globes for much better visibility
    return totalCount.clamp(10, 50);
  }

  // Generate multiple globes at random positions with spacing
  List<GlobeData> generateGlobes(Size size) {
    final List<GlobeData> globes = [];
    final int globeCount = _calculateGlobeCount(size);
    
    // Minimum spacing between globes (as a multiplier of the larger radius)
    // Reduced to allow many more globes to fit
    final double minSpacingMultiplier = 0.8;
    
    // Size ranges (slightly smaller minimum to allow more globes)
    final double minRadius = 50;
    final double maxRadius = 120;
    
    int attempts = 0;
    const int maxAttempts = 1500; // Increased for placing more globes
    
    for (int i = 0; i < globeCount; i++) {
      bool placed = false;
      int placementAttempts = 0;
      
      while (!placed && placementAttempts < maxAttempts) {
        placementAttempts++;
        
        // Random center position (allowing partial globes off-screen)
        // Centers can be placed from -maxRadius to size.width + maxRadius
        // This allows globes to appear at top/bottom/edges with half showing
        final double centerX = -maxRadius + _random.nextDouble() * (size.width + 2 * maxRadius);
        final double centerY = -maxRadius + _random.nextDouble() * (size.height + 2 * maxRadius);
        final Offset center = Offset(centerX, centerY);
        
        // Random size
        final double radius = minRadius + _random.nextDouble() * (maxRadius - minRadius);
        
        // Check if this position would cause overlap
        if (!_wouldOverlap(
          center: center,
          radius: radius,
          existingGlobes: globes,
          minSpacing: radius * minSpacingMultiplier,
        )) {
          // Random opacity (all subtle, between 0.08 and 0.18)
          final double baseOpacity = 0.08 + _random.nextDouble() * 0.10;
          
          // Increased complexity for more points (more detailed globes)
          final int latRings = (6 + (radius / 15)).round().clamp(6, 12);
          final int lonLines = (8 + (radius / 12)).round().clamp(8, 16);
          
          final points = _generateGlobePoints(
            center: center,
            radius: radius,
            latRings: latRings,
            lonLines: lonLines,
          );
          
          globes.add(GlobeData(
            center: center,
            radius: radius,
            baseOpacity: baseOpacity,
            points: points,
            latRings: latRings,
            lonLines: lonLines,
          ));
          
          placed = true;
        }
      }
      
      attempts += placementAttempts;
      if (attempts > maxAttempts * 2) {
        // If we're having too much trouble placing globes, break
        break;
      }
    }
    
    return globes;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Generate or use fixed globes
    final globes = fixedGlobes ?? generateGlobes(size);

    // Draw each globe
    for (final globe in globes) {
      // Apply subtle animation offset if provided (globe rotation effect)
      final animatedPoints = animationOffset != 0.0
          ? globe.points.map((p) {
              final angle = atan2(p.dy - globe.center.dy, p.dx - globe.center.dx);
              final distance = (globe.center - p).distance;
              final newDistance = distance + sin(animationOffset + angle * 2) * 1.5;
              return Offset(
                globe.center.dx + cos(angle) * newDistance,
                globe.center.dy + sin(angle) * newDistance,
              );
            }).toList()
          : globe.points;

      // Line paint with light blue color and varying opacity (reduced brightness)
      final linePaint = Paint()
        ..strokeWidth = 0.8;

      // Draw connecting lines within this globe (increased max distance for more lines)
      final localMaxDistance = globe.radius * 0.85; // Increased from 0.6 to create more connections
      for (int i = 0; i < animatedPoints.length; i++) {
        for (int j = i + 1; j < animatedPoints.length; j++) {
          final distance = (animatedPoints[i] - animatedPoints[j]).distance;
          if (distance < localMaxDistance) {
            // Reduced line opacity by 30% for less brightness, then apply multiplier
            final opacity = (1 - distance / localMaxDistance) * globe.baseOpacity * 0.7 * opacityMultiplier;
            // Use light blue color similar to the image
            linePaint.color = const Color(0xFF87CEEB).withOpacity(opacity);
            canvas.drawLine(animatedPoints[i], animatedPoints[j], linePaint);
          }
        }
      }

      // Draw dots with brightness based on distance from center
      for (final point in animatedPoints) {
        // Calculate distance from center
        final distanceFromCenter = (point - globe.center).distance;
        final normalizedDistance = (distanceFromCenter / globe.radius).clamp(0.0, 1.0);
        
        // Center dots are brighter, outer dots are dimmer
        // Center (distance = 0) gets full brightness, edge (distance = radius) gets reduced brightness
        final centerBrightness = 1.0 - (normalizedDistance * 0.4); // Center is 100% bright, edge is 60%
        final dotOpacity = globe.baseOpacity * 3.5 * centerBrightness * opacityMultiplier; // Increased base brightness, apply multiplier
        
        final dotPaint = Paint()
          ..color = const Color(0xFFB0E0E6).withOpacity(dotOpacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5)
          ..style = PaintingStyle.fill;
        
        // Slightly larger dots at center
        final dotSize = 1.5 + (1.0 - normalizedDistance) * 0.5; // 1.5 to 2.0 based on distance
        canvas.drawCircle(point, dotSize, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant MeshPainter oldDelegate) {
    return oldDelegate.animationOffset != animationOffset ||
           oldDelegate.maxDistance != maxDistance ||
           oldDelegate.fixedGlobes != fixedGlobes ||
           oldDelegate.opacityMultiplier != opacityMultiplier;
  }
}

/// Reusable mesh background widget
class MeshBackground extends StatefulWidget {
  final Widget child;
  final Color? gradientStart;
  final Color? gradientEnd;
  final double maxDistance;
  final bool animated;
  final AlignmentGeometry gradientBegin;
  final AlignmentGeometry gradientEndAlignment;
  final double meshOpacity; // Opacity multiplier for mesh (0.0 to 1.0), default 1.0

  const MeshBackground({
    super.key,
    required this.child,
    this.gradientStart,
    this.gradientEnd,
    this.maxDistance = 150,
    this.animated = false,
    this.gradientBegin = Alignment.topLeft,
    this.gradientEndAlignment = Alignment.bottomRight,
    this.meshOpacity = 0.6, // Reduced from 1.0 to make background less bright
  });

  @override
  State<MeshBackground> createState() => _MeshBackgroundState();
}

class _MeshBackgroundState extends State<MeshBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<GlobeData>? _fixedGlobes;

  @override
  void initState() {
    super.initState();
    if (widget.animated) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 20),
      )..repeat();
    }
  }

  @override
  void dispose() {
    if (widget.animated) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get colors from theme or use defaults
    final startColor = widget.gradientStart ??
        AppTheme.mainBlueDynamic(context);
    final endColor = widget.gradientEnd ??
        AppTheme.secondBlueDynamic(context);

    // Generate fixed globes once if not already generated
    if (_fixedGlobes == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final size = MediaQuery.of(context).size;
          final painter = MeshPainter(maxDistance: widget.maxDistance);
          setState(() {
            _fixedGlobes = painter.generateGlobes(size);
          });
        }
      });
    }

    return Stack(
      children: [
        // Gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: widget.gradientBegin,
              end: widget.gradientEndAlignment,
              colors: [startColor, endColor],
            ),
          ),
        ),
        // Mesh overlay
        if (widget.animated)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: MeshPainter(
                  maxDistance: widget.maxDistance,
                  fixedGlobes: _fixedGlobes,
                  animationOffset: _controller.value * 2 * pi,
                  opacityMultiplier: widget.meshOpacity,
                ),
              );
            },
          )
        else
          CustomPaint(
            size: Size.infinite,
            painter: MeshPainter(
              maxDistance: widget.maxDistance,
              fixedGlobes: _fixedGlobes,
              opacityMultiplier: widget.meshOpacity,
            ),
          ),
        // Content
        widget.child,
      ],
    );
  }
}
