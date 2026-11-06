import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:doghree_rider/common/widgets/custom_image_widget.dart';

/// Full-screen photo viewer: pinch / double-tap to zoom, drag down to dismiss.
class ImageDialogWidget extends StatefulWidget {
  final String imageUrl;
  const ImageDialogWidget({super.key, required this.imageUrl});

  @override
  State<ImageDialogWidget> createState() => _ImageDialogWidgetState();
}

class _ImageDialogWidgetState extends State<ImageDialogWidget>
    with SingleTickerProviderStateMixin {
  final TransformationController _transform = TransformationController();
  late final AnimationController _zoomCtrl;
  Animation<Matrix4>? _zoomAnim;
  Offset _doubleTapAt = Offset.zero;

  double _dragY = 0;
  bool _dragging = false;

  double get _scale => _transform.value.getMaxScaleOnAxis();

  @override
  void initState() {
    super.initState();
    _zoomCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(() {
        final Matrix4? m = _zoomAnim?.value;
        if (m != null) _transform.value = m;
      });
  }

  @override
  void dispose() {
    _zoomCtrl.dispose();
    _transform.dispose();
    super.dispose();
  }

  void _toggleZoom() {
    final Matrix4 end;
    if (_scale > 1.05) {
      end = Matrix4.identity();
    } else {
      const double zoom = 2.5;
      end = Matrix4.diagonal3Values(zoom, zoom, 1)
        ..setTranslationRaw(
          -_doubleTapAt.dx * (zoom - 1),
          -_doubleTapAt.dy * (zoom - 1),
          0,
        );
    }
    _zoomAnim = Matrix4Tween(begin: _transform.value, end: end).animate(
      CurvedAnimation(parent: _zoomCtrl, curve: Curves.easeOutCubic),
    );
    _zoomCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    // 0 = resting, 1 = dragged far enough to fade everything out.
    final double fade = (_dragY.abs() / 320).clamp(0.0, 1.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Dialog.fullscreen(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            // Backdrop: near-black, fades while dragging down.
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.96 - 0.6 * fade),
              ),
            ),

            // The photo.
            Positioned.fill(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: _dragY),
                duration: _dragging
                    ? Duration.zero
                    : const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                builder: (BuildContext context, double dy, Widget? child) =>
                    Transform.translate(offset: Offset(0, dy), child: child),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onDoubleTapDown: (TapDownDetails d) =>
                      _doubleTapAt = d.localPosition,
                  onDoubleTap: _toggleZoom,
                  child: InteractiveViewer(
                    transformationController: _transform,
                    minScale: 1,
                    maxScale: 4,
                    onInteractionStart: (ScaleStartDetails d) {
                      _dragging = d.pointerCount == 1 && _scale <= 1.02;
                    },
                    onInteractionUpdate: (ScaleUpdateDetails d) {
                      if (d.pointerCount > 1) {
                        _dragging = false;
                      } else if (_dragging) {
                        setState(() => _dragY += d.focalPointDelta.dy);
                      }
                    },
                    onInteractionEnd: (ScaleEndDetails d) {
                      final bool dismiss = _dragging &&
                          (_dragY.abs() > 110 ||
                              (_dragY.abs() > 40 &&
                                  d.velocity.pixelsPerSecond.dy.abs() > 900));
                      if (dismiss) {
                        Navigator.of(context).pop();
                      } else {
                        setState(() {
                          _dragging = false;
                          _dragY = 0;
                        });
                      }
                    },
                    child: SizedBox.expand(
                      child: CustomImageWidget(
                        image: widget.imageUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Soft top scrim so the close button is readable on any photo.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 120,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 1 - fade,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.55),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Close button: screen corner, outside the photo.
            SafeArea(
              child: Align(
                alignment: AlignmentDirectional.topEnd,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Opacity(
                    opacity: 1 - fade,
                    child: _CloseButton(
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 42,
          height: 42,
          child: Icon(Icons.close_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}