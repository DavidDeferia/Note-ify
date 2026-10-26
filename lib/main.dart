import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const NotepadApp());
}

class Note {
  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
  });

  final String id;
  String title;
  String content;
  DateTime updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        content: json['content'] as String? ?? '',
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

class NotepadApp extends StatelessWidget {
  const NotepadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Notepad',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5267A8),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF6F7FB),
          foregroundColor: Color(0xFF20243A),
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const NotesHomePage(),
    );
  }
}

class NotesHomePage extends StatefulWidget {
  const NotesHomePage({super.key});

  @override
  State<NotesHomePage> createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  static const _storageKey = 'simple_notepad_notes_v1';
  final List<Note> _notes = [];
  final TextEditingController _searchController = TextEditingController();
  bool _loading = true;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _searchController.addListener(() {
      setState(() => _searchText = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_storageKey);
    if (saved != null) {
      try {
        final decoded = jsonDecode(saved) as List<dynamic>;
        _notes
          ..clear()
          ..addAll(decoded.map(
              (item) => Note.fromJson(Map<String, dynamic>.from(item as Map))));
        _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      } catch (_) {
        // If stored data is malformed, open an empty notes list safely.
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_notes.map((note) => note.toJson()).toList()),
    );
  }

  List<Note> get _visibleNotes {
    if (_searchText.isEmpty) return _notes;
    return _notes.where((note) {
      return note.title.toLowerCase().contains(_searchText) ||
          note.content.toLowerCase().contains(_searchText);
    }).toList();
  }

  Future<void> _openEditor({Note? note}) async {
    final result = await Navigator.of(context).push<Note>(
      MaterialPageRoute(
        builder: (_) => NoteEditorPage(existingNote: note),
      ),
    );
    if (result == null) return;

    setState(() {
      final index = _notes.indexWhere((item) => item.id == result.id);
      if (index >= 0) {
        _notes[index] = result;
      } else {
        _notes.add(result);
      }
      _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    });
    await _saveNotes();
  }

  Future<void> _deleteNote(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete note?'),
        content: Text(
            '“${note.title.isEmpty ? 'Untitled note' : note.title}” will be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _notes.removeWhere((item) => item.id == note.id));
    await _saveNotes();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    if (day == today) {
      return 'Today · ${TimeOfDay.fromDateTime(date).format(context)}';
    }
    if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final notes = _visibleNotes;
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Notepad', style: TextStyle(fontWeight: FontWeight.w800)),
            Text('Your thoughts, all in one place',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
          ],
        ),
        toolbarHeight: 76,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text('New note'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search your notes',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Text('Your notes',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4E8F7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${_notes.length}',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : notes.isEmpty
                        ? _EmptyState(
                            searching: _searchText.isNotEmpty,
                            onCreate: () => _openEditor(),
                          )
                        : ListView.separated(
                            itemCount: notes.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final note = notes[index];
                              return Material(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: () => _openEditor(note: note),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 15, 8, 15),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 42,
                                          height: 42,
                                          decoration: BoxDecoration(
                                            color: index.isEven
                                                ? const Color(0xFFE8ECFA)
                                                : const Color(0xFFE3F2EE),
                                            borderRadius:
                                                BorderRadius.circular(13),
                                          ),
                                          child: Icon(
                                            Icons.description_outlined,
                                            color: index.isEven
                                                ? const Color(0xFF5267A8)
                                                : const Color(0xFF438875),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                note.title.trim().isEmpty
                                                    ? 'Untitled note'
                                                    : note.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                note.content.trim().isEmpty
                                                    ? 'No additional text'
                                                    : note.content,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  height: 1.35,
                                                  color:
                                                      Colors.blueGrey.shade600,
                                                ),
                                              ),
                                              const SizedBox(height: 9),
                                              Text(
                                                _formatDate(note.updatedAt),
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color:
                                                      Colors.blueGrey.shade400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Delete note',
                                          onPressed: () => _deleteNote(note),
                                          icon: const Icon(Icons.more_vert),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.searching, required this.onCreate});

  final bool searching;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: Color(0xFFE8ECFA),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.sticky_note_2_outlined,
                  size: 42, color: Color(0xFF5267A8)),
            ),
            const SizedBox(height: 18),
            Text(
              searching ? 'No matching notes' : 'A fresh page awaits',
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              searching
                  ? 'Try another search term.'
                  : 'Create your first note and keep your ideas close.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey.shade600, height: 1.4),
            ),
            if (!searching) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add),
                label: const Text('Create a note'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NoteEditorPage extends StatefulWidget {
  const NoteEditorPage({super.key, this.existingNote});

  final Note? existingNote;

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final String _id;
  late final DateTime _createdAt;

  @override
  void initState() {
    super.initState();
    final note = widget.existingNote;
    _id = note?.id ?? DateTime.now().microsecondsSinceEpoch.toString();
    _createdAt = note?.updatedAt ?? DateTime.now();
    _titleController = TextEditingController(text: note?.title ?? '');
    _contentController = TextEditingController(text: note?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleController.text.trim().isEmpty &&
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write something before saving.')),
      );
      return;
    }
    Navigator.pop(
      context,
      Note(
        id: _id,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.existingNote == null ? 'New note' : 'Edit note'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Save'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                style:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
                decoration: const InputDecoration(
                  hintText: 'Note title',
                  filled: false,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.edit_note, size: 16, color: Colors.blueGrey),
                  const SizedBox(width: 6),
                  Text(
                    'Take a moment and write it down',
                    style: TextStyle(
                        color: Colors.blueGrey.shade500, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: 'Start writing here...',
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
