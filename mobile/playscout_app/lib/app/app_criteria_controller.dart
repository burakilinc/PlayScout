import 'package:flutter/foundation.dart';

import '../features/filter_options/models/venue_nearby_criteria.dart';

/// Holds [VenueNearbyCriteria] shared across Home, Map, Filter return, and Search.
class AppCriteriaController extends ChangeNotifier {
  VenueNearbyCriteria _criteria = VenueNearbyCriteria.initial();

  VenueNearbyCriteria get criteria => _criteria;

  void setCriteria(VenueNearbyCriteria value) {
    _criteria = value;
    notifyListeners();
  }

  void resetToInitial() {
    _criteria = VenueNearbyCriteria.initial();
    notifyListeners();
  }
}
