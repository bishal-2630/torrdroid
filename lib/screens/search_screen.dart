import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/search_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'All';
  final List<String> _types = ['All', 'Video', 'Audio', 'Apps', 'Games', 'Docs'];

  void _handleSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Provider.of<SearchService>(context, listen: false).search(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TorrDroid Search'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter search term...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _handleSearch,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _handleSearch(),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _types.map((type) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(type),
                      selected: _selectedType == type,
                      onSelected: (selected) {
                        setState(() {
                          _selectedType = type;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<SearchService>(
                builder: (context, searchService, child) {
                  if (searchService.isSearching) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (searchService.results.isEmpty) {
                    return const Center(child: Text('Search something!'));
                  }

                  return ListView.builder(
                    itemCount: searchService.results.length,
                    itemBuilder: (context, index) {
                      final result = searchService.results[index];
                      return Card(
                        child: ListTile(
                          title: Text(result.name),
                          subtitle: Text('${result.size} | S: ${result.seeds} L: ${result.leeches}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: () async {
                              final searchService = Provider.of<SearchService>(context, listen: false);
                              final torrentService = Provider.of<TorrentService>(context, listen: false);
                              
                              // Show loading indicator
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Fetching magnet link...')),
                              );

                              final magnetLink = await searchService.getMagnetLink(result.magnetLink);
                              
                              if (magnetLink.isNotEmpty) {
                                torrentService.addDownload(result.name, magnetLink);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Starting download: ${result.name}')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Failed to fetch magnet link.')),
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
