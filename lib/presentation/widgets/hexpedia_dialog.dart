import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/game_localization.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../domain/models/hexpedia_entry_model.dart';
import '../providers/game_state_notifier.dart';
import 'tactile_neo_button.dart';

class HexpediaDialog extends ConsumerStatefulWidget {
  const HexpediaDialog({super.key});

  @override
  ConsumerState<HexpediaDialog> createState() => _HexpediaDialogState();
}

class _HexpediaDialogState extends ConsumerState<HexpediaDialog> {
  HexpediaCategory _selectedCategory = HexpediaCategory.all;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _expandedIds = {'trade_caravan_routes', 'core_castle'}; // Default expanded

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleExpanded(String id) {
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(gameStateProvider.select((s) => s.settings.activeThemePalette));
    final lang = ref.watch(gameStateProvider.select((s) => s.settings.language));
    final theme = NeoBrutalistTheme.getTheme(palette);

    final entries = HexpediaRepository.search(
      _searchController.text,
      category: _selectedCategory,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 680),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF10B981), width: 2),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor,
              offset: const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // 1. Üst Başlık Barı (Header)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.surfaceLight,
                border: Border(bottom: BorderSide(color: theme.border, width: 2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.menu_book, size: 20, color: Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      GameLocalization.get('hexpedia_title', lang: lang),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF064E3B),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: const Color(0xFF10B981), width: 1),
                    ),
                    child: Text(
                      '${entries.length} REHBER',
                      style: const TextStyle(
                        color: Color(0xFF6EE7B7),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TactileNeoButton(
                    onTap: () => Navigator.of(context).pop(),
                    height: 28,
                    width: 28,
                    padding: EdgeInsets.zero,
                    alignment: Alignment.center,
                    backgroundColor: theme.surfaceLight,
                    borderColor: theme.slateBorder,
                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ],
              ),
            ),

            // 2. Canlı Arama Kutusu (Search Input)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: const Color(0xFF090D16),
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: theme.slateBorder, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: GameLocalization.get('hexpedia_search_hint', lang: lang),
                          hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 16, color: Color(0xFF94A3B8)),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),

            // 3. Kategori Filtre Butonları (Category Tabs)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(
                color: theme.surfaceLight,
                border: Border(bottom: BorderSide(color: theme.border, width: 1.5)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: HexpediaCategory.values.map((cat) {
                    final bool isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: TactileNeoButton(
                        onTap: () {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        },
                        height: 30,
                        backgroundColor: isSelected ? const Color(0xFF059669) : theme.surface,
                        borderColor: isSelected ? const Color(0xFF34D399) : theme.slateBorder,
                        shadowColor: theme.shadowColor,
                        shadowOffset: isSelected ? 2.0 : 1.0,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              cat.icon,
                              size: 13,
                              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              cat.getTitle(lang),
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                                fontSize: 10,
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // 4. Ansiklopedi Giriş Listesi (Articles List)
            Expanded(
              child: entries.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.search_off, size: 40, color: Color(0xFF64748B)),
                            const SizedBox(height: 12),
                            Text(
                              GameLocalization.get('hexpedia_empty', lang: lang),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: entries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        final isExpanded = _expandedIds.contains(entry.id);
                        return _buildEntryCard(entry, isExpanded, lang, theme);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryCard(
    HexpediaEntry entry,
    bool isExpanded,
    String lang,
    NeoBrutalistThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: isExpanded ? entry.iconColor : theme.slateBorder,
          width: isExpanded ? 1.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            offset: const Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header (Tıklanabilir Başlık)
          InkWell(
            onTap: () => _toggleExpanded(entry.id),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: entry.iconColor.withAlpha(40),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: entry.iconColor, width: 1.2),
                    ),
                    child: Center(
                      child: Icon(entry.icon, size: 18, color: entry.iconColor),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (entry.badgeText.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: entry.iconColor.withAlpha(50),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Text(
                                  entry.badgeText,
                                  style: TextStyle(
                                    color: entry.iconColor,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Expanded(
                              child: Text(
                                entry.getTitle(lang),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          entry.getSummary(lang),
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: isExpanded ? 3 : 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF94A3B8),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Genişletilmiş Detaylar (Expanded Body)
          if (isExpanded) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFF1E293B), width: 1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  // Detaylı Açıklama
                  Text(
                    entry.getContent(lang),
                    style: const TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),

                  // 1. Mekanik Verileri & Formüller (Stats)
                  if (entry.stats.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: const Color(0xFF334155), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.tune, size: 12, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 5),
                              Text(
                                GameLocalization.get('hexpedia_stats', lang: lang),
                                style: const TextStyle(
                                  color: Color(0xFFF59E0B),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ...entry.stats.entries.map((st) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 3),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${st.key}: ',
                                    style: const TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      st.value,
                                      style: const TextStyle(
                                        color: Color(0xFFF1F5F9),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],

                  // 2. Adım Adım Rehber (Step-by-Step Guide)
                  if (entry.getStepGuide(lang).isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF064E3B).withAlpha(80),
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: const Color(0xFF059669), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.alt_route, size: 12, color: Color(0xFF34D399)),
                              const SizedBox(width: 5),
                              Text(
                                GameLocalization.get('hexpedia_step_guide', lang: lang),
                                style: const TextStyle(
                                  color: Color(0xFF34D399),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ...entry.getStepGuide(lang).map((step) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.arrow_right, size: 14, color: Color(0xFF6EE7B7)),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      step,
                                      style: const TextStyle(
                                        color: Color(0xFFE2E8F0),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],

                  // 3. Taktiksel İpuçları (Tips)
                  if (entry.getTips(lang).isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF082F49).withAlpha(80),
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: const Color(0xFF0284C7), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.tips_and_updates, size: 12, color: Color(0xFF38BDF8)),
                              const SizedBox(width: 5),
                              Text(
                                GameLocalization.get('hexpedia_tips', lang: lang),
                                style: const TextStyle(
                                  color: Color(0xFF38BDF8),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ...entry.getTips(lang).map((tip) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 3),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(color: Color(0xFF7DD3FC), fontSize: 11, fontWeight: FontWeight.bold)),
                                  Expanded(
                                    child: Text(
                                      tip,
                                      style: const TextStyle(
                                        color: Color(0xFFBAE6FD),
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
