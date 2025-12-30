import 'package:flutter/foundation.dart';

/// Filter parameters for image processing
class FilterState {
  final double contrast;
  final double brightness;
  final double saturate;
  final double sepia;
  final double hueRotate;
  final double highlights;
  final double whites;
  final double shadows;
  final double blacks;
  final double structure;
  final double vignette;

  const FilterState({
    this.contrast = 1.0,
    this.brightness = 1.0,
    this.saturate = 1.0,
    this.sepia = 0.0,
    this.hueRotate = 0.0,
    this.highlights = 0.0,
    this.whites = 0.0,
    this.shadows = 0.0,
    this.blacks = 0.0,
    this.structure = 0.0,
    this.vignette = 0.0,
  });

  FilterState copyWith({
    double? contrast,
    double? brightness,
    double? saturate,
    double? sepia,
    double? hueRotate,
    double? highlights,
    double? whites,
    double? shadows,
    double? blacks,
    double? structure,
    double? vignette,
  }) {
    return FilterState(
      contrast: contrast ?? this.contrast,
      brightness: brightness ?? this.brightness,
      saturate: saturate ?? this.saturate,
      sepia: sepia ?? this.sepia,
      hueRotate: hueRotate ?? this.hueRotate,
      highlights: highlights ?? this.highlights,
      whites: whites ?? this.whites,
      shadows: shadows ?? this.shadows,
      blacks: blacks ?? this.blacks,
      structure: structure ?? this.structure,
      vignette: vignette ?? this.vignette,
    );
  }
}

/// Enum for available panels
enum EditorPanel { enhance, color, tone, structure, vignette }

/// Shared state for the Photo Editor
class PhotoEditorState extends ChangeNotifier {
  EditorPanel _activePanel = EditorPanel.vignette;
  FilterState _filters = const FilterState();
  String? _indicatorText;

  // Getters
  EditorPanel get activePanel => _activePanel;
  FilterState get filters => _filters;
  String? get indicatorText => _indicatorText;

  // Panel switching
  void setActivePanel(EditorPanel panel) {
    if (_activePanel != panel) {
      _activePanel = panel;
      notifyListeners();
    }
  }

  // Filter updates
  void updateFilters(FilterState newFilters) {
    _filters = newFilters;
    notifyListeners();
  }

  void updateContrast(double value) {
    _filters = _filters.copyWith(contrast: value.clamp(0.5, 2.0));
    notifyListeners();
  }

  void updateBrightness(double value) {
    _filters = _filters.copyWith(brightness: value.clamp(0.5, 2.0));
    notifyListeners();
  }

  void updateSaturate(double value) {
    _filters = _filters.copyWith(saturate: value.clamp(0.0, 2.0));
    notifyListeners();
  }

  void updateSepia(double value) {
    _filters = _filters.copyWith(sepia: value.clamp(0.0, 1.0));
    notifyListeners();
  }

  void updateHueRotate(double value) {
    _filters = _filters.copyWith(hueRotate: value);
    notifyListeners();
  }

  void updateHighlights(double value) {
    _filters = _filters.copyWith(highlights: value.clamp(-1.0, 1.0));
    notifyListeners();
  }

  void updateWhites(double value) {
    _filters = _filters.copyWith(whites: value.clamp(-1.0, 1.0));
    notifyListeners();
  }

  void updateShadows(double value) {
    _filters = _filters.copyWith(shadows: value.clamp(-1.0, 1.0));
    notifyListeners();
  }

  void updateBlacks(double value) {
    _filters = _filters.copyWith(blacks: value.clamp(-1.0, 1.0));
    notifyListeners();
  }

  void updateStructure(double value) {
    _filters = _filters.copyWith(structure: value.clamp(-50.0, 50.0));
    notifyListeners();
  }

  void updateVignette(double value) {
    _filters = _filters.copyWith(vignette: value.clamp(-1.0, 1.0));
    notifyListeners();
  }

  // Value indicator
  void showIndicator(String text) {
    _indicatorText = text;
    notifyListeners();
  }

  void hideIndicator() {
    _indicatorText = null;
    notifyListeners();
  }

  // Reset
  void resetAll() {
    _filters = const FilterState();
    showIndicator('Reset All');
    notifyListeners();
  }
}
