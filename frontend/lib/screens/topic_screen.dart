import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/components/error_snackbar.dart';
import 'package:frontend/components/thread_tile.dart';
import 'package:frontend/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/utils/argument_helpers.dart';
import 'package:frontend/utils/encrypted_storage.dart';
import 'package:frontend/utils/topic_screen_model.dart';

class TopicScreen extends StatefulWidget {
  const TopicScreen({super.key});

  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  final TextEditingController _createThreadController = TextEditingController();

  Future<(TopicScreenModel?, Exception?)> fetchTopicScreenApi(
      int topicId) async {
    var (jwt, _) = await EncryptedStorage().get(key: "jwt");

    var response = await http.get(APIConstants.topicScreenUri(topicId),
        headers: {"Authorization": "Bearer $jwt"});

    if (response.statusCode == 200) {
      return (
        TopicScreenModel.fromJson(
            json.decode(response.body) as Map<String, dynamic>),
        null
      );
    } else {
      return (null, Exception("Unknown Error"));
    }
  }

  @override
  Widget build(BuildContext context) {
    int topicId =
        (ModalRoute.of(context)!.settings.arguments as TopicScreenArgs).topicId;
    return Scaffold(
      appBar: AppBar(
        title: const Text("DiscourseDen", style: TextStyle(fontSize: 40)),
        actions: const [
          Icon(
            Icons.account_circle,
            size: 40,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: FutureBuilder(
          future: fetchTopicScreenApi(topicId),
          builder: (context, snapshot) {
            if (snapshot.hasData == false) {
              return const Center(child: CircularProgressIndicator());
            } else {
              var model = snapshot.data?.$1 as TopicScreenModel;
              var topic = model.topic;
              var threads = model.threads;
              List<Widget> buttons;
              if (model.userStatus == "MOD") {
                buttons = [
                  MaterialButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(getErrorSnackBar("Coming Soon!"));
                    },
                    color: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text("Moderate"),
                  ),
                  MaterialButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Create New Thread"),
                              content: TextField(
                                  controller: _createThreadController),
                              actions: [
                                TextButton(
                                    onPressed: () async {
                                      await handleCreate(topic.id);
                                    },
                                    child: const Text("Create")),
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("Cancel"))
                              ],
                            );
                          });
                    },
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text("New Thread"),
                  ),
                  MaterialButton(
                    onPressed: () {},
                    color: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text("Leave"),
                  )
                ];
              } else if (model.userStatus == "MEM") {
                buttons = [
                  MaterialButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Create New Thread"),
                              content: TextField(
                                  controller: _createThreadController),
                              actions: [
                                TextButton(
                                    onPressed: () async {
                                      await handleCreate(topic.id);
                                    },
                                    child: const Text("Create")),
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("Cancel"))
                              ],
                            );
                          });
                    },
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text("New Thread"),
                  ),
                  MaterialButton(
                    onPressed: () {},
                    color: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text("Leave"),
                  )
                ];
              } else {
                buttons = [
                  MaterialButton(
                    onPressed: () {
                      print("pressed");
                    },
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text("Join"),
                  ),
                ];
              }
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(topic.name, style: const TextStyle(fontSize: 34)),
                      Column(children: buttons)
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                        itemCount: threads.length,
                        itemBuilder: (context, index) {
                          return ThreadTile(thread: threads[index]);
                        }),
                  )
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> handleCreate(int topicId) async {
    var (jwt, _) = await EncryptedStorage().get(key: "jwt");

    var threadTitle = _createThreadController.text;
    _createThreadController.clear();

    var response =
        await http.post(APIConstants.createThreadUri(topicId), headers: {
      "Authorization": "Bearer $jwt",
    }, body: {
      "title": threadTitle,
    });

    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          getErrorSnackBar((json.decode(response.body) as Map)["detail"]));
    }
  }
}
