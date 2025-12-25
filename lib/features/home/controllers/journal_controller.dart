import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../../../core/data/db_helper.dart';
import '../../../core/utils/mood_analyzer.dart';

class JournalController extends ChangeNotifier {
  List<JournalEntry> _allJournals = []; 
  List<JournalEntry> _displayJournals = []; 
  List<JournalEntry> _deletedJournals = [];

  List<JournalEntry> get journals => _displayJournals;
  List<JournalEntry> get deletedJournals => _deletedJournals;
  
  String _searchQuery = "";
  bool _showFavoritesOnly = false;

  // --- FIX: Expose this value to the UI ---
  bool get showFavoritesOnly => _showFavoritesOnly; 

  Future<void> loadJournals() async {
    _allJournals = await DBHelper.instance.readAllJournals();
    _applyFilters(); 
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void toggleShowFavorites(bool enable) {
    _showFavoritesOnly = enable;
    _applyFilters();
  }

  void _applyFilters() {
    _displayJournals = _allJournals.where((entry) {
      final matchesSearch = entry.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                            entry.content.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFavorite = _showFavoritesOnly ? entry.isFavorite : true;
      return matchesSearch && matchesFavorite;
    }).toList();
    
    notifyListeners();
  }

  Future<void> toggleFavorite(JournalEntry entry) async {
    final updatedEntry = JournalEntry(
      id: entry.id,
      title: entry.title,
      content: entry.content,
      date: entry.date,
      isDeleted: entry.isDeleted,
      imageBase64: entry.imageBase64,
      mood: entry.mood,
      isFavorite: !entry.isFavorite, 
    );

    await DBHelper.instance.update(updatedEntry);
    await loadJournals(); 
  }

  Map<String, int> getWeeklyMoodStats() {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final weeklyEntries = _allJournals.where((e) => e.date.isAfter(sevenDaysAgo));
    
    Map<String, int> stats = {};
    for (var entry in weeklyEntries) {
      final mood = entry.mood ?? 'Unknown';
      stats[mood] = (stats[mood] ?? 0) + 1;
    }
    return stats;
  }

  Future<void> addJournal(String title, String content, String? imageBase64) async {
    String detectedMood = MoodAnalyzer.analyze("$title $content");
    final newEntry = JournalEntry(
      title: title,
      content: content,
      date: DateTime.now(),
      imageBase64: imageBase64,
      isDeleted: false,
      mood: detectedMood,
      isFavorite: false,
    );
    await DBHelper.instance.create(newEntry);
    await loadJournals(); 
  }

  Future<void> updateJournal(int id, String title, String content, String? imageBase64) async {
    String detectedMood = MoodAnalyzer.analyze("$title $content");
    final oldEntry = _allJournals.firstWhere((e) => e.id == id);
    
    final updatedEntry = JournalEntry(
      id: id,
      title: title,
      content: content,
      date: DateTime.now(),
      imageBase64: imageBase64,
      isDeleted: false,
      mood: detectedMood,
      isFavorite: oldEntry.isFavorite, 
    );
    await DBHelper.instance.update(updatedEntry);
    await loadJournals();
  }
  
  Future<void> moveToBin(JournalEntry entry) async {
    final deletedEntry = JournalEntry(
      id: entry.id,
      title: entry.title,
      content: entry.content,
      date: entry.date,
      isDeleted: true,
      imageBase64: entry.imageBase64,
      mood: entry.mood,
      isFavorite: entry.isFavorite,
    );
    await DBHelper.instance.update(deletedEntry);
    await loadJournals(); 
  }
  
  Future<void> loadDeletedJournals() async {
    _deletedJournals = await DBHelper.instance.readDeletedJournals();
    notifyListeners();
  }

  Future<void> restoreJournal(JournalEntry entry) async {
    final restoredEntry = JournalEntry(
      id: entry.id,
      title: entry.title,
      content: entry.content,
      date: entry.date,
      isDeleted: false, 
      imageBase64: entry.imageBase64,
      mood: entry.mood,
      isFavorite: entry.isFavorite
    );
    await DBHelper.instance.update(restoredEntry);
    await loadDeletedJournals();
    await loadJournals(); 
  }

  Future<void> deletePermanently(int id) async {
    await DBHelper.instance.delete(id);
    _deletedJournals.removeWhere((j) => j.id == id);
    notifyListeners();
  }
}