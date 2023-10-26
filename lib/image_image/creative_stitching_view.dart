import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image;

import '../common/widget/pick_main_image.dart';
import 'creative_stitching.dart';

class CreativeStitchingView extends StatefulWidget {
  const CreativeStitchingView({super.key});

  @override
  State<CreativeStitchingView> createState() => _CreativeStitchingViewState();
}

class _CreativeStitchingViewState extends State<CreativeStitchingView> {
  final PickMainImageController mainImageController = PickMainImageController();
  final ValueNotifier<List<PlatformFile>> amazingImageListNotifier = ValueNotifier([]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PickMainImage(controller: mainImageController),
          ),
          ElevatedButton(
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.image,
                allowMultiple: true,
              );
              amazingImageListNotifier.value = sort(result?.files ?? []);
            },
            child: const Text('Pick'),
          ),
          ValueListenableBuilder(
            valueListenable: mainImageController.imageFile,
            builder: (BuildContext context, PlatformFile? value, Widget? child) {
              return ElevatedButton(
                onPressed: value == null ? null : go,
                child: const Text('Go'),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> go() async {
    final List<image.Image> result = await creativeStitchingByPlatformFile(
      mainImageController.imageFile.value!,
      amazingImageListNotifier.value,
      mainImageCropRect: mainImageController.cropRect,
    );
    final prefix = DateTime.now().toString();
    for (int i = 0; i < result.length; i++) {
      await FileSaver.instance.saveFile(
        name: '${prefix}_${i + 1}',
        ext: 'png',
        mimeType: MimeType.png,
        bytes: image.encodePng(result[i]),
      );
    }
  }

  List<PlatformFile> sort(List<PlatformFile> list) => list..sort((a, b) => a.name.compareTo(b.name));
}
