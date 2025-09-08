import 'package:flutter/material.dart';

class ShortcutsWidget extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  const ShortcutsWidget({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildShortcutItem(
          context: context,
          icon: Icons.touch_app_outlined,
          label: 'Bater ponto',
          isSelected: selectedIndex == 0,
          onTap: () => onIndexChanged(0),
        ),
        _buildShortcutItem(
          context: context,
          icon: Icons.work_outline,
          label: 'Meu RH',
          isSelected: selectedIndex == 1,
          onTap: () => onIndexChanged(1),
        ),
        _buildShortcutItem(
          context: context,
          icon: Icons.receipt_long_outlined,
          label: 'Holerite',
          isSelected: selectedIndex == 2,
          onTap: () => onIndexChanged(2),
        ),
      ],
    );
  }

  Widget _buildShortcutItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.7)
                : const Color(0xFFE0E0E0),
            child: Icon(icon,
                size: 30,
                color: isSelected ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
