import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudNote {
  final String docId;
  final String userId;
  final String heading;
  final String text;

  const CloudNote({
    required this.docId,
    required this.userId,
    required this.heading,
    required this.text,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> doc)
      : docId = doc.id,
        userId = doc.data()[userIdFieldName] as String,
        heading = doc.data()[headingFieldName] as String,
        text = doc.data()[textFieldName] as String;
}
