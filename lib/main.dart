import 'package:flutter/material.dart';
import 'package:gdgbnsflutterbootcamp/note_item.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> _notes = [];
  List<String> _dates = [];
  String _theme = 'light';
  TextEditingController _controller = TextEditingController();

  _getTheme()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _theme = prefs.getString('theme')??'light';
    });
  }

  _setTheme()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('theme', _theme);
  }

  _getData()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _notes = pref.getStringList('TODO')??[];
      _dates = pref.getStringList('dates')??[];
    });
  }

  _saveData()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setStringList('TODO', _notes);
    pref.setStringList('dates', _dates);
  }

  @override
  void initState() {
    _getData();
    _getTheme();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _theme == 'light'?ThemeData.light():ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter BootCamp'),
          leading: IconButton(
            icon: Icon(_theme == 'light'? Icons.wb_sunny:Icons.lightbulb_outline),
            onPressed: _themeChange,
          ),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: _notes.isEmpty?
                  Center(child: Text('There is no notes to view'))
              :GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemBuilder: (BuildContext context, int idx) {
                  // 0 1
                  return InkWell(
                    onLongPress: () => _deleteNote(idx, context),
                    child: NoteItem(note: _notes[idx], date: _dates[idx]),
                  );
                },
                itemCount: _notes.length,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onSubmitted: (_) => _addNote(),
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Enter a note ...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)
                  ),
                ),
              ),
            ),
            RaisedButton(
              onPressed: _addNote,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              child: Text('Add note'),
            )
          ],
        ),
      ),
    );
  }

  _check(BuildContext context) async {
    return await showDialog(
        context: context,
        child: AlertDialog(
          content: Text('Are you sure?'),
          actions: <Widget>[
            RaisedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text('Yes'),
            ),
            RaisedButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('No'),
            ),
          ],
        ));
  }

  _addNote(){
    if (_controller.text.isNotEmpty) {
      setState(() {
        _notes.add(_controller.text);
        _dates.add(DateFormat('MMM dd kk:mm').format(DateTime.now()));
        _controller.clear();
        _saveData();
      });

      print(_notes.toString());
    }
  }
  
  _deleteNote(int idx, BuildContext context)async{
    if (await _check(context) == true) {
    setState(() {
    _notes.removeAt(idx);
    _dates.removeAt(idx);
    _saveData();
    });
    }
  }

  _themeChange(){
    setState(() {
      if(_theme == 'light'){
        _theme = 'dark';
      }else{
        _theme = 'light';
      }
      _setTheme();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}