import 'package:flutter/material.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart' as types;

import '../util.dart';
import 'inherited_chat_theme.dart';
import 'inherited_l10n.dart';
import 'inherited_user.dart';

/// A class that represents file message widget
class FileMessage extends StatelessWidget {
  /// Creates a file message widget based on a [types.FileMessage]
  const FileMessage({
    Key? key,
    @required this.message,
    this.onPressed,
  }) : super(key: key);

  /// [types.FileMessage]
  final types.FileMessage? message;

  /// Called when user taps on a file
  final void Function(types.FileMessage)? onPressed;

  @override
  Widget build(BuildContext context) {
    final _user = InheritedUser.of(context)!.user;
    final _color = _user!.id == message!.author.id
        ? InheritedChatTheme.of(context)!.theme!.sentMessageDocumentIconColor
        : InheritedChatTheme.of(context)!
            .theme!
            .receivedMessageDocumentIconColor;

    return Semantics(
      label: InheritedL10n.of(context)!.l10n!.fileButtonAccessibilityLabel,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 24, 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: _color!.withOpacity(0.2),
                borderRadius: BorderRadius.circular(21),
              ),
              height: 42,
              width: 42,
              child: /*InheritedChatTheme.of(context)!.theme!.documentIcon ??*/ Image
                  .asset(
                'assets/icon-document.png',
                color: _color,
                package: 'ttp_chat',
              ),
            ),
            Flexible(
              child: Container(
                margin: const EdgeInsets.only(
                  left: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message!.name,
                      style: _user.id == message!.author.id
                          ? InheritedChatTheme.of(context)!
                              .theme!
                              .sentMessageBodyTextStyle
                          : InheritedChatTheme.of(context)!
                              .theme!
                              .receivedMessageBodyTextStyle,
                      textWidthBasis: TextWidthBasis.longestLine,
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        top: 4,
                      ),
                      child: Text(formatBytes(message!.size),
                          style: _user.id == message!.author.id
                              ? InheritedChatTheme.of(context)!
                                  .theme!
                                  .sentMessageCaptionTextStyle
                              : InheritedChatTheme.of(context)!
                                  .theme!
                                  .receivedMessageCaptionTextStyle),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
