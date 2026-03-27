import 'package:flutter/material.dart';
import '../models/search_result.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';

class SearchService with ChangeNotifier {
  List<SearchResult> _results = [];
  bool _isSearching = false;

  List<SearchResult> get results => _results;
  bool get isSearching => _isSearching;

  Future<void> search(String query) async {
    _isSearching = true;
    _results = [];
    notifyListeners();
    try {
      if (kIsWeb) {
        _results = await _searchViaProxy(query);
      } else {
        // For now, let's implement a sample scraper for a popular site or a mock response
        // In a real app, you would have multiple scrapers
        if (query == 'test') {
          _results = [
            SearchResult(
              name: 'Ubuntu 22.04 Desktop',
              size: '3.4 GB',
              seeds: 1200,
              leeches: 45,
              magnetLink: 'magnet:?xt=urn:btih:...',
              source: '1337x',
            ),
          ];
        } else {
          _results = await _scrape1337x(query);
        }
      }
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<List<SearchResult>> _scrape1337x(String query) async {
    final searchUrl = 'https://1337x.to/search/$query/1/';
    final response = await http.get(Uri.parse(searchUrl));
    
    if (response.statusCode != 200) return [];

    final document = parser.parse(response.body);
    final rows = document.querySelectorAll('table.table-list tbody tr');
    
    List<SearchResult> results = [];
    for (var row in rows) {
      final cells = row.querySelectorAll('td');
      if (cells.length < 6) continue;

      final nameElement = cells[0].querySelectorAll('a')[1];
      final name = nameElement.text;
      final size = cells[4].text;
      final seeds = int.tryParse(cells[1].text) ?? 0;
      final leeches = int.tryParse(cells[2].text) ?? 0;
      final detailUrl = 'https://1337x.to${nameElement.attributes['href']}';

      results.add(SearchResult(
        name: name,
        size: size,
        seeds: seeds,
        leeches: leeches,
        magnetLink: detailUrl, // Store detail URL temporarily
        source: '1337x',
      ));
    }
    return results;
  }

  Future<List<SearchResult>> _searchViaProxy(String query) async {
    final response = await http.get(Uri.parse('/api/search?q=$query'));
    if (response.statusCode != 200) return [];
    
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) => SearchResult(
      name: item['name'],
      size: item['size'],
      seeds: int.tryParse(item['seeds'].toString()) ?? 0,
      leeches: int.tryParse(item['leeches'].toString()) ?? 0,
      magnetLink: item['detail_url'],
      source: item['source'],
    )).toList();
  }

  Future<String> getMagnetLink(String detailUrl) async {
    try {
      if (kIsWeb) {
        final response = await http.get(Uri.parse('/api/magnet?url=$detailUrl'));
        if (response.statusCode != 200) return '';
        final data = json.decode(response.body);
        return data['magnet'] ?? '';
      }
      
      final response = await http.get(Uri.parse(detailUrl));
      if (response.statusCode != 200) return '';

      final document = parser.parse(response.body);
      final magnetLink = document.querySelector('ul.dropdown-menu li a[href^="magnet:"]')?.attributes['href'];
      return magnetLink ?? '';
    } catch (e) {
      return '';
    }
  }
}
