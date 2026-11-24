import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'note.dart';
import 'notes_cubit.dart';
import 'notes_state.dart';

void main() {
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotesCubit(),
      child: MaterialApp(
        title: 'Заметки',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
        home: const NotesScreen(),
      ),
    );
  }
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _editorFocus = FocusNode();

  void _viewNote(Note note) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Заметка'),
        content: SingleChildScrollView(child: SelectableText(note.text)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _editNote(Note note) {
    final cubit = context.read<NotesCubit>();
    final index = cubit.state.notes.indexWhere((item) => item.id == note.id);
    if (index == -1) return;

    cubit.startEditing(index);
    _controller.text = note.text;
    _editorFocus.requestFocus();
  }

  void _deleteNote(int id) {
    final cubit = context.read<NotesCubit>();
    final index = cubit.state.notes.indexWhere((note) => note.id == id);
    if (index == -1) return;

    if (cubit.state.editingIndex == index) {
      _controller.clear();
      _editorFocus.unfocus();
    }
    cubit.deleteNote(index);
  }

  void _saveNote() {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Введите текст заметки')));
      return;
    }

    final cubit = context.read<NotesCubit>();
    final editingIndex = cubit.state.editingIndex;

    if (editingIndex == -1) {
      cubit.addNote(text);
    } else {
      cubit.updateNote(editingIndex, text);
    }

    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _editorFocus.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<NotesCubit, NotesState>(
          builder: (context, state) => Text(
            state.editingIndex != -1 ? 'Редактирование заметки' : 'Мои заметки',
          ),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<NotesCubit, NotesState>(
        builder: (context, state) {
          final isEditing = state.editingIndex != -1;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  focusNode: _editorFocus,
                  maxLines: 4,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: 'Введите текст заметки...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _saveNote,
                        icon: Icon(isEditing ? Icons.check : Icons.save),
                        label: Text(isEditing ? 'Обновить' : 'Сохранить'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    if (isEditing) ...[
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {
                          context.read<NotesCubit>().cancelEditing();
                          _controller.clear();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                        ),
                        child: const Text('Отмена'),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Список заметок',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Всего: ${state.notes.length}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: state.notes.isEmpty
                      ? const Center(
                          child: Text(
                            'Заметок пока нет.\nДобавьте первую!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: state.notes.length,
                          itemBuilder: (context, index) {
                            final note = state.notes[index];
                            final cubit = context.read<NotesCubit>();
                            return Padding(
                              key: ValueKey(note.id),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Dismissible(
                                key: ValueKey(note.id),
                                direction: note.isImportant
                                    ? DismissDirection.horizontal
                                    : DismissDirection.endToStart,
                                background: _swipeBackground(
                                  alignment: Alignment.centerLeft,
                                  color: Colors.indigo,
                                  icon: Icons.star_outline,
                                ),
                                secondaryBackground: _swipeBackground(
                                  alignment: Alignment.centerRight,
                                  color: Colors.red,
                                  icon: Icons.delete_outline,
                                ),
                                confirmDismiss: (direction) async {
                                  if (direction ==
                                      DismissDirection.endToStart) {
                                    return true;
                                  }
                                  cubit.setNoteImportant(note.id, false);
                                  return false;
                                },
                                onDismissed: (_) => _deleteNote(note.id),
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  elevation: 2,
                                  clipBehavior: Clip.antiAlias,
                                  color: note.isImportant
                                      ? Colors.amber.shade100
                                      : state.editingIndex == index
                                      ? Colors.indigo.shade50
                                      : Colors.white,
                                  child: InkWell(
                                    onTap: () => _viewNote(note),
                                    onDoubleTap: () =>
                                        cubit.setNoteImportant(note.id, true),
                                    onLongPress: () => _editNote(note),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.indigo,
                                        foregroundColor: Colors.white,
                                        child: Text('${index + 1}'),
                                      ),
                                      title: Text(
                                        note.text,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (note.isImportant)
                                            const Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              semanticLabel: 'Важная заметка',
                                            ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.orange,
                                            ),
                                            tooltip: 'Редактировать',
                                            onPressed: () => _editNote(note),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            tooltip: 'Удалить',
                                            onPressed: () =>
                                                _deleteNote(note.id),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _swipeBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}
