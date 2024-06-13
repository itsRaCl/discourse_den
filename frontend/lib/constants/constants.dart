class APIConstants{
	static final loginUri = Uri.http('localhost:8000', 'api/auth/login/');
	static final myTopicsUri = Uri.http('localhost:8000', 'api/topic/my');
	static final allTopicsUri = Uri.http('localhost:8000', 'api/topic/');

	static Uri topicScreenUri(int topicId){
		return Uri.http('localhost:8000', 'api/topic/$topicId/threads');
	}

	static Uri createThreadUri(int topicId){
		return Uri.http('localhost:8000', 'api/topic/$topicId/threads/');
	}
}
