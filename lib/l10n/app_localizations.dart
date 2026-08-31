import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Sanctions'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your identification details to continue.'**
  String get loginSubtitle;

  /// No description provided for @loginCardHint.
  ///
  /// In en, this message translates to:
  /// **'Please provide the required information below.'**
  String get loginCardHint;

  /// No description provided for @cprNumber.
  ///
  /// In en, this message translates to:
  /// **'CPR Number'**
  String get cprNumber;

  /// No description provided for @enterCpr.
  ///
  /// In en, this message translates to:
  /// **'Enter CPR number'**
  String get enterCpr;

  /// No description provided for @cprRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your CPR number'**
  String get cprRequired;

  /// No description provided for @cprMustBe9.
  ///
  /// In en, this message translates to:
  /// **'CPR number must be 9 digits'**
  String get cprMustBe9;

  /// No description provided for @cprExpiry.
  ///
  /// In en, this message translates to:
  /// **'CPR Expiry Date'**
  String get cprExpiry;

  /// No description provided for @selectExpiry.
  ///
  /// In en, this message translates to:
  /// **'Please select the CPR expiry date'**
  String get selectExpiry;

  /// No description provided for @blockNumber.
  ///
  /// In en, this message translates to:
  /// **'Block Number'**
  String get blockNumber;

  /// No description provided for @enterBlock.
  ///
  /// In en, this message translates to:
  /// **'Enter block number'**
  String get enterBlock;

  /// No description provided for @blockRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your block number'**
  String get blockRequired;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @enterMobile.
  ///
  /// In en, this message translates to:
  /// **'Enter mobile number'**
  String get enterMobile;

  /// No description provided for @mobileRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your mobile number'**
  String get mobileRequired;

  /// No description provided for @mobileMustBe8.
  ///
  /// In en, this message translates to:
  /// **'Mobile number must be 8 digits'**
  String get mobileMustBe8;

  /// No description provided for @otpVerification.
  ///
  /// In en, this message translates to:
  /// **'OTP Verification'**
  String get otpVerification;

  /// No description provided for @enterOtpSentTo.
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code sent to +973 {phone}.'**
  String enterOtpSentTo(String phone);

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @otpResent.
  ///
  /// In en, this message translates to:
  /// **'A new OTP has been sent.'**
  String get otpResent;

  /// No description provided for @enterSixDigitOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6-digit OTP.'**
  String get enterSixDigitOtp;

  /// No description provided for @verifyAndLogin.
  ///
  /// In en, this message translates to:
  /// **'Verify and Login'**
  String get verifyAndLogin;

  /// No description provided for @unableToLogin.
  ///
  /// In en, this message translates to:
  /// **'Unable to login. Please try again.'**
  String get unableToLogin;

  /// No description provided for @unableToVerifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Unable to verify the code. Please try again.'**
  String get unableToVerifyOtp;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logOut;

  /// No description provided for @logOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to search sanctions lists.'**
  String get logOutConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @switchToEnglish.
  ///
  /// In en, this message translates to:
  /// **'EN'**
  String get switchToEnglish;

  /// No description provided for @switchToArabic.
  ///
  /// In en, this message translates to:
  /// **'ع'**
  String get switchToArabic;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @un.
  ///
  /// In en, this message translates to:
  /// **'UN'**
  String get un;

  /// No description provided for @national.
  ///
  /// In en, this message translates to:
  /// **'National'**
  String get national;

  /// No description provided for @nationalList.
  ///
  /// In en, this message translates to:
  /// **'National List'**
  String get nationalList;

  /// No description provided for @officialLookup.
  ///
  /// In en, this message translates to:
  /// **'Official sanctions lookup'**
  String get officialLookup;

  /// No description provided for @searchUnAndNational.
  ///
  /// In en, this message translates to:
  /// **'Search United Nations and national lists.'**
  String get searchUnAndNational;

  /// No description provided for @selectAList.
  ///
  /// In en, this message translates to:
  /// **'Select a list'**
  String get selectAList;

  /// No description provided for @unitedNations.
  ///
  /// In en, this message translates to:
  /// **'United Nations'**
  String get unitedNations;

  /// No description provided for @unDescription.
  ///
  /// In en, this message translates to:
  /// **'Search individuals and entities on official UN sanctions lists.'**
  String get unDescription;

  /// No description provided for @nationalDescription.
  ///
  /// In en, this message translates to:
  /// **'Search persons and entities on the national sanctions list.'**
  String get nationalDescription;

  /// No description provided for @unSanctions.
  ///
  /// In en, this message translates to:
  /// **'UN Sanctions'**
  String get unSanctions;

  /// No description provided for @nationalSanctions.
  ///
  /// In en, this message translates to:
  /// **'National Sanctions'**
  String get nationalSanctions;

  /// No description provided for @individuals.
  ///
  /// In en, this message translates to:
  /// **'Individuals'**
  String get individuals;

  /// No description provided for @entities.
  ///
  /// In en, this message translates to:
  /// **'Entities'**
  String get entities;

  /// No description provided for @persons.
  ///
  /// In en, this message translates to:
  /// **'Persons'**
  String get persons;

  /// No description provided for @unIndividualsDescription.
  ///
  /// In en, this message translates to:
  /// **'Search individuals by ID, name, nationality or reference number.'**
  String get unIndividualsDescription;

  /// No description provided for @unEntitiesDescription.
  ///
  /// In en, this message translates to:
  /// **'Search companies, organisations and other listed entities.'**
  String get unEntitiesDescription;

  /// No description provided for @nationalPersonsDescription.
  ///
  /// In en, this message translates to:
  /// **'Search persons included in the national sanctions list.'**
  String get nationalPersonsDescription;

  /// No description provided for @nationalEntitiesDescription.
  ///
  /// In en, this message translates to:
  /// **'Search entities included in the national sanctions list.'**
  String get nationalEntitiesDescription;

  /// No description provided for @officialSourceDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Information should always be verified against the official source before making a legal or compliance decision.'**
  String get officialSourceDisclaimer;

  /// No description provided for @searchByNameIdReference.
  ///
  /// In en, this message translates to:
  /// **'Search by name, ID or reference number'**
  String get searchByNameIdReference;

  /// No description provided for @searchByNameIdRecorded.
  ///
  /// In en, this message translates to:
  /// **'Search by name, ID or recorded name'**
  String get searchByNameIdRecorded;

  /// No description provided for @showingCount.
  ///
  /// In en, this message translates to:
  /// **'Showing {loaded} of {total}'**
  String showingCount(int loaded, int total);

  /// No description provided for @matchesCount.
  ///
  /// In en, this message translates to:
  /// **'{matches} matches in {loaded} loaded of {total}'**
  String matchesCount(int matches, int loaded, int total);

  /// No description provided for @loadingIndividuals.
  ///
  /// In en, this message translates to:
  /// **'Loading individuals...'**
  String get loadingIndividuals;

  /// No description provided for @loadingEntities.
  ///
  /// In en, this message translates to:
  /// **'Loading entities...'**
  String get loadingEntities;

  /// No description provided for @loadingPersons.
  ///
  /// In en, this message translates to:
  /// **'Loading persons...'**
  String get loadingPersons;

  /// No description provided for @loadingIndividualDetails.
  ///
  /// In en, this message translates to:
  /// **'Loading individual details...'**
  String get loadingIndividualDetails;

  /// No description provided for @loadingEntityDetails.
  ///
  /// In en, this message translates to:
  /// **'Loading entity details...'**
  String get loadingEntityDetails;

  /// No description provided for @unableToLoad.
  ///
  /// In en, this message translates to:
  /// **'Unable to load information'**
  String get unableToLoad;

  /// No description provided for @tryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again. If the problem continues, try later.'**
  String get tryAgainLater;

  /// No description provided for @unableToLoadIndividuals.
  ///
  /// In en, this message translates to:
  /// **'Unable to load individuals'**
  String get unableToLoadIndividuals;

  /// No description provided for @unableToLoadEntities.
  ///
  /// In en, this message translates to:
  /// **'Unable to load entities'**
  String get unableToLoadEntities;

  /// No description provided for @unableToLoadPersons.
  ///
  /// In en, this message translates to:
  /// **'Unable to load persons'**
  String get unableToLoadPersons;

  /// No description provided for @unableToLoadIndividualDetails.
  ///
  /// In en, this message translates to:
  /// **'Unable to load individual details'**
  String get unableToLoadIndividualDetails;

  /// No description provided for @unableToLoadEntityDetails.
  ///
  /// In en, this message translates to:
  /// **'Unable to load entity details'**
  String get unableToLoadEntityDetails;

  /// No description provided for @unableToRefreshRecord.
  ///
  /// In en, this message translates to:
  /// **'Unable to refresh the full record. Showing available information.'**
  String get unableToRefreshRecord;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @noMatchesLoaded.
  ///
  /// In en, this message translates to:
  /// **'No matches in the records already loaded. Try a different name or reference number.'**
  String get noMatchesLoaded;

  /// No description provided for @noIndividualsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No individuals are available right now.'**
  String get noIndividualsAvailable;

  /// No description provided for @noEntitiesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No entities are available right now.'**
  String get noEntitiesAvailable;

  /// No description provided for @noPersonsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No persons are available right now.'**
  String get noPersonsAvailable;

  /// No description provided for @unnamedIndividual.
  ///
  /// In en, this message translates to:
  /// **'Unnamed individual'**
  String get unnamedIndividual;

  /// No description provided for @unnamedPerson.
  ///
  /// In en, this message translates to:
  /// **'Unnamed person'**
  String get unnamedPerson;

  /// No description provided for @unnamedEntity.
  ///
  /// In en, this message translates to:
  /// **'Unnamed entity'**
  String get unnamedEntity;

  /// No description provided for @individualDetails.
  ///
  /// In en, this message translates to:
  /// **'Individual Details'**
  String get individualDetails;

  /// No description provided for @entityDetails.
  ///
  /// In en, this message translates to:
  /// **'Entity Details'**
  String get entityDetails;

  /// No description provided for @nationalPersonDetails.
  ///
  /// In en, this message translates to:
  /// **'National Person Details'**
  String get nationalPersonDetails;

  /// No description provided for @nationalEntityDetails.
  ///
  /// In en, this message translates to:
  /// **'National Entity Details'**
  String get nationalEntityDetails;

  /// No description provided for @nationalPersons.
  ///
  /// In en, this message translates to:
  /// **'National Persons'**
  String get nationalPersons;

  /// No description provided for @nationalEntitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'National Entities'**
  String get nationalEntitiesTitle;

  /// No description provided for @identity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get identity;

  /// No description provided for @dates.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get dates;

  /// No description provided for @nationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get nationality;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateOfBirth;

  /// No description provided for @dateOfBirthN.
  ///
  /// In en, this message translates to:
  /// **'Date of birth {n}'**
  String dateOfBirthN(int n);

  /// No description provided for @placeOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Place of birth'**
  String get placeOfBirth;

  /// No description provided for @placeOfBirthN.
  ///
  /// In en, this message translates to:
  /// **'Place of birth {n}'**
  String placeOfBirthN(int n);

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @document.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get document;

  /// No description provided for @documentN.
  ///
  /// In en, this message translates to:
  /// **'Document {n}'**
  String documentN(int n);

  /// No description provided for @aliases.
  ///
  /// In en, this message translates to:
  /// **'Aliases'**
  String get aliases;

  /// No description provided for @alias.
  ///
  /// In en, this message translates to:
  /// **'Alias'**
  String get alias;

  /// No description provided for @aliasN.
  ///
  /// In en, this message translates to:
  /// **'Alias {n}'**
  String aliasN(int n);

  /// No description provided for @addresses.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get addresses;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @addressN.
  ///
  /// In en, this message translates to:
  /// **'Address {n}'**
  String addressN(int n);

  /// No description provided for @interpol.
  ///
  /// In en, this message translates to:
  /// **'Interpol'**
  String get interpol;

  /// No description provided for @interpolNotice.
  ///
  /// In en, this message translates to:
  /// **'Interpol notice'**
  String get interpolNotice;

  /// No description provided for @listingInformation.
  ///
  /// In en, this message translates to:
  /// **'Listing information'**
  String get listingInformation;

  /// No description provided for @additionalInformation.
  ///
  /// In en, this message translates to:
  /// **'Additional information'**
  String get additionalInformation;

  /// No description provided for @otherDetails.
  ///
  /// In en, this message translates to:
  /// **'Other details'**
  String get otherDetails;

  /// No description provided for @identification.
  ///
  /// In en, this message translates to:
  /// **'Identification'**
  String get identification;

  /// No description provided for @arabicName.
  ///
  /// In en, this message translates to:
  /// **'Arabic name'**
  String get arabicName;

  /// No description provided for @englishName.
  ///
  /// In en, this message translates to:
  /// **'English name'**
  String get englishName;

  /// No description provided for @recordedName.
  ///
  /// In en, this message translates to:
  /// **'Recorded name'**
  String get recordedName;

  /// No description provided for @originalScriptName.
  ///
  /// In en, this message translates to:
  /// **'Original-script name'**
  String get originalScriptName;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @secondName.
  ///
  /// In en, this message translates to:
  /// **'Second name'**
  String get secondName;

  /// No description provided for @thirdName.
  ///
  /// In en, this message translates to:
  /// **'Third name'**
  String get thirdName;

  /// No description provided for @fourthName.
  ///
  /// In en, this message translates to:
  /// **'Fourth name'**
  String get fourthName;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @listType.
  ///
  /// In en, this message translates to:
  /// **'List type'**
  String get listType;

  /// No description provided for @referenceNumber.
  ///
  /// In en, this message translates to:
  /// **'Reference number'**
  String get referenceNumber;

  /// No description provided for @listSerial.
  ///
  /// In en, this message translates to:
  /// **'List serial'**
  String get listSerial;

  /// No description provided for @id.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get id;

  /// No description provided for @entityType.
  ///
  /// In en, this message translates to:
  /// **'Entity type'**
  String get entityType;

  /// No description provided for @legalStatus.
  ///
  /// In en, this message translates to:
  /// **'Legal status'**
  String get legalStatus;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @passport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get passport;

  /// No description provided for @nationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get nationalId;

  /// No description provided for @cpr.
  ///
  /// In en, this message translates to:
  /// **'CPR'**
  String get cpr;

  /// No description provided for @documentNumber.
  ///
  /// In en, this message translates to:
  /// **'Document number'**
  String get documentNumber;

  /// No description provided for @nicknameAlias.
  ///
  /// In en, this message translates to:
  /// **'Nickname / alias'**
  String get nicknameAlias;

  /// No description provided for @alsoKnownAs.
  ///
  /// In en, this message translates to:
  /// **'Also known as'**
  String get alsoKnownAs;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @leadership.
  ///
  /// In en, this message translates to:
  /// **'Leadership'**
  String get leadership;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @priorityLevel.
  ///
  /// In en, this message translates to:
  /// **'Priority level'**
  String get priorityLevel;

  /// No description provided for @reasoning.
  ///
  /// In en, this message translates to:
  /// **'Reasoning'**
  String get reasoning;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @designation.
  ///
  /// In en, this message translates to:
  /// **'Designation'**
  String get designation;

  /// No description provided for @quality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get quality;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @countryOfIssue.
  ///
  /// In en, this message translates to:
  /// **'Country of issue'**
  String get countryOfIssue;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @detail.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get detail;

  /// No description provided for @requestDate.
  ///
  /// In en, this message translates to:
  /// **'Request date'**
  String get requestDate;

  /// No description provided for @classificationDate.
  ///
  /// In en, this message translates to:
  /// **'Classification date'**
  String get classificationDate;

  /// No description provided for @sourceListingDate.
  ///
  /// In en, this message translates to:
  /// **'Source listing date'**
  String get sourceListingDate;

  /// No description provided for @sentenceDate.
  ///
  /// In en, this message translates to:
  /// **'Sentence date'**
  String get sentenceDate;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updated;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get lastUpdated;

  /// No description provided for @recordId.
  ///
  /// In en, this message translates to:
  /// **'Record ID'**
  String get recordId;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @invalidRecordId.
  ///
  /// In en, this message translates to:
  /// **'This record does not have a valid data ID.'**
  String get invalidRecordId;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @noNotificationsMessage.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any notifications at the moment.'**
  String get noNotificationsMessage;

  /// No description provided for @notificationDegreeHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get notificationDegreeHigh;

  /// No description provided for @notificationDegreeMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get notificationDegreeMedium;

  /// No description provided for @notificationDegreeLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get notificationDegreeLow;

  /// No description provided for @accountMenu.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountMenu;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as'**
  String get signedInAs;

  /// No description provided for @biometricLogin.
  ///
  /// In en, this message translates to:
  /// **'Biometric Login'**
  String get biometricLogin;

  /// No description provided for @biometricLoginDescription.
  ///
  /// In en, this message translates to:
  /// **'Use biometric authentication to sign in'**
  String get biometricLoginDescription;

  /// No description provided for @enableBiometric.
  ///
  /// In en, this message translates to:
  /// **'Enable Biometric'**
  String get enableBiometric;

  /// No description provided for @disableBiometric.
  ///
  /// In en, this message translates to:
  /// **'Disable Biometric'**
  String get disableBiometric;

  /// No description provided for @biometricEnabledTitle.
  ///
  /// In en, this message translates to:
  /// **'Biometric login enabled'**
  String get biometricEnabledTitle;

  /// No description provided for @biometricEnabledMessage.
  ///
  /// In en, this message translates to:
  /// **'Biometric login has been enabled successfully.'**
  String get biometricEnabledMessage;

  /// No description provided for @disableBiometricTitle.
  ///
  /// In en, this message translates to:
  /// **'Disable biometric login?'**
  String get disableBiometricTitle;

  /// No description provided for @disableBiometricMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to disable biometric login?'**
  String get disableBiometricMessage;

  /// No description provided for @disable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// No description provided for @biometricDisabledTitle.
  ///
  /// In en, this message translates to:
  /// **'Biometric login disabled'**
  String get biometricDisabledTitle;

  /// No description provided for @biometricDisabledMessage.
  ///
  /// In en, this message translates to:
  /// **'Biometric login has been disabled.'**
  String get biometricDisabledMessage;

  /// No description provided for @biometricNotEnabledTitle.
  ///
  /// In en, this message translates to:
  /// **'Biometric Login Not Enabled'**
  String get biometricNotEnabledTitle;

  /// No description provided for @biometricNotEnabledMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enable biometric login within the app after logging in.'**
  String get biometricNotEnabledMessage;

  /// No description provided for @logoutQuestion.
  ///
  /// In en, this message translates to:
  /// **'Logout?'**
  String get logoutQuestion;

  /// No description provided for @logoutConfirmQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmQuestion;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
