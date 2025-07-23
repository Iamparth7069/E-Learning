import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubCategoryFilterBar extends StatelessWidget {
  final RxInt selectedId;
  final List subCategories;
  final void Function(int) onSelected;

  const SubCategoryFilterBar({
    super.key,
    required this.selectedId,
    required this.subCategories,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Container(
        height: 60,
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ListView.builder(

          scrollDirection: Axis.horizontal,
          itemCount: subCategories.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              final isSelected = selectedId.value == 0;
              return _buildChip("All", isSelected, () => onSelected(0));
            } else {
              final sub = subCategories[index - 1];
              final isSelected = sub.subCategoryId == selectedId.value;
              return _buildChip(sub.name, isSelected,
                      () => onSelected(sub.subCategoryId));
            }
          },
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: Colors.indigo,
        backgroundColor: Colors.grey[200],
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.indigo : Colors.grey.shade400,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
