import 'package:flutter/material.dart';
import '../models/download_task.dart';

class TorrentService with ChangeNotifier {
  List<DownloadTask> _activeDownloads = [];

  List<DownloadTask> get activeDownloads => _activeDownloads;

  void addDownload(String name, String magnetLink) {
    final task = DownloadTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );
    _activeDownloads.add(task);
    _startDownload(task);
    notifyListeners();
  }

  void _startDownload(DownloadTask task) async {
    // In a real app, this would use libtorrent_flutter
    // Mocking progress for now
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      task.progress = i / 100.0;
      task.speed = '${(100 + i).toString()} KB/s';
      notifyListeners();
    }
    task.status = 'Completed';
    notifyListeners();
  }
}
