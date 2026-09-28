import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/localization/game_localization.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import 'tactile_neo_button.dart';

class RateGameDialog extends StatelessWidget {
  const RateGameDialog({
    super.key,
    required this.language,
    required this.theme,
  });

  final String language;
  final NeoBrutalistThemeData theme;

  static final Uri _playStoreUri = Uri.https(
    'play.google.com',
    '/store/apps/details',
    {'id': 'com.balax.hexrush'},
  );
  static final Uri _appStoreUri = Uri.https('apps.apple.com', '/search', {
    'term': 'HexRush',
  });

  Future<void> _openStore(BuildContext context) async {
    final Uri uri = defaultTargetPlatform == TargetPlatform.iOS
        ? _appStoreUri
        : _playStoreUri;
    Navigator.of(context).pop();
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: theme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: NeoBrutalistTheme.sharpRadius,
        side: BorderSide(color: theme.border, width: 2.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rate_rounded, color: theme.primaryGold, size: 34),
            const SizedBox(height: 10),
            Text(
              GameLocalization.get(
                'rate_game_title',
                lang: language,
              ).toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              GameLocalization.get('rate_game_body', lang: language),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: TactileNeoButton(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _openStore(context);
                },
                backgroundColor: const Color(0xFF78350F),
                borderColor: theme.primaryGold,
                shadowColor: const Color(0xFF020617),
                height: 42,
                alignment: Alignment.center,
                padding: EdgeInsets.zero,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: theme.primaryGold,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      GameLocalization.get(
                        'rate_game_action',
                        lang: language,
                      ).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TactileNeoButton(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                },
                backgroundColor: const Color(0xFF0F172A),
                borderColor: theme.border,
                shadowColor: const Color(0xFF020617),
                height: 36,
                alignment: Alignment.center,
                padding: EdgeInsets.zero,
                child: Text(
                  GameLocalization.get(
                    'rate_game_later',
                    lang: language,
                  ).toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
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
