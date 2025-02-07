import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'custom_dialog_template.dart';

class InsertImageDialog extends StatefulWidget {
  @override
  _InsertImageDialogState createState() => _InsertImageDialogState();
}

class _InsertImageDialogState extends State<InsertImageDialog> {
  TextEditingController link = TextEditingController();

  TextEditingController alt = TextEditingController();
  bool picked = false;

  @override
  Widget build(BuildContext context) {
    return CustomDialogTemplate(
      body: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Image link'),
            ElevatedButton(
              onPressed: () => getImage(),
              child: Text('...'),
            ),
          ],
        ),
        TextField(
          controller: link,
          decoration: InputDecoration(
            hintText: '',
          ),
        ),
        SizedBox(height: 20.0),
        Text('Alt text (optional)'),
        TextField(
          controller: alt,
          decoration: InputDecoration(
            hintText: '',
          ),
        ),
      ],
      onDone: () => Navigator.pop(context, [link.text, alt.text, picked]),
      onCancel: () => Navigator.pop(context),
    );
  }

  Future getImage() async {
    final picker = ImagePicker();
    var image = await picker.getImage(
      source: ImageSource.gallery,
      maxWidth: 800.0,
      maxHeight: 600.0,
    );

    if (image != null) {
      link.text = image.path;
      picked = true;
    }
  }
}
