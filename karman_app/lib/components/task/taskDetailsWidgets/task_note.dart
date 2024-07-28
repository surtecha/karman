import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class TaskNote extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;

  const TaskNote({
    Key? key,
    required this.controller,
    this.hintText = 'Add a note...',
  }) : super(key: key);

  @override
  _TaskNoteState createState() => _TaskNoteState();
}

class _TaskNoteState extends State<TaskNote> {
  int _noteLines = 1;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateNoteLines);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateNoteLines);
    super.dispose();
  }

  void _updateNoteLines() {
    final newLines = '\n'.allMatches(widget.controller.text).length + 1;
    if (newLines != _noteLines) {
      setState(() {
        _noteLines = newLines;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.tertiarySystemBackground.darkColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Localizations(
        locale: const Locale('en', 'US'),
        delegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        child: Material(
          color: Colors.transparent,
          child: TextField(
            controller: widget.controller,
            style: TextStyle(color: Colors.white),
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
            ),
          ),
        ),
      ),
    );
  }
}
