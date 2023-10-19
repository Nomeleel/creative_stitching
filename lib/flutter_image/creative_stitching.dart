import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/rendering.dart';

typedef DecodeImageProvider<T> = Future<ui.Image> Function(T image);

Future<List<ui.Image>> creativeStitchingByPlatformFile(
  PlatformFile mainImage,
  List<PlatformFile> multipleFileList, {
  Rect? mainImageCropRect,
  int rowCount = 3,
  int colCount = 3,
}) async {
  Future<ui.Image> decodeImageProvider(PlatformFile platformFile) async => decodeImageFromList(platformFile.bytes!);

  return _creativeStitching<PlatformFile>(
    decodeImageProvider,
    mainImage,
    multipleFileList,
    mainImageCropRect,
    rowCount,
    colCount,
  );
}

Future<List<ui.Image>> _creativeStitching<T>(
  DecodeImageProvider<T> decodeImageProvider,
  T mainImageFile,
  List<T> multipleImageList,
  Rect? mainImageCropRect,
  int rowCount,
  int colCount,
) async {
  List<ui.Image> imageList = <ui.Image>[];

  ui.Image mainImage = await decodeImageProvider(mainImageFile);
  List<Rect> rectList =
      _getAverageSplitRectList(mainImageCropRect ?? _getDefaultCropRect(mainImage), rowCount, colCount);
  final paint = Paint()..isAntiAlias = true;

  Future<ui.Image> getStitchingImage(int cropCellIndex, int finalImageIndex, bool isRepeat) async {
    ui.Image topImage = await decodeImageProvider(multipleImageList[finalImageIndex]);
    ui.Image bottomImage = isRepeat ? topImage : await decodeImageProvider(multipleImageList[finalImageIndex + 1]);

    var pictureRecorder = ui.PictureRecorder();
    var canvas = Canvas(pictureRecorder);

    int width = math.max(topImage.width, bottomImage.width);
    int resetTopHeight = (width / topImage.width * topImage.height).toInt();
    int resetBottomHeight = (width / bottomImage.width * bottomImage.height).toInt();
    int resetHeight = math.max(resetTopHeight, resetBottomHeight);
    int height = resetHeight * 2 + width;

    canvas.drawImageRect(
      topImage,
      Rect.fromLTWH(0, 0, topImage.width.toDouble(), topImage.height.toDouble()),
      Rect.fromLTWH(0, 0, width.toDouble(), resetTopHeight.toDouble()),
      paint,
    );
    canvas.drawImageRect(
      mainImage,
      rectList[cropCellIndex],
      Rect.fromLTWH(0, resetHeight.toDouble(), width.toDouble(), width.toDouble()),
      paint,
    );
    canvas.drawImageRect(
      bottomImage,
      Rect.fromLTWH(0, 0, bottomImage.width.toDouble(), bottomImage.height.toDouble()),
      Rect.fromLTWH(0, (height - resetBottomHeight).toDouble(), width.toDouble(), resetBottomHeight.toDouble()),
      paint,
    );

    topImage.dispose();
    if (!isRepeat) {
      bottomImage.dispose();
    }

    return pictureRecorder.endRecording().toImage(width, height);
  }

  int maxCount = rowCount * colCount;
  int doubleImageCount = math.min(math.max(0, multipleImageList.length - maxCount), maxCount);
  int finalCount = math.min(multipleImageList.length - doubleImageCount, maxCount);

  for (int i = 0, index = 0; i < finalCount; i++) {
    bool isRepeat = doubleImageCount-- <= 0;
    imageList.add((await getStitchingImage(i, index, isRepeat)));
    index += isRepeat ? 1 : 2;
  }

  return imageList;
}

Rect _getDefaultCropRect(ui.Image image) {
  double min = math.min(image.height, image.width).toDouble();
  return Rect.fromLTWH((image.width - min) / 2, (image.height - min) / 2, min, min);
}

List<Rect> _getAverageSplitRectList(Rect rect, int rowCount, int colCount) {
  double length = rect.width / math.max(rowCount, colCount);
  List<Rect> rectList = <Rect>[];
  for (double i = 0; i < rowCount; i++) {
    for (double j = 0; j < colCount; j++) {
      rectList.add(Rect.fromLTWH(rect.left + j * length, rect.top + i * length, length, length));
    }
  }

  return rectList;
}
