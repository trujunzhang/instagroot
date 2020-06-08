
import 'package:flutter/material.dart';
import 'package:ieatta/src/models/models.dart';

import '../avatar_widget.dart';

class AddCommentModal extends StatefulWidget {
  final User user;
  final ValueChanged<String> onPost;

  AddCommentModal({@required this.user, @required this.onPost});

  @override
  _AddCommentModalState createState() => _AddCommentModalState();
}

class _AddCommentModalState extends State<AddCommentModal> {
  final _textController = TextEditingController();
  bool _canPost = false;

  @override
  void initState() {
    _textController.addListener(() {
      setState(() => _canPost = _textController.text.isNotEmpty);
    });
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        AvatarWidget(user: widget.user),
        Expanded(
          child: TextField(
            controller: _textController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Add a comment...',
              border: InputBorder.none,
            ),
          ),
        ),
        FlatButton(
          child: Opacity(
            opacity: _canPost ? 1.0 : 0.4,
            child: Text('Post', style: TextStyle(color: Colors.blue)),
          ),
          onPressed:
          _canPost ? () => widget.onPost(_textController.text) : null,
        )
      ],
    );
  }
}


