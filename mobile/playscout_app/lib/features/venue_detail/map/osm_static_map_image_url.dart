/// Map preview image from coordinates only (no address labels in URL).
String osmStaticMapImageUrl({
  required double latitude,
  required double longitude,
  int width = 780,
  int height = 192,
  int zoom = 15,
}) {
  final w = width.clamp(100, 1024);
  final h = height.clamp(80, 1024);
  final z = zoom.clamp(1, 18);
  return 'https://staticmap.openstreetmap.de/staticmap.php?center=$latitude,$longitude&zoom=$z&size=${w}x$h&maptype=mapnik';
}
