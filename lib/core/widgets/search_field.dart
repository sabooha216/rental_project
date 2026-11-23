import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchField extends StatelessWidget {
  final String hintKey;
  final ValueChanged<String> onChanged;
  const SearchField({super.key, required this.hintKey, required this.onChanged});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        child: TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: hintKey.tr,
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
}

/// Horizontal row of choice chips bound to an RxInt (index of the selected chip).
class FilterChips extends StatelessWidget {
  final List<String> labelKeys;
  final RxInt selected;
  const FilterChips({super.key, required this.labelKeys, required this.selected});

  @override
  Widget build(BuildContext context) => Obx(() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(children: [
          for (int i = 0; i < labelKeys.length; i++)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                label: Text(labelKeys[i].tr),
                selected: selected.value == i,
                onSelected: (_) => selected.value = i,
              ),
            ),
        ]),
      ));
}
