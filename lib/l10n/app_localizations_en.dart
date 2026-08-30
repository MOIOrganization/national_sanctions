// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sanctions';

  @override
  String get login => 'Login';

  @override
  String get loginSubtitle => 'Enter your identification details to continue.';

  @override
  String get loginCardHint => 'Please provide the required information below.';

  @override
  String get cprNumber => 'CPR Number';

  @override
  String get enterCpr => 'Enter CPR number';

  @override
  String get cprRequired => 'Please enter your CPR number';

  @override
  String get cprMustBe9 => 'CPR number must be 9 digits';

  @override
  String get cprExpiry => 'CPR Expiry Date';

  @override
  String get selectExpiry => 'Please select the CPR expiry date';

  @override
  String get blockNumber => 'Block Number';

  @override
  String get enterBlock => 'Enter block number';

  @override
  String get blockRequired => 'Please enter your block number';

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get enterMobile => 'Enter mobile number';

  @override
  String get mobileRequired => 'Please enter your mobile number';

  @override
  String get mobileMustBe8 => 'Mobile number must be 8 digits';

  @override
  String get otpVerification => 'OTP Verification';

  @override
  String enterOtpSentTo(String phone) {
    return 'Enter the verification code sent to +973 $phone.';
  }

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String get otpResent => 'A new OTP has been sent.';

  @override
  String get enterSixDigitOtp => 'Please enter the 6-digit OTP.';

  @override
  String get verifyAndLogin => 'Verify and Login';

  @override
  String get unableToLogin => 'Unable to login. Please try again.';

  @override
  String get logOut => 'Logout';

  @override
  String get logOutConfirm =>
      'You will need to sign in again to search sanctions lists.';

  @override
  String get cancel => 'Cancel';

  @override
  String get tryAgain => 'Try again';

  @override
  String get clear => 'Clear';

  @override
  String get switchToEnglish => 'EN';

  @override
  String get switchToArabic => 'ع';

  @override
  String get home => 'Home';

  @override
  String get un => 'UN';

  @override
  String get national => 'National';

  @override
  String get nationalList => 'National List';

  @override
  String get officialLookup => 'Official sanctions lookup';

  @override
  String get searchUnAndNational => 'Search United Nations and national lists.';

  @override
  String get selectAList => 'Select a list';

  @override
  String get unitedNations => 'United Nations';

  @override
  String get unDescription =>
      'Search individuals and entities on official UN sanctions lists.';

  @override
  String get nationalDescription =>
      'Search persons and entities on the national sanctions list.';

  @override
  String get unSanctions => 'UN Sanctions';

  @override
  String get nationalSanctions => 'National Sanctions';

  @override
  String get individuals => 'Individuals';

  @override
  String get entities => 'Entities';

  @override
  String get persons => 'Persons';

  @override
  String get unIndividualsDescription =>
      'Search individuals by ID, name, nationality or reference number.';

  @override
  String get unEntitiesDescription =>
      'Search companies, organisations and other listed entities.';

  @override
  String get nationalPersonsDescription =>
      'Search persons included in the national sanctions list.';

  @override
  String get nationalEntitiesDescription =>
      'Search entities included in the national sanctions list.';

  @override
  String get officialSourceDisclaimer =>
      'Information should always be verified against the official source before making a legal or compliance decision.';

  @override
  String get searchByNameIdReference =>
      'Search by name, ID or reference number';

  @override
  String get searchByNameIdRecorded => 'Search by name, ID or recorded name';

  @override
  String showingCount(int loaded, int total) {
    return 'Showing $loaded of $total';
  }

  @override
  String matchesCount(int matches, int loaded, int total) {
    return '$matches matches in $loaded loaded of $total';
  }

  @override
  String get loadingIndividuals => 'Loading individuals...';

  @override
  String get loadingEntities => 'Loading entities...';

  @override
  String get loadingPersons => 'Loading persons...';

  @override
  String get loadingIndividualDetails => 'Loading individual details...';

  @override
  String get loadingEntityDetails => 'Loading entity details...';

  @override
  String get unableToLoad => 'Unable to load information';

  @override
  String get tryAgainLater =>
      'Please try again. If the problem continues, try later.';

  @override
  String get unableToLoadIndividuals => 'Unable to load individuals';

  @override
  String get unableToLoadEntities => 'Unable to load entities';

  @override
  String get unableToLoadPersons => 'Unable to load persons';

  @override
  String get unableToLoadIndividualDetails =>
      'Unable to load individual details';

  @override
  String get unableToLoadEntityDetails => 'Unable to load entity details';

  @override
  String get unableToRefreshRecord =>
      'Unable to refresh the full record. Showing available information.';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get noMatchesLoaded =>
      'No matches in the records already loaded. Try a different name or reference number.';

  @override
  String get noIndividualsAvailable =>
      'No individuals are available right now.';

  @override
  String get noEntitiesAvailable => 'No entities are available right now.';

  @override
  String get noPersonsAvailable => 'No persons are available right now.';

  @override
  String get unnamedIndividual => 'Unnamed individual';

  @override
  String get unnamedPerson => 'Unnamed person';

  @override
  String get unnamedEntity => 'Unnamed entity';

  @override
  String get individualDetails => 'Individual Details';

  @override
  String get entityDetails => 'Entity Details';

  @override
  String get nationalPersonDetails => 'National Person Details';

  @override
  String get nationalEntityDetails => 'National Entity Details';

  @override
  String get nationalPersons => 'National Persons';

  @override
  String get nationalEntitiesTitle => 'National Entities';

  @override
  String get identity => 'Identity';

  @override
  String get dates => 'Dates';

  @override
  String get nationality => 'Nationality';

  @override
  String get dateOfBirth => 'Date of birth';

  @override
  String dateOfBirthN(int n) {
    return 'Date of birth $n';
  }

  @override
  String get placeOfBirth => 'Place of birth';

  @override
  String placeOfBirthN(int n) {
    return 'Place of birth $n';
  }

  @override
  String get documents => 'Documents';

  @override
  String get document => 'Document';

  @override
  String documentN(int n) {
    return 'Document $n';
  }

  @override
  String get aliases => 'Aliases';

  @override
  String get alias => 'Alias';

  @override
  String aliasN(int n) {
    return 'Alias $n';
  }

  @override
  String get addresses => 'Addresses';

  @override
  String get address => 'Address';

  @override
  String addressN(int n) {
    return 'Address $n';
  }

  @override
  String get interpol => 'Interpol';

  @override
  String get interpolNotice => 'Interpol notice';

  @override
  String get listingInformation => 'Listing information';

  @override
  String get additionalInformation => 'Additional information';

  @override
  String get otherDetails => 'Other details';

  @override
  String get identification => 'Identification';

  @override
  String get arabicName => 'Arabic name';

  @override
  String get englishName => 'English name';

  @override
  String get recordedName => 'Recorded name';

  @override
  String get originalScriptName => 'Original-script name';

  @override
  String get firstName => 'First name';

  @override
  String get secondName => 'Second name';

  @override
  String get thirdName => 'Third name';

  @override
  String get fourthName => 'Fourth name';

  @override
  String get name => 'Name';

  @override
  String get listType => 'List type';

  @override
  String get referenceNumber => 'Reference number';

  @override
  String get listSerial => 'List serial';

  @override
  String get id => 'ID';

  @override
  String get entityType => 'Entity type';

  @override
  String get legalStatus => 'Legal status';

  @override
  String get gender => 'Gender';

  @override
  String get passport => 'Passport';

  @override
  String get nationalId => 'National ID';

  @override
  String get cpr => 'CPR';

  @override
  String get documentNumber => 'Document number';

  @override
  String get nicknameAlias => 'Nickname / alias';

  @override
  String get alsoKnownAs => 'Also known as';

  @override
  String get description => 'Description';

  @override
  String get leadership => 'Leadership';

  @override
  String get activity => 'Activity';

  @override
  String get priorityLevel => 'Priority level';

  @override
  String get reasoning => 'Reasoning';

  @override
  String get notes => 'Notes';

  @override
  String get comments => 'Comments';

  @override
  String get designation => 'Designation';

  @override
  String get quality => 'Quality';

  @override
  String get type => 'Type';

  @override
  String get countryOfIssue => 'Country of issue';

  @override
  String get note => 'Note';

  @override
  String get detail => 'Detail';

  @override
  String get requestDate => 'Request date';

  @override
  String get classificationDate => 'Classification date';

  @override
  String get sourceListingDate => 'Source listing date';

  @override
  String get sentenceDate => 'Sentence date';

  @override
  String get created => 'Created';

  @override
  String get updated => 'Updated';

  @override
  String get lastUpdated => 'Last updated';

  @override
  String get recordId => 'Record ID';

  @override
  String get version => 'Version';

  @override
  String get invalidRecordId => 'This record does not have a valid data ID.';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get noNotificationsMessage =>
      'You don\'t have any notifications at the moment.';

  @override
  String get notificationDegreeHigh => 'High';

  @override
  String get notificationDegreeMedium => 'Medium';

  @override
  String get notificationDegreeLow => 'Low';

  @override
  String get accountMenu => 'Account';

  @override
  String get signedInAs => 'Signed in as';

  @override
  String get biometricLogin => 'Biometric Login';

  @override
  String get biometricLoginDescription =>
      'Use biometric authentication to sign in';

  @override
  String get enableBiometric => 'Enable Biometric';

  @override
  String get disableBiometric => 'Disable Biometric';

  @override
  String get biometricEnabledTitle => 'Biometric login enabled';

  @override
  String get biometricEnabledMessage =>
      'Biometric login has been enabled successfully.';

  @override
  String get disableBiometricTitle => 'Disable biometric login?';

  @override
  String get disableBiometricMessage =>
      'Are you sure you want to disable biometric login?';

  @override
  String get disable => 'Disable';

  @override
  String get biometricDisabledTitle => 'Biometric login disabled';

  @override
  String get biometricDisabledMessage => 'Biometric login has been disabled.';

  @override
  String get biometricNotEnabledTitle => 'Biometric Login Not Enabled';

  @override
  String get biometricNotEnabledMessage =>
      'Please enable biometric login within the app after logging in.';

  @override
  String get logoutQuestion => 'Logout?';

  @override
  String get logoutConfirmQuestion => 'Are you sure you want to logout?';

  @override
  String get ok => 'OK';
}
