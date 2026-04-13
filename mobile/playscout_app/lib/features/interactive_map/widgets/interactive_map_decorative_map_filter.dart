/// ~20% luminance blend toward grayscale (Stitch `grayscale-[0.2]`), keeps illustrated map feel.
abstract final class InteractiveMapDecorativeMapFilter {
  static const double _w = 0.22;
  static const double _lr = 0.2126;
  static const double _lg = 0.7152;
  static const double _lb = 0.0722;

  /// 4×5 color matrix for [ColorFilter.matrix].
  static const List<double> partialGrayscaleMatrix = <double>[
    (1 - _w) + _w * _lr, _w * _lg, _w * _lb, 0, 0,
    _w * _lr, (1 - _w) + _w * _lg, _w * _lb, 0, 0,
    _w * _lr, _w * _lg, (1 - _w) + _w * _lb, 0, 0,
    0, 0, 0, 1, 0,
  ];
}
