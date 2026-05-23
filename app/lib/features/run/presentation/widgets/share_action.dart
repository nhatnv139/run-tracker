import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:runvie/data/models/activity.dart';
import 'package:runvie/shared/utils/distance_utils.dart';

/// Captures the widget under [boundaryKey] as a PNG and opens the share
/// sheet. The widget must be mounted (use `Offstage(offstage: true, ...)`
/// or `Transform.translate(offset: Offset(-10000, 0), ...)` to keep it
/// invisible but in the render tree).
class ShareCardRenderer {
  ShareCardRenderer._();

  static Future<bool> shareBoundary(
    GlobalKey boundaryKey,
    Activity activity,
  ) async {
    try {
      final RenderObject? obj = boundaryKey.currentContext?.findRenderObject();
      if (obj is! RenderRepaintBoundary) return false;
      // Allow one frame to ensure the boundary has painted.
      await Future<void>.delayed(const Duration(milliseconds: 16));
      final ui.Image image = await obj.toImage(pixelRatio: 1.0);
      final ByteData? bytes =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return false;
      final Directory dir = await getTemporaryDirectory();
      final String filePath =
          p.join(dir.path, 'runvie_share_${activity.id}.png');
      final File file = File(filePath);
      await file.writeAsBytes(bytes.buffer.asUint8List());

      await Share.shareXFiles(
        <XFile>[XFile(filePath, mimeType: 'image/png')],
        text:
            'Vừa hoàn thành ${DistanceUtils.formatKm(activity.distanceMeters)} km với RunVie!',
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
