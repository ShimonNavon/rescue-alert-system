import 'package:flutter/material.dart';
import 'package:rescue_app/models/message.dart';

class MessageText extends StatefulWidget {
  final Message message;

  const MessageText({
    required this.message,
    super.key,
  });

  @override
  State<MessageText> createState() => _MessageTextState();
}

class _MessageTextState extends State<MessageText> {
  static const int _collapsedMaxLines = 2;
  static const int _longTextThreshold = 120;

  bool _isExpanded = false;

  bool get _isLongText {
    return widget.message.text.length > _longTextThreshold ||
        widget.message.text.contains('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: _isLongText
            ? () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              }
            : null,
        title: Text(widget.message.title),
        subtitle: Text(
          widget.message.text,
          maxLines: _isLongText && !_isExpanded ? _collapsedMaxLines : null,
          overflow: _isLongText && !_isExpanded
              ? TextOverflow.ellipsis
              : TextOverflow.visible,
        ),
        trailing: _isLongText
            ? Icon(_isExpanded ? Icons.expand_less : Icons.expand_more)
            : null,
      ),
    );
  }
}
