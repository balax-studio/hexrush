import 'package:flutter/material.dart';
import '../../core/localization/game_localization.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import 'icons/game_vector_icons.dart';
import 'tactile_dialog_route.dart';

Future<bool> showAdRewardProgressDialog(
  BuildContext context, {
  String? title,
  String? message,
  String lang = 'tr',
}) async {
  final displayTitle = title ?? GameLocalization.get('reward_processing', lang: lang);
  final displayMessage = message ?? GameLocalization.get('reward_processing_please_wait', lang: lang);

  final result = await showNeoTactileDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _AdRewardProgressDialogWidget(
      title: displayTitle,
      message: displayMessage,
    ),
  );
  return result ?? false;
}

class _AdRewardProgressDialogWidget extends StatefulWidget {
  final String title;
  final String message;

  const _AdRewardProgressDialogWidget({
    required this.title,
    required this.message,
  });

  @override
  State<_AdRewardProgressDialogWidget> createState() =>
      __AdRewardProgressDialogWidgetState();
}

class __AdRewardProgressDialogWidgetState
    extends State<_AdRewardProgressDialogWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _controller.forward().then((_) {
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: NeoBrutalistTheme.surface,
            borderRadius: NeoBrutalistTheme.standardRadius,
            border: Border.all(color: const Color(0xFFD97706), width: 2.5),
            boxShadow: NeoBrutalistTheme.hardShadow(offset: 4.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const GameVectorIcon(
                    type: GameIconType.frenzy,
                    size: 20,
                    color: Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.title.toUpperCase(),
                    style: NeoBrutalistTheme.fontHeaderMonolith.copyWith(
                      color: const Color(0xFFF59E0B),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final remainingSec = (5.0 * (1.0 - _controller.value)).ceil();
                  return Text(
                    '${widget.message} (${remainingSec}s)',
                    textAlign: TextAlign.center,
                    style: NeoBrutalistTheme.fontLabel.copyWith(
                      color: const Color(0xFFCBD5E1),
                      fontSize: 12,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final progress = _controller.value;
                  return Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF060913),
                      borderRadius: NeoBrutalistTheme.sharpRadius,
                      border: Border.all(color: const Color(0xFF334155), width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: NeoBrutalistTheme.sharpRadius,
                      child: Stack(
                        children: [
                          FractionallySizedBox(
                            widthFactor: progress.clamp(0.0, 1.0),
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFD97706),
                                    Color(0xFFF59E0B),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              '${(progress * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
