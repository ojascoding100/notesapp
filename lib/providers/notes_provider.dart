import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';

class NotesProvider extends ChangeNotifier {
  static const String _storageKey = 'notes_list';

  List<Note> _notes = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  List<String> get categories {
    final cats = <String>{'All'};
    for (final note in _notes) {
      if (note.category.isNotEmpty) {
        cats.add(note.category);
      }
    }
    return cats.toList();
  }

  List<Note> get filteredNotes {
    if (_selectedCategory == 'All') return _notes;
    return _notes.where((n) => n.category == _selectedCategory).toList();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(_storageKey);
      if (jsonList != null) {
        _notes = jsonList.map((json) => Note.fromJson(json)).toList();
        _notes.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
      }
    } catch (e) {
      _notes = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _notes.map((note) => note.toJson()).toList();
      await prefs.setStringList(_storageKey, jsonList);
    } catch (_) {}
  }

  Future<void> addNote(Note note) async {
    _notes.insert(0, note);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> updateNote(Note updatedNote) async {
    final index = _notes.indexWhere((n) => n.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote;
      await _saveToPrefs();
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    await _saveToPrefs();
    notifyListeners();
  }
}
