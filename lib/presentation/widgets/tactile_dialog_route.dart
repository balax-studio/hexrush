import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// SwiftUI-tarzı Yay Fiziğine (Spring Physics & Curves.easeOutBack) Sahip Taktil Neo-Brutalist Dialog Açıcı
Future<T?> showNeoTactileDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color barrierColor = const Color(0x99020617),
}) {
  HapticFeedback.lightImpact();

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'Dismiss Modal',
    barrierColor: barrierColor,
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (ctx, anim1, anim2) => builder(ctx),
    transitionBuilder: (ctx, anim1, anim2, child) {
      final curved = CurvedAnimation(
        parent: anim1,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      );

      final scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(curved);
      final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: anim1, curve: Curves.easeOut),
      );
      final slideAnim = Tween<Offset>(
        begin: const Offset(0.0, 0.04),
        end: Offset.zero,
      ).animate(curved);

      return SlideTransition(
        position: slideAnim,
        child: ScaleTransition(
          scale: scaleAnim,
          child: FadeTransition(
            opacity: fadeAnim,
            child: child,
          ),
        ),
      );
    },
  );
}
