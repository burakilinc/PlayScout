class CreateSuggestionResult {
  const CreateSuggestionResult({
    required this.suggestionId,
    required this.name,
    required this.category,
    required this.moderationStatusKey,
    required this.confirmationTitle,
    required this.confirmationMessage,
    required this.createdAtUtc,
  });

  final String suggestionId;
  final String name;
  final int category;
  final String moderationStatusKey;
  final String confirmationTitle;
  final String confirmationMessage;
  final DateTime? createdAtUtc;

  factory CreateSuggestionResult.fromJson(Map<String, dynamic> j) {
    DateTime? at;
    final raw = j['createdAtUtc'] ?? j['CreatedAtUtc'];
    if (raw is String) {
      at = DateTime.tryParse(raw);
    }
    return CreateSuggestionResult(
      suggestionId: '${j['suggestionId'] ?? j['SuggestionId'] ?? ''}',
      name: '${j['name'] ?? j['Name'] ?? ''}',
      category: (j['category'] ?? j['Category'] as num?)?.toInt() ?? 0,
      moderationStatusKey: '${j['moderationStatusKey'] ?? j['ModerationStatusKey'] ?? ''}',
      confirmationTitle: '${j['confirmationTitle'] ?? j['ConfirmationTitle'] ?? ''}',
      confirmationMessage: '${j['confirmationMessage'] ?? j['ConfirmationMessage'] ?? ''}',
      createdAtUtc: at,
    );
  }
}
