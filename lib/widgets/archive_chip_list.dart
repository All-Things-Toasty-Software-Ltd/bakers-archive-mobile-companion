import 'package:flutter/material.dart';
import '../core/theme/bread_colors.dart';
import '../data/models/archive_model.dart';

/// Horizontal scrolling list of archive selector chips.
class ArchiveChipList extends StatelessWidget {
  final List<ArchiveModel> archives;
  final ArchiveModel? selectedArchive;
  final ValueChanged<ArchiveModel?> onSelected;

  const ArchiveChipList({
    super.key,
    required this.archives,
    required this.selectedArchive,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isAllSelected = selectedArchive == null;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // "All" chip
          ChoiceChip(
            label: const Text('All Archives'),
            selected: isAllSelected,
            onSelected: (_) => onSelected(null),
            showCheckmark: false,
            avatar: isAllSelected
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
            selectedColor: BreadColors.crustGoldDark,
          ),
          const SizedBox(width: 8),

          // Archive specific chips
          ...archives.map((archive) {
            final isSelected = selectedArchive?.id == archive.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(archive.name),
                selected: isSelected,
                onSelected: (_) => onSelected(archive),
                showCheckmark: false,
                avatar: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
                selectedColor: BreadColors.crustGoldDark,
              ),
            );
          }),
        ],
      ),
    );
  }
}
