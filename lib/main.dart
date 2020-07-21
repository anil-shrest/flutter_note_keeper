import 'package:flutter/material.dart';
import 'package:notesapp/screens/note_list.dart';
import 'package:notesapp/screens/note_detail.dart';

void main() => runApp(MaterialApp(
  home: MyApp(),
));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal
      ),
      home: NoteList(),
    );
  }
}
