class SongModel {
  final String videoId;
  final String title;

  SongModel({required this.videoId, required this.title});

  factory SongModel.fromMap(Map data) {
    return SongModel(videoId: data['videoId'], title: data['title']);
  }

  Map<String, dynamic> toMap() {
    return {'videoId': videoId, 'title': title};
  }
}
