import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/widgets/workout/set_list_item_textfield.dart';

class SetListItem extends StatelessWidget {
  const SetListItem({
    super.key,
    required this.index,
    required this.leadingColor,
    required this.onRemove,
    required this.repsController,
    required this.weightController,
    required this.isWarmup,
    this.previousWorkoutSummary,
  });

  final int index;
  final String? previousWorkoutSummary;
  final bool isWarmup;
  final TextEditingController repsController;
  final TextEditingController weightController;
  final void Function(int index) onRemove;

  final Color leadingColor;

  void _showSetsActionSheet({required BuildContext context}) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              onRemove(index);
            },
            child: const Text('Remove set'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile.notched(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      backgroundColor: const Color.fromRGBO(25, 28, 36, 1),
      leading: CircleAvatar(
        backgroundColor: leadingColor,
        child: Text(
          isWarmup ? "W${index + 1}" : "${index + 1}",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
              fontSize: isWarmup ? 12 : null),
        ),
      ),
      title: Row(
        children: [
          const SizedBox(
            width: 18,
          ),
          SetListItemTextField(
            label: 'Reps',
            textEditingController: repsController,
          ),
          const SizedBox(
            width: 28,
          ),
          SetListItemTextField(
            label: 'kg',
            textEditingController: weightController,
          ),
          const SizedBox(
            width: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Past"),
              const SizedBox(
                height: 8,
              ),
              Text(previousWorkoutSummary ?? "No data",
                  style:
                      TextStyle(color: CupertinoColors.white.withOpacity(0.7)))
            ],
          )
        ],
      ),
      trailing: GestureDetector(
          onTap: () => _showSetsActionSheet(context: context),
          child: const Icon(CupertinoIcons.ellipsis)),
    );
  }
}
