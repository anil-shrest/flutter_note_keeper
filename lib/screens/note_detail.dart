import 'package:flutter/material.dart';
import 'dart:async';
import 'package:notesapp/utils/db_helper.dart';
import 'package:notesapp/models/note.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  //constructor creation to access data of note list
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  _NoteDetailState createState() => _NoteDetailState(this.note, this.appBarTitle);
}

class _NoteDetailState extends State<NoteDetail> {
  //variables
  String appBarTitle;
  Note note;
  _NoteDetailState(this.note, this.appBarTitle);

  static var _priorities = ['High', 'Low'];

  DatabaseHelper helper =DatabaseHelper();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //variables declaration
    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(
        onWillPop: () {
          //to control the things when user press back button
          lastScreen();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                //to control the things when user press back button
                lastScreen();
              },
            ),
          ),
          body: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(
              children: <Widget>[
                //first element
                ListTile(
                  title: DropdownButton(
                    items: _priorities.map((String dropDownItems) {
                      return DropdownMenuItem<String>(
                        value: dropDownItems,
                        child: Text(dropDownItems),
                      );
                    }).toList(),
//                style: textStyle,
                    value: getPriorityAsString(note.priority),
                    onChanged: (valueSelected) {
                      setState(() {
                        debugPrint('User selected $valueSelected');
                        updatePriorityAsInt(valueSelected);
                      });
                    },
                  ),
                ),

                //Second elements
                Padding(
                  padding: const EdgeInsets.only(top: 15.0, bottom: 5.0),
                  child: TextField(
                    controller: titleController,
//                style: textStyle,
                    onChanged: (value) {
                      debugPrint('Title text field changed!');
                      updateTitle();
                    },
                    decoration: InputDecoration(
                      labelText: 'Title',
//                  labelStyle: textStyle,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                    ),
                  ),
                ),

                //Third element
                Padding(
                  padding: const EdgeInsets.only(top: 15.0, bottom: 5.0),
                  child: TextField(
                      controller: descriptionController,
//                  style: textStyle,
                      onChanged: (value) {
                        debugPrint('Description text field changed!');
                        updateDescription();
                      },
                      decoration: InputDecoration(
                        labelText: 'Description',
//                    labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                      )),
                ),

                //Fourth element
                Padding(
                  padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
//                      color: Theme.of(context).primaryColorDark,
//                      textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Save',
                            textScaleFactor: 1.2,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint('Save button clicked!');
                              _save();
                            });
                          },
                          highlightColor: Colors.teal[200],
                        ),
                      ),
                      SizedBox(height: 80.0),
                      Container(width: 10.0),
                      Expanded(
                        child: RaisedButton(
//                      color: Theme.of(context).primaryColorDark,
//                      textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Delete',
                            textScaleFactor: 1.2,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint('Delete button clicked!');
                              _delete();
                            });
                          },
                          highlightColor: Colors.teal[200],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  //to go to last screen
  void lastScreen() {
    Navigator.pop(context, true);
  }

  //convert string priority in the form of integer before saving it to database
  void updatePriorityAsInt(String value){
    switch (value){
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  //convert int priority to string priority and display in dropdown
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; //high
        break;
      case 2:
        priority = _priorities[1]; //low
        break;
    }
    return priority;
  }

  //update the title of note object
  void updateTitle(){
    note.title = titleController.text;
  }

  //update the description of note object
  void updateDescription(){
    note.description = descriptionController.text;
  }

  //save data into database
  void _save() async{

    lastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());

    int result;
    if(note.id != null){
      result = await helper.updateNote(note);
    }else{
      result = await helper.insertNote(note);
    }

    if(result != 0){
      _showAlertDialog('Status', 'Note Saved Successfully');
    }else{
      _showAlertDialog('Status', 'Sorry something went wrong. Try Again!');
    }
  }

  //delete method
  void _delete() async{

    lastScreen();

    //1st case if the user tries to delete the
    // new note which has not yet been added to the db
    if (note.id == null){
      _showAlertDialog('status', 'No data found');
      return;
    }

    //2nd case when user tries to delete existing note
    int result = await helper.deleteNote(note.id);
    if(result != 0){
      _showAlertDialog('status', 'Note Deleted');
    }else{
      _showAlertDialog('status', 'Unable to delete!');
    }
  }

  void _showAlertDialog(String title, String message){
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );

    showDialog(
      context: context,
      builder: (_) => alertDialog
    );
  }
}
