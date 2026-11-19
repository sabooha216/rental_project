import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmptyState extends StatelessWidget {
  final String messageKey;
  const EmptyState(this.messageKey, {super.key});

  @override
  Widget build(BuildContext context) =>
      Center(child: Text(messageKey.tr, style: const TextStyle(color: Colors.grey)));
}
