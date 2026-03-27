import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/torrent_service.dart';

class DownloadScreen extends StatelessWidget {
  const DownloadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        centerTitle: true,
      ),
      body: Consumer<TorrentService>(
        builder: (context, torrentService, child) {
          if (torrentService.activeDownloads.isEmpty) {
            return const Center(child: Text('No active downloads'));
          }

          return ListView.builder(
            itemCount: torrentService.activeDownloads.length,
            itemBuilder: (context, index) {
              final download = torrentService.activeDownloads[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(download.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(value: download.progress),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${(download.progress * 100).toStringAsFixed(1)}%'),
                          Text(download.speed),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add magnet link dialog
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
