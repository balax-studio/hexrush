import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/doctrine_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';

void main() {
  group('Civic Doctrines & Kurultay Tests', () {
    test('Initial doctrines contain preset cards with unlocked defaults', () {
      final doctrines = DoctrineCardModel.getInitialDoctrines();
      expect(doctrines.length, greaterThanOrEqualTo(8));

      final sulama = doctrines.where((d) => d.id == 'doc_sulama_fermani').first;
      expect(sulama.isUnlocked, isTrue);
      expect(sulama.slotType, DoctrineSlotType.economic);

      final akinci = doctrines.where((d) => d.id == 'doc_bozkir_akincisi').first;
      expect(akinci.isUnlocked, isTrue);
      expect(akinci.slotType, DoctrineSlotType.military);
    });

    test('EconomyCalculator applies doctrine production multiplier correctly', () {
      final activeDocs = [
        const DoctrineCardModel(
          id: 'doc_sulama_fermani',
          titleTr: 'Sulama Fermanı',
          titleEn: 'Irrigation Decree',
          descriptionTr: '',
          descriptionEn: '',
          slotType: DoctrineSlotType.economic,
          effectType: DoctrineEffectType.cropBonus,
          effectValue: 0.25,
          unlockCastleLevel: 1,
          isUnlocked: true,
        ),
      ];

      final cornMult = EconomyCalculator.getDoctrineProductionMultiplier(
        buildingType: BuildingType.corn,
        activeDoctrines: activeDocs,
      );
      expect(cornMult, closeTo(1.25, 0.001));

      final lumberjackMult = EconomyCalculator.getDoctrineProductionMultiplier(
        buildingType: BuildingType.lumberjack,
        activeDoctrines: activeDocs,
      );
      expect(lumberjackMult, closeTo(1.0, 0.001));
    });

    test('Conquest discount doctrine reduces expansion cost', () {
      final activeDocs = [
        const DoctrineCardModel(
          id: 'doc_bozkir_akincisi',
          titleTr: 'Bozkır Akıncısı',
          titleEn: 'Steppe Raider',
          descriptionTr: '',
          descriptionEn: '',
          slotType: DoctrineSlotType.military,
          effectType: DoctrineEffectType.conquestDiscount,
          effectValue: 0.20,
          unlockCastleLevel: 1,
          isUnlocked: true,
        ),
      ];

      final mult = EconomyCalculator.getConquestCostMultiplier(activeDocs);
      expect(mult, closeTo(0.80, 0.001));
    });

    test('Winter warm doctrine reduces heating wood cost', () {
      final activeDocs = [
        const DoctrineCardModel(
          id: 'doc_kis_otagi',
          titleTr: 'Kış Otağı',
          titleEn: 'Winter Yurt Lodge',
          descriptionTr: '',
          descriptionEn: '',
          slotType: DoctrineSlotType.nomadic,
          effectType: DoctrineEffectType.winterWarmDiscount,
          effectValue: 3.0,
          unlockCastleLevel: 1,
          isUnlocked: true,
        ),
      ];

      final cost = EconomyCalculator.getWinterWarmWoodCost(activeDocs);
      expect(cost, closeTo(2.0, 0.001));
    });

    test('GameStateNotifier equips and unequips doctrines safely', () {
      final notifier = GameStateNotifier();
      expect(notifier.state.activeDoctrineSlots[DoctrineSlotType.economic], 'doc_sulama_fermani');

      // Unequip
      notifier.equipDoctrine(DoctrineSlotType.economic, null);
      expect(notifier.state.activeDoctrineSlots[DoctrineSlotType.economic], isNull);

      // Equip again
      notifier.equipDoctrine(DoctrineSlotType.economic, 'doc_sulama_fermani');
      expect(notifier.state.activeDoctrineSlots[DoctrineSlotType.economic], 'doc_sulama_fermani');
    });
  });
}
