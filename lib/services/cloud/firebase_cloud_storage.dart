import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';
import 'package:mynotes/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  // singleton logic
  static final FirebaseCloudStorage _shared = FirebaseCloudStorage._instance();
  FirebaseCloudStorage._instance();
  factory FirebaseCloudStorage() => _shared;

  // the 'stream' kind equivalent of firestore, acts like a CRUD layer
  final notes = FirebaseFirestore.instance.collection('notes');

  Future<CloudNote> createNewNote({required userId}) async {
    // document reference of the newly created note
    final doc = await notes.add({
      userIdFieldName: userId,
      textFieldName: '',
    });

    // get() function actually grabs the note
    final note = await doc.get();

    // return the cloud note
    return CloudNote(docId: note.id, userId: userId, text: '');
  }

  Future<Iterable<CloudNote>> getNotes({required String userId}) async {
    try {
      return await notes
          .where(
            userIdFieldName,
            isEqualTo: userId,
          )
          .get()
          .then(
            (value) => value.docs.map((doc) => CloudNote.fromSnapshot(doc)),
          );
    } catch (e) {
      throw CouldNotReadException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String userId}) => notes.snapshots().map((event) =>
      event.docs.map((doc) => CloudNote.fromSnapshot(doc)).where((note) => note.userId == userId));

  Future<void> updateNote({required docId, required text}) async {
    try {
      await notes.doc(docId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateException();
    }
  }

  Future<void> deleteNote({required docId}) async {
    try {
      await notes.doc(docId).delete();
    } catch (e) {
      throw CouldNotDeleteException();
    }
  }
}
