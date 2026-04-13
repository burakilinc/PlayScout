/// Public web URL pattern for sharing a venue (marketing site / universal link target).
String playScoutVenueShareUrl(String venueId) {
  final enc = Uri.encodeComponent(venueId.trim());
  return 'https://playscout.app/venue/$enc';
}
