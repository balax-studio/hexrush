import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../providers/game_state_notifier.dart';

class ToastOverlay extends ConsumerStatefulWidget {
  const ToastOverlay({super.key});

  @override
  ConsumerState<ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends ConsumerState<ToastOverlay> {
  Timer? _timer;
  String? _lastToast;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeToast = ref.watch(
      gameStateProvider.select((s) => s.activeToast),
    );

    if (activeToast != null && activeToast != _lastToast) {
      _lastToast = activeToast;
      _timer?.cancel();
      _timer = Timer(const Duration(milliseconds: 2500), () {
        if (mounted) {
          ref.read(gameStateProvider.notifier).clearToast();
        }
      });
    }

    if (activeToast == null) return const SizedBox.shrink();

    // IgnorePointer ile altındaki karo/buton tıklamaları asla engellenmez!
    return Positioned(
      top: MediaQuery.of(context).padding.top + 80,
      left: 20,
      right: 20,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 200),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: NeoBrutalistTheme.bgDark,
                borderRadius: NeoBrutalistTheme.standardRadius,
                border: Border.all(color: const Color(0xFFFFC700), width: 2.0),
                boxShadow: NeoBrutalistTheme.hardShadow(offset: 4.0),
              ),
              child: Text(
                activeToast,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
