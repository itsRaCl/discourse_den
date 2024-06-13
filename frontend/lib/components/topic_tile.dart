import 'package:flutter/material.dart';
import 'package:frontend/utils/argument_helpers.dart';
import 'package:frontend/utils/topic_model.dart';

class TopicTile extends StatelessWidget {
  const TopicTile({super.key, required this.topic});

  final TopicModel topic;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed("/topic",
            arguments: TopicScreenArgs(topicId: topic.topicId));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            height: 100,
            decoration: BoxDecoration(
                color: Colors.black, borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(topic.topicName, style: const TextStyle(fontSize: 20)),
                  const Icon(Icons.keyboard_double_arrow_right, size: 20)
                ],
              ),
            )),
      ),
    );
  }
}
