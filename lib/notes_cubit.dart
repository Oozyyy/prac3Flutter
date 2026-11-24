import 'package:flutter_bloc/flutter_bloc.dart';
import 'note.dart';
import 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit() : super(NotesState(notes: [], editingIndex: -1));

  int _nextId = 0;

  void addNote(String text) {
    final newNote = Note(id: _nextId++, text: text);
    emit(state.copyWith(notes: [...state.notes, newNote]));
  }

  void updateNote(int index, String text) {
    final updated = [...state.notes];
    updated[index] = updated[index].copyWith(text: text);
    emit(state.copyWith(notes: updated, editingIndex: -1));
  }

  void setNoteImportant(int id, bool isImportant) {
    final index = state.notes.indexWhere((note) => note.id == id);
    if (index == -1 || state.notes[index].isImportant == isImportant) {
      return;
    }

    final updated = [...state.notes];
    updated[index] = updated[index].copyWith(isImportant: isImportant);
    emit(state.copyWith(notes: updated));
  }

  void deleteNote(int index) {
    final updated = [...state.notes]..removeAt(index);
    int newEditingIndex = state.editingIndex;
    if (newEditingIndex == index) {
      newEditingIndex = -1;
    } else if (newEditingIndex > index) {
      newEditingIndex--;
    }
    emit(state.copyWith(notes: updated, editingIndex: newEditingIndex));
  }

  void startEditing(int index) {
    emit(state.copyWith(editingIndex: index));
  }

  void cancelEditing() {
    emit(state.copyWith(editingIndex: -1));
  }
}
