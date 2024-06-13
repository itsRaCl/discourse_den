class TopicScreenModel{
  final String userStatus;
  final Topic topic;
  final List<Thread> threads;

  TopicScreenModel({
    required this.userStatus,
    required this.topic,
    required this.threads,
  });

  factory TopicScreenModel.fromJson(Map<String, dynamic> json) {
    return TopicScreenModel(
      userStatus: json['user_status'],
      topic: Topic.fromJson(json['topic']),
      threads: (json['threads'] as List<dynamic>)
          .map((threadJson) => Thread.fromJson(threadJson))
          .toList(),
    );
  }
}

class Topic {
  final int id;
  final String name;
  final String description;
  final DateTime createdAt;
  final String owner;

  Topic({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.owner,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      owner: json['owner'],
    );
  }
}

class Thread {
  final int id;
  final String title;
  final String? createdBy;
  final DateTime createdAt;
  final int likeCount;
  final int dislikeCount;
  final int commentCount;

  Thread({
    required this.id,
    required this.title,
    required this.createdBy,
    required this.createdAt,
    required this.likeCount,
    required this.dislikeCount,
    required this.commentCount,
  });

  factory Thread.fromJson(Map<String, dynamic> json) {
    return Thread(
      id: json['id'],
      title: json['title'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      likeCount: json['like_count'],
      dislikeCount: json['dislike_count'],
      commentCount: json['comment_count'],
    );
  }
}
