import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpx/gpx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';

class GPXService {
  /// Converts a list of LatLng points to a GPX file
  static Future<File> createGpxFromPoints(List<LatLng> points, String routeId) async {
    // Create a GPX object
    final gpx = Gpx();

    // Create a track with one segment containing all the points
    final track = Trk(name: 'Route $routeId');
    final segment = Trkseg();

    // Add each point to the segment
    for (var point in points) {
      final trkpt = Wpt(
        lat: point.latitude,
        lon: point.longitude,
        ele: 0.0, // Elevation (optional)
        time: DateTime.now(), // Timestamp (you might want to adjust this for realistic simulation)
      );
      segment.trkpts.add(trkpt);
    }

    track.trksegs.add(segment);
    gpx.trks.add(track);

    // Generate the GPX XML
    final gpxString = GpxWriter().asString(gpx, pretty: true);

    // Save to a file
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/route_$routeId.gpx');
    await file.writeAsString(gpxString);

    return file;
  }

  /// Loads a GPX file and returns a list of LatLng points
  static Future<List<LatLng>> getPointsFromGpx(String gpxFilePath) async {
    final file = File(gpxFilePath);
    if (!await file.exists()) {
      throw Exception('GPX file not found: $gpxFilePath');
    }

    final gpxString = await file.readAsString();
    final gpx = GpxReader().fromString(gpxString);

    final points = <LatLng>[];

    // Extract points from all tracks and segments
    for (final track in gpx.trks) {
      for (final segment in track.trksegs) {
        for (final point in segment.trkpts) {
          points.add(LatLng(point.lat ?? 0, point.lon ?? 0));
        }
      }
    }

    return points;
  }

  /// Simulates movement along the route by returning the position at the given percentage of progress
  static LatLng getPositionAtProgress(List<LatLng> routePoints, double progress) {
    if (routePoints.isEmpty) {
      return const LatLng(0, 0);
    }

    if (progress <= 0) {
      return routePoints.first;
    }

    if (progress >= 1) {
      return routePoints.last;
    }

    // Calculate the index of the current point
    final pointCount = routePoints.length;
    final targetIndex = (progress * (pointCount - 1)).floor();
    final nextIndex = targetIndex + 1 < pointCount ? targetIndex + 1 : targetIndex;

    // Calculate the progress between the two points
    final segmentProgress = (progress * (pointCount - 1)) - targetIndex;

    // Interpolate between the two points
    final currentPoint = routePoints[targetIndex];
    final nextPoint = routePoints[nextIndex];

    return LatLng(
      currentPoint.latitude + (nextPoint.latitude - currentPoint.latitude) * segmentProgress,
      currentPoint.longitude + (nextPoint.longitude - currentPoint.longitude) * segmentProgress,
    );
  }
}
