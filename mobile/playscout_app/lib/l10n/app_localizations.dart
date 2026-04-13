import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'PlayScout'**
  String get appTitle;

  /// No description provided for @navDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get navDiscover;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get navEvents;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change app language without signing in'**
  String get languageSubtitle;

  /// No description provided for @useDeviceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Use device language'**
  String get useDeviceLanguage;

  /// No description provided for @notificationsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTooltip;

  /// No description provided for @welcomeTermsPrivacySoon.
  ///
  /// In en, this message translates to:
  /// **'Terms and privacy links coming soon.'**
  String get welcomeTermsPrivacySoon;

  /// No description provided for @welcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Find the perfect place for your child'**
  String get welcomeTagline;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @continueWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Continue with Email'**
  String get continueWithEmail;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE AS GUEST'**
  String get continueAsGuest;

  /// No description provided for @legalPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to PlayScout\'s '**
  String get legalPrefix;

  /// No description provided for @legalTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get legalTerms;

  /// No description provided for @legalAnd.
  ///
  /// In en, this message translates to:
  /// **' & '**
  String get legalAnd;

  /// No description provided for @legalPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalPrivacy;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @whereToToday.
  ///
  /// In en, this message translates to:
  /// **'Where to today?'**
  String get whereToToday;

  /// No description provided for @locationPickerSoon.
  ///
  /// In en, this message translates to:
  /// **'Location picker coming soon'**
  String get locationPickerSoon;

  /// No description provided for @notificationsSoon.
  ///
  /// In en, this message translates to:
  /// **'Notifications coming soon'**
  String get notificationsSoon;

  /// No description provided for @suggestPlaceCta.
  ///
  /// In en, this message translates to:
  /// **'Suggest a place'**
  String get suggestPlaceCta;

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'The Sanctuary'**
  String get mapTitle;

  /// No description provided for @mapEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No places nearby'**
  String get mapEmptyTitle;

  /// No description provided for @mapEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try widening filters or moving the map area.'**
  String get mapEmptySubtitle;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @nearbyPlaces.
  ///
  /// In en, this message translates to:
  /// **'Nearby places'**
  String get nearbyPlaces;

  /// No description provided for @noVenuesToShow.
  ///
  /// In en, this message translates to:
  /// **'No venues to show.'**
  String get noVenuesToShow;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get authWelcomeBack;

  /// No description provided for @authStepBack.
  ///
  /// In en, this message translates to:
  /// **'Step back into your child\'s world of discovery.'**
  String get authStepBack;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @loginToPlayScout.
  ///
  /// In en, this message translates to:
  /// **'Login to PlayScout'**
  String get loginToPlayScout;

  /// No description provided for @googleShort.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get googleShort;

  /// No description provided for @appleShort.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get appleShort;

  /// No description provided for @newToPlayScout.
  ///
  /// In en, this message translates to:
  /// **'New to PlayScout?'**
  String get newToPlayScout;

  /// No description provided for @joinUs.
  ///
  /// In en, this message translates to:
  /// **'Join Us'**
  String get joinUs;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'OR CONTINUE WITH'**
  String get orContinueWith;

  /// No description provided for @outdoorDiscovery.
  ///
  /// In en, this message translates to:
  /// **'OUTDOOR DISCOVERY'**
  String get outdoorDiscovery;

  /// No description provided for @joinPlayScout.
  ///
  /// In en, this message translates to:
  /// **'Join PlayScout'**
  String get joinPlayScout;

  /// No description provided for @createAccountLead.
  ///
  /// In en, this message translates to:
  /// **'Create an account to start exploring nature-friendly playgrounds and activities for your little explorers.'**
  String get createAccountLead;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @createMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Create My Account'**
  String get createMyAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// No description provided for @cookies.
  ///
  /// In en, this message translates to:
  /// **'Cookies'**
  String get cookies;

  /// No description provided for @copyrightLine.
  ///
  /// In en, this message translates to:
  /// **'© 2026 PlayScout. All Rights Reserved.'**
  String get copyrightLine;

  /// No description provided for @termsLinkSoon.
  ///
  /// In en, this message translates to:
  /// **'Terms link coming soon.'**
  String get termsLinkSoon;

  /// No description provided for @privacyLinkSoon.
  ///
  /// In en, this message translates to:
  /// **'Privacy link coming soon.'**
  String get privacyLinkSoon;

  /// No description provided for @acceptTermsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please accept the Terms of Service and Privacy Policy to continue.'**
  String get acceptTermsRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordRulesError.
  ///
  /// In en, this message translates to:
  /// **'Use 8-128 characters with at least one uppercase letter, one lowercase letter, and one number.'**
  String get passwordRulesError;

  /// No description provided for @iAgreeToThe.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get iAgreeToThe;

  /// No description provided for @andText.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get andText;

  /// No description provided for @dotText.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get dotText;

  /// No description provided for @forgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Lost your path?'**
  String get forgotTitle;

  /// No description provided for @forgotLead.
  ///
  /// In en, this message translates to:
  /// **'Enter the email associated with your PlayScout account and we\'ll send a breeze of fresh air to reset your password.'**
  String get forgotLead;

  /// No description provided for @parentEmail.
  ///
  /// In en, this message translates to:
  /// **'PARENT\'S EMAIL'**
  String get parentEmail;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @rememberedIt.
  ///
  /// In en, this message translates to:
  /// **'Remembered it?'**
  String get rememberedIt;

  /// No description provided for @goBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go back to login'**
  String get goBackToLogin;

  /// No description provided for @forgotResetInfo.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox and spam folder. The reset link is active for 24 hours to ensure your sanctuary remains secure.'**
  String get forgotResetInfo;

  /// No description provided for @guestPromptMaybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get guestPromptMaybeLater;

  /// No description provided for @guestTitleFavorites.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save favorites'**
  String get guestTitleFavorites;

  /// No description provided for @guestBodyFavorites.
  ///
  /// In en, this message translates to:
  /// **'Create a PlayScout account to save playgrounds you love and pick them up on any device.'**
  String get guestBodyFavorites;

  /// No description provided for @guestTitleWriteReview.
  ///
  /// In en, this message translates to:
  /// **'Sign in to write a review'**
  String get guestTitleWriteReview;

  /// No description provided for @guestBodyWriteReview.
  ///
  /// In en, this message translates to:
  /// **'Share what worked for your family - reviews help other parents choose the right spot with confidence.'**
  String get guestBodyWriteReview;

  /// No description provided for @guestTitleSuggestPlace.
  ///
  /// In en, this message translates to:
  /// **'Sign in to suggest a place'**
  String get guestTitleSuggestPlace;

  /// No description provided for @guestBodySuggestPlace.
  ///
  /// In en, this message translates to:
  /// **'Members can suggest new spots for our map. Each suggestion is reviewed before it goes live.'**
  String get guestBodySuggestPlace;

  /// No description provided for @guestTitleOpenFavorites.
  ///
  /// In en, this message translates to:
  /// **'Sign in to open Favorites'**
  String get guestTitleOpenFavorites;

  /// No description provided for @guestBodyOpenFavorites.
  ///
  /// In en, this message translates to:
  /// **'Your saved places and lists are available when you sign in with a full account.'**
  String get guestBodyOpenFavorites;

  /// No description provided for @guestTitleContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get guestTitleContinue;

  /// No description provided for @guestBodyContinuePath.
  ///
  /// In en, this message translates to:
  /// **'That area of PlayScout is for members. Sign in to pick up where you left off.'**
  String get guestBodyContinuePath;

  /// No description provided for @guestBodyDefault.
  ///
  /// In en, this message translates to:
  /// **'Join the PlayScout community to save favorites, write reviews, and help other families discover great places.'**
  String get guestBodyDefault;

  /// No description provided for @suggestPlaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggest a place'**
  String get suggestPlaceTitle;

  /// No description provided for @suggestKnowGreatSpot.
  ///
  /// In en, this message translates to:
  /// **'Know a great spot?'**
  String get suggestKnowGreatSpot;

  /// No description provided for @suggestEntryLead.
  ///
  /// In en, this message translates to:
  /// **'Tell us about playgrounds, cafes, or play spaces other families would love. Suggestions are reviewed before they appear anywhere in PlayScout.'**
  String get suggestEntryLead;

  /// No description provided for @startSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Start suggestion'**
  String get startSuggestion;

  /// No description provided for @fullMemberRequired.
  ///
  /// In en, this message translates to:
  /// **'Full member account required.'**
  String get fullMemberRequired;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @signInFullAccountSuggest.
  ///
  /// In en, this message translates to:
  /// **'Sign in with a full account to suggest a new place.'**
  String get signInFullAccountSuggest;

  /// No description provided for @placeName.
  ///
  /// In en, this message translates to:
  /// **'Place name'**
  String get placeName;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @locationHelp.
  ///
  /// In en, this message translates to:
  /// **'Either paste coordinates (both required) or describe the location (5+ characters).'**
  String get locationHelp;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @locationLabelHint.
  ///
  /// In en, this message translates to:
  /// **'Location label (area, address hint, landmark)'**
  String get locationLabelHint;

  /// No description provided for @whyFamiliesLoveItOptional.
  ///
  /// In en, this message translates to:
  /// **'Why families love it (optional)'**
  String get whyFamiliesLoveItOptional;

  /// No description provided for @ageRangeMonthsOptional.
  ///
  /// In en, this message translates to:
  /// **'Age range (months, optional)'**
  String get ageRangeMonthsOptional;

  /// No description provided for @minMonths.
  ///
  /// In en, this message translates to:
  /// **'Min months'**
  String get minMonths;

  /// No description provided for @maxMonths.
  ///
  /// In en, this message translates to:
  /// **'Max months'**
  String get maxMonths;

  /// No description provided for @playSupervisorOnSite.
  ///
  /// In en, this message translates to:
  /// **'Play supervisor on site'**
  String get playSupervisorOnSite;

  /// No description provided for @allowsSupervisedDropoff.
  ///
  /// In en, this message translates to:
  /// **'Allows supervised drop-off'**
  String get allowsSupervisedDropoff;

  /// No description provided for @optionalAmenities.
  ///
  /// In en, this message translates to:
  /// **'Optional amenities'**
  String get optionalAmenities;

  /// No description provided for @playSupervisorShort.
  ///
  /// In en, this message translates to:
  /// **'Play supervisor'**
  String get playSupervisorShort;

  /// No description provided for @dropoffAllowed.
  ///
  /// In en, this message translates to:
  /// **'Drop-off allowed'**
  String get dropoffAllowed;

  /// No description provided for @submitForReview.
  ///
  /// In en, this message translates to:
  /// **'Submit for review'**
  String get submitForReview;

  /// No description provided for @suggestModerationNote.
  ///
  /// In en, this message translates to:
  /// **'Your suggestion is queued for moderation and is not published to the map until approved.'**
  String get suggestModerationNote;

  /// No description provided for @suggestThanksTitle.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your suggestion'**
  String get suggestThanksTitle;

  /// No description provided for @suggestThanksBody.
  ///
  /// In en, this message translates to:
  /// **'Our team will review your submission before it can appear in PlayScout.'**
  String get suggestThanksBody;

  /// No description provided for @moderation.
  ///
  /// In en, this message translates to:
  /// **'Moderation'**
  String get moderation;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @notVisibleUntilReview.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" is not visible on venue lists until it passes review.'**
  String notVisibleUntilReview(String name);

  /// No description provided for @backToDiscover.
  ///
  /// In en, this message translates to:
  /// **'Back to Discover'**
  String get backToDiscover;

  /// No description provided for @suggestion.
  ///
  /// In en, this message translates to:
  /// **'Suggestion'**
  String get suggestion;

  /// No description provided for @suggestionReceived.
  ///
  /// In en, this message translates to:
  /// **'Thanks - your suggestion was received.'**
  String get suggestionReceived;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @favoritesOptimisticVenueName.
  ///
  /// In en, this message translates to:
  /// **'Saved venue'**
  String get favoritesOptimisticVenueName;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @savePlacesFamilyLoves.
  ///
  /// In en, this message translates to:
  /// **'Save the places your family loves'**
  String get savePlacesFamilyLoves;

  /// No description provided for @favoritesGuestLead.
  ///
  /// In en, this message translates to:
  /// **'Create a free account or sign in to keep a gentle list of playgrounds and events.'**
  String get favoritesGuestLead;

  /// No description provided for @browseAccountOptions.
  ///
  /// In en, this message translates to:
  /// **'Browse account options'**
  String get browseAccountOptions;

  /// No description provided for @tapHeartToSave.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on a playground to save it here.'**
  String get tapHeartToSave;

  /// No description provided for @couldNotRemoveFavorite.
  ///
  /// In en, this message translates to:
  /// **'Could not remove favorite.'**
  String get couldNotRemoveFavorite;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write a review'**
  String get writeReview;

  /// No description provided for @postReview.
  ///
  /// In en, this message translates to:
  /// **'Post review'**
  String get postReview;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset Filters'**
  String get resetFilters;

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List view'**
  String get listView;

  /// No description provided for @indoor.
  ///
  /// In en, this message translates to:
  /// **'Indoor'**
  String get indoor;

  /// No description provided for @outdoor.
  ///
  /// In en, this message translates to:
  /// **'Outdoor'**
  String get outdoor;

  /// No description provided for @nearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get nearby;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @thisWeekend.
  ///
  /// In en, this message translates to:
  /// **'This Weekend'**
  String get thisWeekend;

  /// No description provided for @retryCaps.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryCaps;

  /// No description provided for @toilet.
  ///
  /// In en, this message translates to:
  /// **'Toilet'**
  String get toilet;

  /// No description provided for @parking.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get parking;

  /// No description provided for @foodAndDrinks.
  ///
  /// In en, this message translates to:
  /// **'Food & Drinks'**
  String get foodAndDrinks;

  /// No description provided for @shade.
  ///
  /// In en, this message translates to:
  /// **'Shade'**
  String get shade;

  /// No description provided for @stroller.
  ///
  /// In en, this message translates to:
  /// **'Stroller'**
  String get stroller;

  /// No description provided for @toddlerSafe.
  ///
  /// In en, this message translates to:
  /// **'Toddler Safe'**
  String get toddlerSafe;

  /// No description provided for @parks.
  ///
  /// In en, this message translates to:
  /// **'Parks'**
  String get parks;

  /// No description provided for @cafes.
  ///
  /// In en, this message translates to:
  /// **'Cafes'**
  String get cafes;

  /// No description provided for @reviewPostedThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks - your review was posted.'**
  String get reviewPostedThanks;

  /// No description provided for @cleanliness.
  ///
  /// In en, this message translates to:
  /// **'Cleanliness'**
  String get cleanliness;

  /// No description provided for @safety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get safety;

  /// No description provided for @goodForSmallChildren.
  ///
  /// In en, this message translates to:
  /// **'Good for small children'**
  String get goodForSmallChildren;

  /// No description provided for @indoorPlay.
  ///
  /// In en, this message translates to:
  /// **'Indoor play'**
  String get indoorPlay;

  /// No description provided for @outdoorPlay.
  ///
  /// In en, this message translates to:
  /// **'Outdoor play'**
  String get outdoorPlay;

  /// No description provided for @mixedIndoorOutdoor.
  ///
  /// In en, this message translates to:
  /// **'Mixed indoor / outdoor'**
  String get mixedIndoorOutdoor;

  /// No description provided for @dropInCare.
  ///
  /// In en, this message translates to:
  /// **'Drop-in care'**
  String get dropInCare;

  /// No description provided for @familyCafeRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Family cafe or restaurant'**
  String get familyCafeRestaurant;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @fenced.
  ///
  /// In en, this message translates to:
  /// **'Fenced'**
  String get fenced;

  /// No description provided for @sand.
  ///
  /// In en, this message translates to:
  /// **'Sand'**
  String get sand;

  /// No description provided for @strollerFriendly.
  ///
  /// In en, this message translates to:
  /// **'Stroller-friendly'**
  String get strollerFriendly;

  /// No description provided for @restrooms.
  ///
  /// In en, this message translates to:
  /// **'Restrooms'**
  String get restrooms;

  /// No description provided for @foodNearby.
  ///
  /// In en, this message translates to:
  /// **'Food nearby'**
  String get foodNearby;

  /// No description provided for @playSupervisorAvailable.
  ///
  /// In en, this message translates to:
  /// **'Play Supervisor Available'**
  String get playSupervisorAvailable;

  /// No description provided for @trainedStaffWatchingZones.
  ///
  /// In en, this message translates to:
  /// **'Trained staff watching the zones'**
  String get trainedStaffWatchingZones;

  /// No description provided for @childDropoffAllowed.
  ///
  /// In en, this message translates to:
  /// **'Child Drop-off Allowed'**
  String get childDropoffAllowed;

  /// No description provided for @safeShortTermCareToddlers.
  ///
  /// In en, this message translates to:
  /// **'Safe short-term care for toddlers'**
  String get safeShortTermCareToddlers;

  /// No description provided for @designatedSecureZones.
  ///
  /// In en, this message translates to:
  /// **'Designated secure zones where you can leave your child for up to 2 hours.'**
  String get designatedSecureZones;

  /// No description provided for @artWorkshops.
  ///
  /// In en, this message translates to:
  /// **'Art Workshops'**
  String get artWorkshops;

  /// No description provided for @codingForKids.
  ///
  /// In en, this message translates to:
  /// **'Coding for Kids'**
  String get codingForKids;

  /// No description provided for @musicTheory.
  ///
  /// In en, this message translates to:
  /// **'Music Theory'**
  String get musicTheory;

  /// No description provided for @scienceLab.
  ///
  /// In en, this message translates to:
  /// **'Science Lab'**
  String get scienceLab;

  /// No description provided for @age0to5.
  ///
  /// In en, this message translates to:
  /// **'Age 0-5'**
  String get age0to5;

  /// No description provided for @age6to10.
  ///
  /// In en, this message translates to:
  /// **'Age 6-10'**
  String get age6to10;

  /// No description provided for @strollerParking.
  ///
  /// In en, this message translates to:
  /// **'Stroller Parking'**
  String get strollerParking;

  /// No description provided for @cafe.
  ///
  /// In en, this message translates to:
  /// **'Cafe'**
  String get cafe;

  /// No description provided for @deviceLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get deviceLanguageLabel;

  /// No description provided for @dashEmDash.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get dashEmDash;

  /// No description provided for @filterTrustSafetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Trust & Safety'**
  String get filterTrustSafetyTitle;

  /// No description provided for @filterTrustSupervisorLongSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Certified staff on-site to monitor children during play hours.'**
  String get filterTrustSupervisorLongSubtitle;

  /// No description provided for @filterAmenitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get filterAmenitiesTitle;

  /// No description provided for @filterEnvironmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get filterEnvironmentTitle;

  /// No description provided for @filterHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter Playgrounds'**
  String get filterHeaderTitle;

  /// No description provided for @filterReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get filterReset;

  /// No description provided for @filterShowPlaces.
  ///
  /// In en, this message translates to:
  /// **'Show Places'**
  String get filterShowPlaces;

  /// No description provided for @filterDistanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get filterDistanceTitle;

  /// No description provided for @filterDistanceHalfKm.
  ///
  /// In en, this message translates to:
  /// **'0.5 km'**
  String get filterDistanceHalfKm;

  /// No description provided for @filterDistanceTenKm.
  ///
  /// In en, this message translates to:
  /// **'10 km'**
  String get filterDistanceTenKm;

  /// No description provided for @filterAgeSuitabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Age Suitability'**
  String get filterAgeSuitabilityTitle;

  /// No description provided for @filterAge02.
  ///
  /// In en, this message translates to:
  /// **'0-2'**
  String get filterAge02;

  /// No description provided for @filterAge35.
  ///
  /// In en, this message translates to:
  /// **'3-5'**
  String get filterAge35;

  /// No description provided for @filterAge610.
  ///
  /// In en, this message translates to:
  /// **'6-10'**
  String get filterAge610;

  /// No description provided for @homeWeekendHeading.
  ///
  /// In en, this message translates to:
  /// **'This Weekend'**
  String get homeWeekendHeading;

  /// No description provided for @homeNearYouHeading.
  ///
  /// In en, this message translates to:
  /// **'Near You'**
  String get homeNearYouHeading;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search places'**
  String get homeSearchHint;

  /// No description provided for @homeCtaTitle.
  ///
  /// In en, this message translates to:
  /// **'Where should we go now?'**
  String get homeCtaTitle;

  /// No description provided for @homeCtaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get personalized recommendations for parks, cafes, and indoor play areas based on your mood.'**
  String get homeCtaSubtitle;

  /// No description provided for @homeCtaButton.
  ///
  /// In en, this message translates to:
  /// **'Get recommendations'**
  String get homeCtaButton;

  /// No description provided for @homeWeekendEmpty.
  ///
  /// In en, this message translates to:
  /// **'No events scheduled this weekend.'**
  String get homeWeekendEmpty;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No venues nearby'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try another category or widen your search later.'**
  String get homeEmptySubtitle;

  /// No description provided for @homeErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get homeErrorTitle;

  /// No description provided for @homeShowAllCategories.
  ///
  /// In en, this message translates to:
  /// **'Show all categories'**
  String get homeShowAllCategories;

  /// No description provided for @homeCategoryParks.
  ///
  /// In en, this message translates to:
  /// **'Parks'**
  String get homeCategoryParks;

  /// No description provided for @homeCategoryIndoor.
  ///
  /// In en, this message translates to:
  /// **'Indoor'**
  String get homeCategoryIndoor;

  /// No description provided for @homeCategoryEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get homeCategoryEvents;

  /// No description provided for @homeCategoryCafes.
  ///
  /// In en, this message translates to:
  /// **'Cafes'**
  String get homeCategoryCafes;

  /// No description provided for @homeCategorySoftPlay.
  ///
  /// In en, this message translates to:
  /// **'Soft Play'**
  String get homeCategorySoftPlay;

  /// No description provided for @reviewTranslatedFrom.
  ///
  /// In en, this message translates to:
  /// **'Translated from {language}'**
  String reviewTranslatedFrom(String language);

  /// No description provided for @reviewSeeOriginal.
  ///
  /// In en, this message translates to:
  /// **'See original'**
  String get reviewSeeOriginal;

  /// No description provided for @reviewShowTranslation.
  ///
  /// In en, this message translates to:
  /// **'Show translation'**
  String get reviewShowTranslation;

  /// No description provided for @venueParentReviews.
  ///
  /// In en, this message translates to:
  /// **'Parent Reviews'**
  String get venueParentReviews;

  /// No description provided for @venueViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get venueViewAll;

  /// No description provided for @venueNoReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet.'**
  String get venueNoReviewsYet;

  /// No description provided for @venueBeFirstToShare.
  ///
  /// In en, this message translates to:
  /// **'Be the first to share your experience.'**
  String get venueBeFirstToShare;

  /// No description provided for @venueNotFound.
  ///
  /// In en, this message translates to:
  /// **'Venue not found'**
  String get venueNotFound;

  /// No description provided for @errorSomethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorSomethingWrong;

  /// No description provided for @couldNotUpdateFavorite.
  ///
  /// In en, this message translates to:
  /// **'Could not update favorite. Try again.'**
  String get couldNotUpdateFavorite;

  /// No description provided for @shareComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Share coming soon'**
  String get shareComingSoon;

  /// No description provided for @venueWhatOffers.
  ///
  /// In en, this message translates to:
  /// **'What this place offers'**
  String get venueWhatOffers;

  /// No description provided for @getDirections.
  ///
  /// In en, this message translates to:
  /// **'Get Directions'**
  String get getDirections;

  /// No description provided for @mapSearchParksIndoorHint.
  ///
  /// In en, this message translates to:
  /// **'Search parks, indoor places...'**
  String get mapSearchParksIndoorHint;

  /// No description provided for @mapKmAway.
  ///
  /// In en, this message translates to:
  /// **'{distance} km away'**
  String mapKmAway(String distance);

  /// No description provided for @eventsWeekendFun.
  ///
  /// In en, this message translates to:
  /// **'Weekend Fun'**
  String get eventsWeekendFun;

  /// No description provided for @eventsSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get eventsSeeAll;

  /// No description provided for @eventsNoWeekendPicks.
  ///
  /// In en, this message translates to:
  /// **'No weekend picks in this list.'**
  String get eventsNoWeekendPicks;

  /// No description provided for @eventsLearningSkills.
  ///
  /// In en, this message translates to:
  /// **'Learning & Skills'**
  String get eventsLearningSkills;

  /// No description provided for @eventsSomethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get eventsSomethingWrong;

  /// No description provided for @eventsNoEventsWeekend.
  ///
  /// In en, this message translates to:
  /// **'No events this weekend.'**
  String get eventsNoEventsWeekend;

  /// No description provided for @eventsNoEventsFilters.
  ///
  /// In en, this message translates to:
  /// **'No events match your filters right now.'**
  String get eventsNoEventsFilters;

  /// No description provided for @eventsNoEventsMatchFilters.
  ///
  /// In en, this message translates to:
  /// **'No events match these filters.'**
  String get eventsNoEventsMatchFilters;

  /// No description provided for @eventsHappeningNearby.
  ///
  /// In en, this message translates to:
  /// **'Happening Nearby'**
  String get eventsHappeningNearby;

  /// No description provided for @eventsNoVenueLinked.
  ///
  /// In en, this message translates to:
  /// **'No venue-linked events yet.'**
  String get eventsNoVenueLinked;

  /// No description provided for @eventsFeaturedBadge.
  ///
  /// In en, this message translates to:
  /// **'FEATURED'**
  String get eventsFeaturedBadge;

  /// No description provided for @eventsGenericTitle.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get eventsGenericTitle;

  /// No description provided for @searchFindParkTitle.
  ///
  /// In en, this message translates to:
  /// **'Find a Park'**
  String get searchFindParkTitle;

  /// No description provided for @searchSomethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get searchSomethingWrong;

  /// No description provided for @searchNoVenuesMatch.
  ///
  /// In en, this message translates to:
  /// **'No venues match this search right now.\nTry another name, adjust the chips, or open filters to widen your criteria.'**
  String get searchNoVenuesMatch;

  /// No description provided for @searchPopularSearches.
  ///
  /// In en, this message translates to:
  /// **'Popular searches'**
  String get searchPopularSearches;

  /// No description provided for @searchSuggestedForYou.
  ///
  /// In en, this message translates to:
  /// **'Suggested for you'**
  String get searchSuggestedForYou;

  /// No description provided for @searchRecentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get searchRecentSearches;

  /// No description provided for @searchClearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get searchClearHistory;

  /// No description provided for @searchNoRecentYet.
  ///
  /// In en, this message translates to:
  /// **'No recent searches yet.'**
  String get searchNoRecentYet;

  /// No description provided for @searchHintPanel.
  ///
  /// In en, this message translates to:
  /// **'Try a place name or pick a category. Filters you set here stay in sync with Home and Map.'**
  String get searchHintPanel;

  /// No description provided for @searchNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get searchNoResultsTitle;

  /// No description provided for @searchNoResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Try clearing quick filters or widening your saved filters from the tune menu.'**
  String get searchNoResultsBody;

  /// No description provided for @popularPlayground.
  ///
  /// In en, this message translates to:
  /// **'Playground'**
  String get popularPlayground;

  /// No description provided for @popularParkWithCafe.
  ///
  /// In en, this message translates to:
  /// **'Park with cafe'**
  String get popularParkWithCafe;

  /// No description provided for @popularSoftPlay.
  ///
  /// In en, this message translates to:
  /// **'Soft play'**
  String get popularSoftPlay;

  /// No description provided for @popularWaterPlay.
  ///
  /// In en, this message translates to:
  /// **'Water play'**
  String get popularWaterPlay;

  /// No description provided for @authErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'That email or password does not match our records. Please try again.'**
  String get authErrorInvalidCredentials;

  /// No description provided for @authErrorGoogleNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in is not available on this server yet.'**
  String get authErrorGoogleNotConfigured;

  /// No description provided for @authErrorEmailLinkedGoogle.
  ///
  /// In en, this message translates to:
  /// **'This email is linked to a different Google account.'**
  String get authErrorEmailLinkedGoogle;

  /// No description provided for @authErrorAppleComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Apple Sign In is coming soon.'**
  String get authErrorAppleComingSoon;

  /// No description provided for @authErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get authErrorGeneric;

  /// No description provided for @authErrorGoogleWebUnconfigured.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in on web needs GOOGLE_WEB_CLIENT_ID at build time. Use email or guest for local dev.'**
  String get authErrorGoogleWebUnconfigured;

  /// No description provided for @authErrorGoogleIdToken.
  ///
  /// In en, this message translates to:
  /// **'Could not read your Google account. Please try again.'**
  String get authErrorGoogleIdToken;

  /// No description provided for @authErrorAppleIdentity.
  ///
  /// In en, this message translates to:
  /// **'Could not read your Apple ID. Please try again.'**
  String get authErrorAppleIdentity;

  /// No description provided for @authErrorAppleUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Apple Sign In is not available on this device.'**
  String get authErrorAppleUnavailable;

  /// No description provided for @writeReviewOverallRating.
  ///
  /// In en, this message translates to:
  /// **'Overall rating'**
  String get writeReviewOverallRating;

  /// No description provided for @writeReviewYourReview.
  ///
  /// In en, this message translates to:
  /// **'Your review'**
  String get writeReviewYourReview;

  /// No description provided for @writeReviewWrittenInAppLang.
  ///
  /// In en, this message translates to:
  /// **'Written in {code} — matches your app language when supported.'**
  String writeReviewWrittenInAppLang(String code);

  /// No description provided for @writeReviewOptionalScores.
  ///
  /// In en, this message translates to:
  /// **'Optional detail scores (1–5)'**
  String get writeReviewOptionalScores;

  /// No description provided for @writeReviewPickRating.
  ///
  /// In en, this message translates to:
  /// **'Pick a star rating from 1 to 5.'**
  String get writeReviewPickRating;

  /// No description provided for @writeReviewCommentMinLen.
  ///
  /// In en, this message translates to:
  /// **'Please write at least 20 characters.'**
  String get writeReviewCommentMinLen;

  /// No description provided for @writeReviewCommentMaxLen.
  ///
  /// In en, this message translates to:
  /// **'Comment is too long (max 4000 characters).'**
  String get writeReviewCommentMaxLen;

  /// No description provided for @writeReviewCommentMinWords.
  ///
  /// In en, this message translates to:
  /// **'Please use at least three words.'**
  String get writeReviewCommentMinWords;

  /// No description provided for @writeReviewCommentRepeated.
  ///
  /// In en, this message translates to:
  /// **'Comment cannot be a single repeated character.'**
  String get writeReviewCommentRepeated;

  /// No description provided for @writeReviewAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'You already shared a review for this place. Thanks for helping other parents!'**
  String get writeReviewAlreadyExists;

  /// No description provided for @writeReviewCouldNotPost.
  ///
  /// In en, this message translates to:
  /// **'Could not post your review. Check your connection and try again.'**
  String get writeReviewCouldNotPost;

  /// No description provided for @signInToPostReview.
  ///
  /// In en, this message translates to:
  /// **'Sign in with a full account to post a review.'**
  String get signInToPostReview;

  /// No description provided for @suggestCouldNotSend.
  ///
  /// In en, this message translates to:
  /// **'Could not send your suggestion. Try again in a moment.'**
  String get suggestCouldNotSend;

  /// No description provided for @suggestNameMin.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters.'**
  String get suggestNameMin;

  /// No description provided for @suggestNameAlphanumeric.
  ///
  /// In en, this message translates to:
  /// **'Name must include letters or digits.'**
  String get suggestNameAlphanumeric;

  /// No description provided for @suggestLocationNumbersInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter valid numbers for both latitude and longitude, or clear both.'**
  String get suggestLocationNumbersInvalid;

  /// No description provided for @suggestLocationOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'Coordinates are out of range.'**
  String get suggestLocationOutOfRange;

  /// No description provided for @suggestLocationEitherOr.
  ///
  /// In en, this message translates to:
  /// **'Add both latitude & longitude, or a location label (at least 5 characters).'**
  String get suggestLocationEitherOr;

  /// No description provided for @suggestDetailsMinLen.
  ///
  /// In en, this message translates to:
  /// **'If you add details, use at least 10 characters.'**
  String get suggestDetailsMinLen;

  /// No description provided for @suggestMinAgeRange.
  ///
  /// In en, this message translates to:
  /// **'Min age (months): use 0–216.'**
  String get suggestMinAgeRange;

  /// No description provided for @suggestMaxAgeRange.
  ///
  /// In en, this message translates to:
  /// **'Max age (months): use 0–216.'**
  String get suggestMaxAgeRange;

  /// No description provided for @suggestMinGreaterMax.
  ///
  /// In en, this message translates to:
  /// **'Min age cannot be greater than max age.'**
  String get suggestMinGreaterMax;

  /// No description provided for @suggestSupervisorAmenityRequires.
  ///
  /// In en, this message translates to:
  /// **'Play supervisor amenity requires \"Play supervisor on site\".'**
  String get suggestSupervisorAmenityRequires;

  /// No description provided for @suggestDropoffAmenityRequires.
  ///
  /// In en, this message translates to:
  /// **'Drop-off amenity requires \"Allows supervised drop-off\".'**
  String get suggestDropoffAmenityRequires;

  /// No description provided for @suggestValidationGeneric.
  ///
  /// In en, this message translates to:
  /// **'Please check the form and try again.'**
  String get suggestValidationGeneric;

  /// No description provided for @venueReviewsNotFound.
  ///
  /// In en, this message translates to:
  /// **'This venue could not be found.'**
  String get venueReviewsNotFound;

  /// No description provided for @venueReviewsUnsupportedLang.
  ///
  /// In en, this message translates to:
  /// **'This language is not supported for reviews.'**
  String get venueReviewsUnsupportedLang;

  /// No description provided for @venueReviewsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load reviews. Pull to try again.'**
  String get venueReviewsLoadFailed;

  /// No description provided for @venueReviewsNoReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet.'**
  String get venueReviewsNoReviews;

  /// No description provided for @venueReviewsBeFirst.
  ///
  /// In en, this message translates to:
  /// **'Be the first to share your experience.'**
  String get venueReviewsBeFirst;

  /// No description provided for @venueReviewsParentTitle.
  ///
  /// In en, this message translates to:
  /// **'Parent reviews'**
  String get venueReviewsParentTitle;

  /// No description provided for @formatDistanceMeters.
  ///
  /// In en, this message translates to:
  /// **'{meters} m'**
  String formatDistanceMeters(String meters);

  /// No description provided for @formatDistanceKm.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String formatDistanceKm(String km);

  /// No description provided for @ageAllAges.
  ///
  /// In en, this message translates to:
  /// **'All ages'**
  String get ageAllAges;

  /// No description provided for @ageYearsSingle.
  ///
  /// In en, this message translates to:
  /// **'{years} yrs'**
  String ageYearsSingle(String years);

  /// No description provided for @ageYearsRange.
  ///
  /// In en, this message translates to:
  /// **'{low}–{high} yrs'**
  String ageYearsRange(String low, String high);

  /// No description provided for @ratingNoRatingYet.
  ///
  /// In en, this message translates to:
  /// **'No rating yet'**
  String get ratingNoRatingYet;

  /// No description provided for @ratingWithCount.
  ///
  /// In en, this message translates to:
  /// **'{rating} · {count} reviews'**
  String ratingWithCount(String rating, String count);

  /// No description provided for @eventTodayTime.
  ///
  /// In en, this message translates to:
  /// **'Today, {time}'**
  String eventTodayTime(String time);

  /// No description provided for @eventAgesRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Ages {low}–{high}'**
  String eventAgesRangeLabel(String low, String high);

  /// No description provided for @eventAgesMinPlusLabel.
  ///
  /// In en, this message translates to:
  /// **'Ages {years}+'**
  String eventAgesMinPlusLabel(String years);

  /// No description provided for @eventAgesUpToOnly.
  ///
  /// In en, this message translates to:
  /// **'Up to {years}'**
  String eventAgesUpToOnly(String years);

  /// No description provided for @venueMilesAway.
  ///
  /// In en, this message translates to:
  /// **'{miles} miles away'**
  String venueMilesAway(String miles);

  /// No description provided for @venueDetailScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Venue Details'**
  String get venueDetailScreenTitle;

  /// No description provided for @venueAmenitiesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'What this place offers'**
  String get venueAmenitiesSectionTitle;

  /// No description provided for @venueGetDirectionsCta.
  ///
  /// In en, this message translates to:
  /// **'Get Directions'**
  String get venueGetDirectionsCta;

  /// No description provided for @venueOpenInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Maps'**
  String get venueOpenInMaps;

  /// No description provided for @venueReviewCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No reviews} one{1 review} other{{count} reviews}}'**
  String venueReviewCount(int count);

  /// No description provided for @shareVenueBody.
  ///
  /// In en, this message translates to:
  /// **'{name}\n{url}'**
  String shareVenueBody(String name, String url);

  /// No description provided for @favoriteCouldNotUpdate.
  ///
  /// In en, this message translates to:
  /// **'Could not update favorite. Try again.'**
  String get favoriteCouldNotUpdate;

  /// No description provided for @accountScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountScreenTitle;

  /// No description provided for @accountMemberSignedIn.
  ///
  /// In en, this message translates to:
  /// **'You are signed in with a full member account.'**
  String get accountMemberSignedIn;

  /// No description provided for @accountGuestSignedIn.
  ///
  /// In en, this message translates to:
  /// **'You are browsing as a guest. Sign in with a full account to save favorites on every device.'**
  String get accountGuestSignedIn;

  /// No description provided for @accountSignedOutBlurb.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save favorites, write reviews, and sync across devices.'**
  String get accountSignedOutBlurb;

  /// No description provided for @accountSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get accountSignOut;

  /// No description provided for @navSignInEntry.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get navSignInEntry;

  /// No description provided for @navMyAccountEntry.
  ///
  /// In en, this message translates to:
  /// **'My account'**
  String get navMyAccountEntry;

  /// No description provided for @navMyProfileEntry.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get navMyProfileEntry;

  /// No description provided for @venueAgeChipRange.
  ///
  /// In en, this message translates to:
  /// **'Ages {low}–{high}'**
  String venueAgeChipRange(String low, String high);

  /// No description provided for @ageMonthsShort.
  ///
  /// In en, this message translates to:
  /// **'{months} mo'**
  String ageMonthsShort(String months);

  /// No description provided for @ageYearsPlusShort.
  ///
  /// In en, this message translates to:
  /// **'{years}+'**
  String ageYearsPlusShort(String years);

  /// No description provided for @ageUpToWithLabel.
  ///
  /// In en, this message translates to:
  /// **'Up to {label}'**
  String ageUpToWithLabel(String label);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'it',
    'ja',
    'ko',
    'pt',
    'ru',
    'tr',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
