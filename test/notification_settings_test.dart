import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/domain/models/game_state_model.dart';

void main() {
  group('NotificationSettingsModel Tests', () {
    test('Default values are correct and active', () {
      const model = NotificationSettingsModel();
      expect(model.enabled, isTrue);
      expect(model.idle1hAlert, isTrue);
      expect(model.idle4hAlert, isTrue);
      expect(model.dailyCouncilAlert, isTrue);
      expect(model.dailyHarvestAlert, isTrue);
      expect(model.inactivityAlert, isTrue);
    });

    test('copyWith updates specific notification properties', () {
      const model = NotificationSettingsModel();
      final updated = model.copyWith(
        enabled: false,
        idle1hAlert: false,
        idle4hAlert: true,
      );

      expect(updated.enabled, isFalse);
      expect(updated.idle1hAlert, isFalse);
      expect(updated.idle4hAlert, isTrue);
      expect(updated.dailyCouncilAlert, isTrue);
    });

    test('toJson and fromJson work seamlessly and backward compatible', () {
      const model = NotificationSettingsModel(
        enabled: false,
        idle1hAlert: false,
        idle4hAlert: true,
        dailyCouncilAlert: true,
        dailyHarvestAlert: false,
        inactivityAlert: true,
      );

      final json = model.toJson();
      final fromJson = NotificationSettingsModel.fromJson(json);

      expect(fromJson.enabled, isFalse);
      expect(fromJson.idle1hAlert, isFalse);
      expect(fromJson.idle4hAlert, isTrue);
      expect(fromJson.dailyCouncilAlert, isTrue);
      expect(fromJson.dailyHarvestAlert, isFalse);
      expect(fromJson.inactivityAlert, isTrue);
    });

    test('SettingsModel serializes and deserializes notification settings correctly', () {
      const settings = SettingsModel(
        language: 'tr',
        notifications: NotificationSettingsModel(
          enabled: true,
          idle1hAlert: true,
          idle4hAlert: true,
          dailyCouncilAlert: false,
        ),
      );

      final json = settings.toJson();
      final deserialized = SettingsModel.fromJson(json);

      expect(deserialized.notifications.enabled, isTrue);
      expect(deserialized.notifications.idle1hAlert, isTrue);
      expect(deserialized.notifications.idle4hAlert, isTrue);
      expect(deserialized.notifications.dailyCouncilAlert, isFalse);
    });
  });
}
