import 'package:flutter/material.dart';
import '../models/user_model.dart';

class ProjectTile extends StatelessWidget {
  final ProjectUser projectUser;

  const ProjectTile({super.key, required this.projectUser});

  @override
  Widget build(BuildContext context) {
    final isValidated = projectUser.validated;
    final finalMark = projectUser.finalMark;
    final isCompleted = projectUser.isCompleted;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(isValidated, isCompleted),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getBorderColor(isValidated, isCompleted),
          width: 1,
        ),
      ),
      child: ListTile(
        dense: true,
        title: Text(
          projectUser.project.name,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        subtitle: Text(
          _getStatusText(isValidated, isCompleted),
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: finalMark != null
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isValidated ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$finalMark%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
            : Icon(_getStatusIcon(isCompleted), color: Colors.grey[400]),
      ),
    );
  }

  Color _getBackgroundColor(bool isValidated, bool isCompleted) {
    if (!isCompleted) return Colors.grey[50]!;
    return isValidated ? Colors.green[50]! : Colors.red[50]!;
  }

  Color _getBorderColor(bool isValidated, bool isCompleted) {
    if (!isCompleted) return Colors.grey[300]!;
    return isValidated ? Colors.green[200]! : Colors.red[200]!;
  }

  String _getStatusText(bool isValidated, bool isCompleted) {
    if (!isCompleted) return 'In progress';
    return isValidated ? 'Validated' : 'Failed';
  }

  IconData _getStatusIcon(bool isCompleted) {
    return isCompleted ? Icons.check_circle_outline : Icons.hourglass_empty;
  }
}
