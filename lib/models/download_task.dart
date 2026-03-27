class DownloadTask {
  final String id;
  final String name;
  double progress;
  String speed;
  String status;

  DownloadTask({
    required this.id,
    required this.name,
    this.progress = 0.0,
    this.speed = '0 KB/s',
    this.status = 'Queued',
  });
}
