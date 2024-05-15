import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

class EmojiSet {
  void showEmojiPicker(
      BuildContext context, TextEditingController textController) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return EmojiPicker(
          onEmojiSelected: (category, emoji) {
            if (emoji != null) {
              textController.text = textController.text + emoji.emoji;
            }
          },
        );
      },
    );
  }
}
