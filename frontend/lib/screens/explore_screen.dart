import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/components/topic_tile.dart';
import 'package:frontend/constants/constants.dart';
import 'package:frontend/utils/encrypted_storage.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/utils/topic_model.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<TopicModel> _topics = [];

  @override
  void initState() {
    super.initState();

    getAllTopics();
  }

  Future<List<TopicModel>> fetchAllTopicsApi() async {
    List<TopicModel> topics = [];
    var (jwt, _) = await EncryptedStorage().get(key: "jwt");

    if (jwt == null) {
      print("huh!");
      return topics;
    }
    var response = await http.get(APIConstants.allTopicsUri,
        headers: {"Authorization": "Bearer $jwt"});

    if (response.statusCode == 200) {
      var x = (json.decode(response.body)['data'] as List);

      for (var i in x) {
        topics.add(TopicModel.fromJson(i as Map));
      }
    }

    return topics;
  }

  Future<Null> getAllTopics() async {
    var topics = await fetchAllTopicsApi();
    setState(() {
      _topics = topics;
    });
  }

  Future<void> filterResults(String query) async {
    var topics = await fetchAllTopicsApi();
    List<TopicModel> results = [];
    for (var i in topics) {
      if (i.topicName.contains(query)) {
        results.add(i);
      }
    }
    setState(() {
          _topics = results;
        });
  }

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(
                height: 15,
              ),
              TextField(
                onChanged: (String query){
			filterResults(query);
		},
                decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    hintText: "Search"),
              ),
              const SizedBox(
                height: 15,
              ),
              Expanded(
                  child: ListView.builder(
                      itemCount: _topics.length,
                      itemBuilder: (context, index) {
                        return TopicTile(topic: _topics[index]);
                      }))
            ],
          ),
        ));
  }
}
