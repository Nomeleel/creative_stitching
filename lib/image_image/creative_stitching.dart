import 'dart:async';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as image;

typedef DecodeImageProvider<T> = Future<image.Image> Function(T image);

Future<List<image.Image>> creativeStitchingByPlatformFile(
  PlatformFile mainImage,
  List<PlatformFile> multipleFileList, {
  Rect? mainImageCropRect,
  int rowCount = 3,
  int colCount = 3,
}) async {
  Future<image.Image> decodeImageProvider(PlatformFile platformFile) async => image.decodeImage(platformFile.bytes!)!;

  return _creativeStitching<PlatformFile>(
    decodeImageProvider,
    mainImage,
    multipleFileList,
    mainImageCropRect,
    rowCount,
    colCount,
  );
}

Future<List<image.Image>> _creativeStitching<T>(
  DecodeImageProvider<T> decodeImageProvider,
  T mainImageFile,
  List<T> multipleImageList,
  Rect? mainImageCropRect,
  int rowCount,
  int colCount,
) async {
  List<image.Image> imageList = <image.Image>[];

  image.Image mainImage = await decodeImageProvider(mainImageFile);
  List<Rect> rectList =
      _getAverageSplitRectList(mainImageCropRect ?? _getDefaultCropRect(mainImage), rowCount, colCount);

  Future<image.Image> getStitchingImage(int cropCellIndex, int finalImageIndex, bool isRepeat) async {
    image.Image topImage = await decodeImageProvider(multipleImageList[finalImageIndex]);
    image.Image bottomImage = isRepeat ? topImage : await decodeImageProvider(multipleImageList[finalImageIndex + 1]);

    int width = math.max(topImage.width, bottomImage.width);
    int resetTopHeight = (width / topImage.width * topImage.height).toInt();
    int resetBottomHeight = (width / bottomImage.width * bottomImage.height).toInt();
    int resetHeight = math.max(resetTopHeight, resetBottomHeight);
    int height = resetHeight * 2 + width;

    image.Image finalImage = image.Image(width: width, height: height, numChannels: 4);

    image.fill(finalImage, color: image.ColorUint8.rgba(255,255,255,255));

    image.compositeImage(
      finalImage,
      topImage,
      dstW: width,
      dstH: resetTopHeight,
    );

    final mainIndexRect = rectList[cropCellIndex];

    image.compositeImage(
      finalImage,
      mainImage,
      dstY: resetHeight,
      dstW: width,
      dstH: width,
      srcX: mainIndexRect.left.toInt(),
      srcY: mainIndexRect.top.toInt(),
      srcW: mainIndexRect.width.toInt(),
      srcH: mainIndexRect.height.toInt(),
    );

    image.compositeImage(
      finalImage,
      bottomImage,
      dstY: height - resetBottomHeight,
      dstW: width,
      dstH: resetBottomHeight,
    );

    return finalImage;
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

Rect _getDefaultCropRect(image.Image image) {
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
