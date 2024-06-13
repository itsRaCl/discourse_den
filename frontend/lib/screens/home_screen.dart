import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/components/error_snackbar.dart';
import 'package:frontend/components/topic_tile.dart';
import 'package:frontend/constants/constants.dart';
import 'package:frontend/utils/encrypted_storage.dart';
import 'package:frontend/utils/topic_model.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<TopicModel>> getYourTopics() async {
    List<TopicModel> topics = [];
    var (jwt, _) = await EncryptedStorage().get(key: "jwt");
    if (jwt == null) {
      print("huh!");
    }
    var response = await http.get(
      APIConstants.myTopicsUri,
      headers: {"Authorization": "Bearer $jwt"},
    );
    if (response.statusCode == 200) {
      var x = (jsonDecode(response.body)['data'] as List);
      for (var i in x) {
        topics.add(TopicModel.fromJson(i as Map));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(getErrorSnackBar("Some error occured!"));
      }
    }
    return topics;
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
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Container(
              height: 580,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurStyle: BlurStyle.outer,
                    blurRadius: 2,
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your Topics",
                      style: TextStyle(fontSize: 34),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: FutureBuilder(
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.none || snapshot.hasData == false) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else {
                              var data = snapshot.data as List;
                              if (data.isEmpty) {
                                return const Center(
                                    child: Text("Join Some topics!"));
                              }
                              return Center(
                                child: ListView.builder(
                                  itemCount: data.length,
                                  itemBuilder: (context, index) {
                                    return TopicTile(topic: data[index]);
                                  },
                                ),
                              );
                            }
                          },
                          future: getYourTopics()),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
		      Navigator.of(context).pushNamed("/explore");
	      },
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      blurStyle: BlurStyle.outer,
                      blurRadius: 2,
                    )
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Explore", style: TextStyle(fontSize: 34)),
                      Icon(Icons.keyboard_double_arrow_right, size: 34)
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(getErrorSnackBar("Coming Soon!"));
              },
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      blurStyle: BlurStyle.outer,
                      blurRadius: 2,
                    )
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Invites", style: TextStyle(fontSize: 34)),
                      Icon(Icons.keyboard_double_arrow_right, size: 34)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
