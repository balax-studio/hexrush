import 'package:flutter/material.dart';
import '../../core/audio/tactile_audio_service.dart';

/// HexRush Taktil Neo-Brutalist Mekanik Buton
/// Fiziksel basma hissi (çökme ve gölge sıfırlanması), yaylanma ve dokunsal haptik titreşim sağlar.
class TactileNeoButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color borderColor;
  final Color shadowColor;
  final double shadowOffset;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool isEnabled;
  final TactileSoundType soundType;

  const TactileNeoButton({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor = const Color(0xFF1E293B),
    this.borderColor = Colors.black,
    this.shadowColor = Colors.black,
    this.shadowOffset = 3.0,
    this.borderRadius = 3.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    this.isEnabled = true,
    this.soundType = TactileSoundType.tap,
  });

  @override
  State<TactileNeoButton> createState() => _TactileNeoButtonState();
}

class _TactileNeoButtonState extends State<TactileNeoButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isEnabled || widget.onTap == null) return;
    TactileAudioService.instance.play(widget.soundType);
    setState(() {
      _isPressed = true;
    });
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isEnabled || widget.onTap == null) return;
    setState(() {
      _isPressed = false;
    });
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    if (!widget.isEnabled || widget.onTap == null) return;
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool active = widget.isEnabled && widget.onTap != null;
    final double currentOffset = (_isPressed && active) ? widget.shadowOffset : 0.0;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.opaque,
      child: Transform.translate(
        offset: Offset(currentOffset, currentOffset),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 60),
          curve: Curves.easeOutQuad,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: active
                ? widget.backgroundColor
                : const Color(0xFF334155).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: active ? widget.borderColor : const Color(0xFF475569),
              width: 1.8,
            ),
            boxShadow: (_isPressed || !active)
                ? const []
                : [
                    BoxShadow(
                      color: widget.shadowColor,
                      offset: Offset(widget.shadowOffset, widget.shadowOffset),
                      blurRadius: 0.0,
                    ),
                  ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
