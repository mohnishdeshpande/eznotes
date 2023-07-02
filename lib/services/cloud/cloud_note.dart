import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudNote {
  final String docId;
  final String userId;
  final String text;

  const CloudNote({
    required this.docId,
    required this.userId,
    required this.text,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : docId = snapshot.id,
        userId = snapshot.data()[userIdFieldName],
        text = snapshot.data()[textFieldName] as String;
}
