class TopicModel {
  final int topicId;
  final String topicName;
  final String topicDescription;
  final String createdAt;
  final int owner;

  const TopicModel(
      {required this.topicId,
      required this.topicName,
      required this.topicDescription,
      required this.createdAt,
      required this.owner});

  factory TopicModel.fromJson(Map json) {
    var x = TopicModel(
        topicId: json['id'],
        topicName: json['name'],
        topicDescription: json['description'],
        createdAt: json['created_at'],
        owner: json['owner']);
    return x;
  }
}
