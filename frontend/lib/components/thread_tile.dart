import 'package:flutter/material.dart';
import 'package:frontend/utils/topic_screen_model.dart';

class ThreadTile extends StatelessWidget {
  const ThreadTile({super.key, required this.thread});

  final Thread thread;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
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
                  Expanded(
                    child: Text(
                      thread.title,
                      style: const TextStyle(fontSize: 20),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Icon(Icons.thumb_up, size: 16),
                            const SizedBox(width: 4),
                            Text("${thread.likeCount}",
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Icon(Icons.thumb_down, size: 16),
                            const SizedBox(width: 4),
                            Text("${thread.dislikeCount}",
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ]),
                  const SizedBox(width: 10),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.schedule),
                            const SizedBox(width: 4),
                            Text(
                              "${thread.createdAt.day}/${thread.createdAt.month}/${thread.createdAt.year} ${thread.createdAt.hour}:${thread.createdAt.minute}",
                              style: const TextStyle(fontSize: 12),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.account_circle),
                            const SizedBox(width: 4),
                            Text("${thread.createdBy}"),
                          ],
                        )
                      ]),
                  const SizedBox(width: 10),
                  const Icon(Icons.keyboard_double_arrow_right, size: 20)
                ],
              ),
            )),
      ),
    );
  }
}
