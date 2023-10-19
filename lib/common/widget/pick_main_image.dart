import 'package:extended_image/extended_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class PickMainImage extends StatelessWidget {
  const PickMainImage({super.key, required this.controller});

  final PickMainImageController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.imageFile,
      builder: (BuildContext context, PlatformFile? value, Widget? child) {
        if (value == null) return buildPickPlaceholder();

        return ExtendedImage.memory(
          value.bytes!,
          fit: BoxFit.contain,
          mode: ExtendedImageMode.editor,
          extendedImageEditorKey: controller.imageEditKey,
          initEditorConfigHandler: (ExtendedImageState? state) {
            return EditorConfig(
              maxScale: 8.0,
              cropRectPadding: const EdgeInsets.all(0.0),
              hitTestSize: 50.0,
              cropAspectRatio: 1.0,
            );
          },
        );
      },
    );
  }

  Widget buildPickPlaceholder() {
    return GestureDetector(
      onTap: controller.pickImage,
      child: Container(
        height: 100,
        width: 100,
        margin: const EdgeInsets.all(4).copyWith(right: 16),
        decoration: BoxDecoration(
          border: Border.all(width: .5, color: Colors.black12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.add, size: 30, color: Colors.grey),
      ),
    );
  }
}

class PickMainImageController {
  final ValueNotifier<PlatformFile?> imageFile = ValueNotifier(null);
  final GlobalKey<ExtendedImageEditorState> imageEditKey = GlobalKey<ExtendedImageEditorState>();

  Rect? get cropRect => imageEditKey.currentState?.getCropRect();

  void pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    imageFile.value = result?.files.firstOrNull;
  }
}