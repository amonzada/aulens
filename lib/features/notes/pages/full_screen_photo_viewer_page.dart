import 'dart:io';

import 'package:flutter/material.dart';

import '../models/note.dart';

/// Full-screen photo viewer with zoom and pan support.
class FullScreenPhotoViewerPage extends StatefulWidget {
  final List<Note> photos;
  final int initialIndex;

  const FullScreenPhotoViewerPage({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<FullScreenPhotoViewerPage> createState() =>
      _FullScreenPhotoViewerPageState();
}

class _FullScreenPhotoViewerPageState extends State<FullScreenPhotoViewerPage> {
  late final PageController _pageController;
  final Map<int, TransformationController> _transformControllers = {};

  late int _currentIndex;
  bool _currentImageZoomed = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _transformControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TransformationController _controllerFor(int index) {
    return _transformControllers.putIfAbsent(
      index,
      () => TransformationController(),
    );
  }

  void _handleScaleChange(int index) {
    if (!mounted || index != _currentIndex) return;
    final scale = _controllerFor(index).value.getMaxScaleOnAxis();
    final zoomed = scale > 1.0;
    if (_currentImageZoomed == zoomed) return;
    setState(() => _currentImageZoomed = zoomed);
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      _currentImageZoomed =
          _controllerFor(index).value.getMaxScaleOnAxis() > 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.photos.length;

    if (count == 0) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('${_currentIndex + 1} / $count'),
        centerTitle: true,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 160),
        child: PageView.builder(
          key: ValueKey(_currentImageZoomed),
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics: _currentImageZoomed
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          itemCount: count,
          itemBuilder: (context, index) {
            final note = widget.photos[index];
            final imagePath = note.imagePath;
            if (imagePath == null || imagePath.trim().isEmpty) {
              return const SizedBox.shrink();
            }

            return _ZoomablePhotoPage(
              imagePath: imagePath,
              controller: _controllerFor(index),
              onTransformChanged: () => _handleScaleChange(index),
              heroTag: index == widget.initialIndex
                  ? 'note-photo-${note.id ?? imagePath}-${note.createdAt.millisecondsSinceEpoch}'
                  : null,
              colorScheme: cs,
            );
          },
        ),
      ),
    );
  }
}

class _ZoomablePhotoPage extends StatefulWidget {
  final String imagePath;
  final TransformationController controller;
  final VoidCallback onTransformChanged;
  final String? heroTag;
  final ColorScheme colorScheme;

  const _ZoomablePhotoPage({
    required this.imagePath,
    required this.controller,
    required this.onTransformChanged,
    required this.heroTag,
    required this.colorScheme,
  });

  @override
  State<_ZoomablePhotoPage> createState() => _ZoomablePhotoPageState();
}

class _ZoomablePhotoPageState extends State<_ZoomablePhotoPage> {
  TapDownDetails? _doubleTapDown;

  void _onDoubleTap() {
    final tapPosition = _doubleTapDown?.localPosition;
    if (tapPosition == null) return;

    final currentScale = widget.controller.value.getMaxScaleOnAxis();
    if (currentScale > 1.0) {
      widget.controller.value = Matrix4.identity();
      widget.onTransformChanged();
      return;
    }

    const targetScale = 2.5;
    final x = -tapPosition.dx * (targetScale - 1);
    final y = -tapPosition.dy * (targetScale - 1);

    widget.controller.value = Matrix4.identity()
      ..translateByDouble(x, y, 0, 1)
      ..scaleByDouble(targetScale, targetScale, 1, 1);
    widget.onTransformChanged();
  }

  @override
  Widget build(BuildContext context) {
    final image = Image.file(
      File(widget.imagePath),
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => Container(
        width: 220,
        height: 220,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.broken_image_outlined,
          size: 48,
          color: widget.colorScheme.outlineVariant,
        ),
      ),
    );

    return GestureDetector(
      onDoubleTapDown: (details) => _doubleTapDown = details,
      onDoubleTap: _onDoubleTap,
      child: Center(
        child: InteractiveViewer(
          transformationController: widget.controller,
          minScale: 1.0,
          maxScale: 6.0,
          panEnabled: true,
          scaleEnabled: true,
          boundaryMargin: const EdgeInsets.all(80),
          clipBehavior: Clip.none,
          onInteractionUpdate: (_) => widget.onTransformChanged(),
          onInteractionEnd: (_) => widget.onTransformChanged(),
          child: widget.heroTag == null
              ? image
              : Hero(tag: widget.heroTag!, child: image),
        ),
      ),
    );
  }
}
