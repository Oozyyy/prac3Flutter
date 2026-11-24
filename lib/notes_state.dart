import 'note.dart';

class NotesState {
  final List<Note> notes;
  final int editingIndex;

  NotesState({required this.notes, required this.editingIndex});

  NotesState copyWith({List<Note>? notes, int? editingIndex}) {
    return NotesState(
      notes: notes ?? this.notes,
      editingIndex: editingIndex ?? this.editingIndex,
    );
  }
}
