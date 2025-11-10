import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// عنصر قائمة قابل للسحب
class SwipeableListItem extends StatelessWidget {
  final Widget child;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onArchive;
  final Color deleteColor;
  final Color editColor;
  final Color archiveColor;

  const SwipeableListItem({
    super.key,
    required this.child,
    this.onDelete,
    this.onEdit,
    this.onArchive,
    this.deleteColor = Colors.red,
    this.editColor = Colors.blue,
    this.archiveColor = Colors.orange,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      background: _buildSwipeBackground(Alignment.centerRight, deleteColor, Icons.delete, 'حذف'),
      secondaryBackground: _buildSwipeBackground(Alignment.centerLeft, editColor, Icons.edit, 'تعديل'),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd && onDelete != null) {
          final confirm = await _showConfirmDialog(context, 'حذف', 'هل تريد حذف هذا العنصر؟');
          if (confirm == true) {
            onDelete!();
            return true;
          }
        } else if (direction == DismissDirection.endToStart && onEdit != null) {
          onEdit!();
        }
        return false;
      },
      child: child,
    );
  }

  Widget _buildSwipeBackground(Alignment alignment, Color color, IconData icon, String label) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmDialog(BuildContext context, String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('تأكيد')),
        ],
      ),
    );
  }
}
