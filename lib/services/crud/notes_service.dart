import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mynotes/services/crud/crud_exceptions.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class NotesService {
  Database? _db;

  List<DatabaseNote> _notes = [];

  // making NotesService a singleton
  static final NotesService _shared = NotesService._instance();
  NotesService._instance();
  factory NotesService() => _shared;

  // stream of notes
  final _notesStreamController = StreamController<List<DatabaseNote>>.broadcast();

  // getter for all stream notes
  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;

  // pre-loading notes into the application
  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    // initialise the _notes
    _notes = allNotes.toList();
    // hook _notes to the notes stream controller
    _notesStreamController.add(_notes);
  }

  Database _getDB() {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpenException();
    } else {
      return db;
    }
  }

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    DatabaseUser user;
    try {
      user = await getUser(email: email);
    } on UserNotFound {
      user = await createUser(email: email);
    } catch (e) {
      // catched excpetions and throws it to the caller
      rethrow;
    }

    return user;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbOpen();
    final db = _getDB();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    // if email found in table, user already exists
    if (results.isEmpty) {
      throw UserNotFound();
    }

    return DatabaseUser.fromRow(results.first);
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbOpen();
    final db = _getDB();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    // if email found in table, user already exists
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }

    // add user
    final id = await db.insert(userTable, {
      emailCol: email.toLowerCase(),
    });

    return DatabaseUser(id: id, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbOpen();
    final db = _getDB();
    // sqflite syntax
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Future<void> _ensureDbOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      // empty
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }

    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      // create sql tables - user, note
      db.execute(createUserTable);
      db.execute(createNoteTable);

      // loading cache notes
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpenException();
    }
    // close db
    await db.close();
    _db = null;
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbOpen();
    final db = _getDB();
    // ensure owner exists in DB
    final user = await getUser(email: owner.email);
    if (user != owner) {
      throw UserNotFound();
    }

    final id = await db.insert(noteTable, {
      userIdCol: owner.id,
      textCol: '',
      isSyncedCol: 1,
    });

    final note = DatabaseNote(
      id: id,
      userId: owner.id,
      text: '',
      isSynced: true,
    );

    // add note to ther array
    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  Future<void> deleteNote({required int noteId}) async {
    await _ensureDbOpen();
    final db = _getDB();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [noteId],
    );

    if (deletedCount != 1) {
      throw NoteNotFound();
    }

    _notes.removeWhere((note) => note.id == noteId);
    _notesStreamController.add(_notes);
  }

  Future<int> deleteAllNotes({required DatabaseUser owner}) async {
    await _ensureDbOpen();
    final db = _getDB();
    final deletionsCount = await db.delete(noteTable);
    // empty the notes array
    _notes = [];
    _notesStreamController.add(_notes);
    return deletionsCount;
  }

  Future<DatabaseNote> getNote({required int noteId}) async {
    await _ensureDbOpen();
    final db = _getDB();
    final results = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [noteId],
    );
    if (results.isEmpty) {
      throw NoteNotFound();
    }

    final note = DatabaseNote.fromRow(results.first);

    // update the current note to the latest version
    _notes.removeWhere((note) => note.id == noteId);
    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbOpen();
    final db = _getDB();
    // get all rows
    final results = await db.query(noteTable);

    // maps every note row with DatabaseNote constructed from given row
    // returns an Iterable
    return results.map((note) => DatabaseNote.fromRow(note));
  }

  Future<DatabaseNote> updateNote({
    required int noteId,
    required String text,
  }) async {
    await _ensureDbOpen();
    final db = _getDB();
    // just to ensure note with given id exists
    await getNote(noteId: noteId);

    final updatesCount = await db.update(
      noteTable,
      {
        textCol: text,
        isSyncedCol: 0,
      },
      where: 'id = ?',
      whereArgs: [noteId],
    );

    if (updatesCount != 1) {
      throw CouldNotUpdateNote();
    }

    // return the updated note
    // updating cache handled by getNote()
    return getNote(noteId: noteId);
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idCol] as int,
        email = map[emailCol] as String;

  // overload methods
  @override
  String toString() => 'User, id = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSynced;

  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSynced,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idCol] as int,
        userId = map[userIdCol] as int,
        text = map[textCol] as String,
        isSynced = (map[isSyncedCol] as int) == 1 ? true : false;

  // overload methods
  @override
  String toString() => 'User, id = $id, userId = $userId, isSynced = $isSynced, text = $text';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const userTable = 'user';
const noteTable = 'note';
const idCol = 'id';
const emailCol = 'email';
const userIdCol = 'user_id';
const textCol = 'text';
const isSyncedCol = 'is_synced';
const createUserTable = '''
CREATE TABLE IF NOT EXISTS "user" (
  "id"	INTEGER NOT NULL,
  "email"	TEXT NOT NULL UNIQUE,
  PRIMARY KEY("id" AUTOINCREMENT)
);
''';
const createNoteTable = '''
CREATE TABLE IF NOT EXISTS "note" (
  "id"	INTEGER NOT NULL,
  "user_id"	INTEGER NOT NULL,
  "text"	TEXT,
  "is_synced"	INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY("user_id") REFERENCES "user"("id"),
  PRIMARY KEY("id" AUTOINCREMENT)
);
''';
