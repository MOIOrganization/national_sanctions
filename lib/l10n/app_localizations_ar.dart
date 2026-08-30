// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'العقوبات';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get loginSubtitle => 'أدخل بيانات الهوية للمتابعة.';

  @override
  String get loginCardHint => 'يرجى إدخال المعلومات المطلوبة أدناه.';

  @override
  String get cprNumber => 'الرقم الشخصي';

  @override
  String get enterCpr => 'أدخل الرقم الشخصي';

  @override
  String get cprRequired => 'يرجى إدخال الرقم الشخصي';

  @override
  String get cprMustBe9 => 'يجب أن يتكون الرقم الشخصي من 9 أرقام';

  @override
  String get cprExpiry => 'تاريخ انتهاء البطاقة';

  @override
  String get selectExpiry => 'يرجى اختيار تاريخ انتهاء البطاقة';

  @override
  String get blockNumber => 'رقم المجمع';

  @override
  String get enterBlock => 'أدخل رقم المجمع';

  @override
  String get blockRequired => 'يرجى إدخال رقم المجمع';

  @override
  String get mobileNumber => 'رقم الهاتف';

  @override
  String get enterMobile => 'أدخل رقم الهاتف';

  @override
  String get mobileRequired => 'يرجى إدخال رقم الهاتف';

  @override
  String get mobileMustBe8 => 'يجب أن يتكون رقم الهاتف من 8 أرقام';

  @override
  String get otpVerification => 'التحقق برمز OTP';

  @override
  String enterOtpSentTo(String phone) {
    return 'أدخل رمز التحقق المرسل إلى +973 $phone.';
  }

  @override
  String get resendOtp => 'إعادة إرسال الرمز';

  @override
  String get otpResent => 'تم إرسال رمز تحقق جديد.';

  @override
  String get enterSixDigitOtp => 'يرجى إدخال رمز التحقق المكوّن من 6 أرقام.';

  @override
  String get verifyAndLogin => 'تحقق وسجّل الدخول';

  @override
  String get unableToLogin => 'تعذر تسجيل الدخول. يرجى المحاولة مرة أخرى.';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get logOutConfirm =>
      'ستحتاج إلى تسجيل الدخول مرة أخرى للبحث في قوائم العقوبات.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get tryAgain => 'إعادة المحاولة';

  @override
  String get clear => 'مسح';

  @override
  String get switchToEnglish => 'EN';

  @override
  String get switchToArabic => 'ع';

  @override
  String get home => 'الرئيسية';

  @override
  String get un => 'أممي';

  @override
  String get national => 'وطني';

  @override
  String get nationalList => 'القائمة الوطنية';

  @override
  String get officialLookup => 'البحث الرسمي في العقوبات';

  @override
  String get searchUnAndNational =>
      'ابحث في قوائم الأمم المتحدة والقوائم الوطنية.';

  @override
  String get selectAList => 'اختر قائمة';

  @override
  String get unitedNations => 'الأمم المتحدة';

  @override
  String get unDescription =>
      'ابحث عن الأشخاص والكيانات المدرجين في قوائم الأمم المتحدة الرسمية.';

  @override
  String get nationalDescription =>
      'ابحث عن الأشخاص والكيانات المدرجين في القائمة الوطنية للعقوبات.';

  @override
  String get unSanctions => 'عقوبات الأمم المتحدة';

  @override
  String get nationalSanctions => 'العقوبات الوطنية';

  @override
  String get individuals => 'الأشخاص';

  @override
  String get entities => 'الكيانات';

  @override
  String get persons => 'الأشخاص';

  @override
  String get unIndividualsDescription =>
      'ابحث عن الأشخاص بالرقم أو الاسم أو الجنسية أو الرقم المرجعي.';

  @override
  String get unEntitiesDescription =>
      'ابحث عن الشركات والمنظمات والكيانات المدرجة الأخرى.';

  @override
  String get nationalPersonsDescription =>
      'ابحث عن الأشخاص المدرجين في القائمة الوطنية للعقوبات.';

  @override
  String get nationalEntitiesDescription =>
      'ابحث عن الكيانات المدرجة في القائمة الوطنية للعقوبات.';

  @override
  String get officialSourceDisclaimer =>
      'يجب دائماً التحقق من المعلومات من المصدر الرسمي قبل اتخاذ أي قرار قانوني أو امتثالي.';

  @override
  String get searchByNameIdReference =>
      'البحث بالاسم أو الرقم أو الرقم المرجعي';

  @override
  String get searchByNameIdRecorded => 'البحث بالاسم أو الرقم أو الاسم المسجل';

  @override
  String showingCount(int loaded, int total) {
    return 'عرض $loaded من $total';
  }

  @override
  String matchesCount(int matches, int loaded, int total) {
    return '$matches نتيجة في $loaded محمّل من $total';
  }

  @override
  String get loadingIndividuals => 'جاري تحميل الأشخاص...';

  @override
  String get loadingEntities => 'جاري تحميل الكيانات...';

  @override
  String get loadingPersons => 'جاري تحميل الأشخاص...';

  @override
  String get loadingIndividualDetails => 'جاري تحميل بيانات الفرد...';

  @override
  String get loadingEntityDetails => 'جاري تحميل بيانات الكيان...';

  @override
  String get unableToLoad => 'تعذر تحميل المعلومات';

  @override
  String get tryAgainLater =>
      'يرجى المحاولة مرة أخرى. إذا استمرت المشكلة، حاول لاحقاً.';

  @override
  String get unableToLoadIndividuals => 'تعذر تحميل الأشخاص';

  @override
  String get unableToLoadEntities => 'تعذر تحميل الكيانات';

  @override
  String get unableToLoadPersons => 'تعذر تحميل الأشخاص';

  @override
  String get unableToLoadIndividualDetails => 'تعذر تحميل بيانات الفرد';

  @override
  String get unableToLoadEntityDetails => 'تعذر تحميل بيانات الكيان';

  @override
  String get unableToRefreshRecord =>
      'تعذر تحديث السجل الكامل. يتم عرض المعلومات المتاحة.';

  @override
  String get noResultsFound => 'لا توجد نتائج';

  @override
  String get noMatchesLoaded =>
      'لا توجد مطابقات في السجلات المحمّلة. جرّب اسماً أو رقماً مرجعياً مختلفاً.';

  @override
  String get noIndividualsAvailable => 'لا يوجد أفراد متاحون حالياً.';

  @override
  String get noEntitiesAvailable => 'لا توجد كيانات متاحة حالياً.';

  @override
  String get noPersonsAvailable => 'لا يوجد أشخاص متاحون حالياً.';

  @override
  String get unnamedIndividual => 'فرد بدون اسم';

  @override
  String get unnamedPerson => 'شخص بدون اسم';

  @override
  String get unnamedEntity => 'كيان بدون اسم';

  @override
  String get individualDetails => 'بيانات الفرد';

  @override
  String get entityDetails => 'بيانات الكيان';

  @override
  String get nationalPersonDetails => 'بيانات الشخص الوطني';

  @override
  String get nationalEntityDetails => 'بيانات الكيان الوطني';

  @override
  String get nationalPersons => 'الأشخاص الوطنيون';

  @override
  String get nationalEntitiesTitle => 'الكيانات الوطنية';

  @override
  String get identity => 'الهوية';

  @override
  String get dates => 'التواريخ';

  @override
  String get nationality => 'الجنسية';

  @override
  String get dateOfBirth => 'تاريخ الميلاد';

  @override
  String dateOfBirthN(int n) {
    return 'تاريخ الميلاد $n';
  }

  @override
  String get placeOfBirth => 'مكان الميلاد';

  @override
  String placeOfBirthN(int n) {
    return 'مكان الميلاد $n';
  }

  @override
  String get documents => 'الوثائق';

  @override
  String get document => 'وثيقة';

  @override
  String documentN(int n) {
    return 'وثيقة $n';
  }

  @override
  String get aliases => 'الأسماء الحركية';

  @override
  String get alias => 'اسم حركي';

  @override
  String aliasN(int n) {
    return 'اسم حركي $n';
  }

  @override
  String get addresses => 'العناوين';

  @override
  String get address => 'العنوان';

  @override
  String addressN(int n) {
    return 'عنوان $n';
  }

  @override
  String get interpol => 'الإنتربول';

  @override
  String get interpolNotice => 'إشعار الإنتربول';

  @override
  String get listingInformation => 'بيانات الإدراج';

  @override
  String get additionalInformation => 'معلومات إضافية';

  @override
  String get otherDetails => 'تفاصيل أخرى';

  @override
  String get identification => 'إثبات الهوية';

  @override
  String get arabicName => 'الاسم بالعربية';

  @override
  String get englishName => 'الاسم بالإنجليزية';

  @override
  String get recordedName => 'الاسم المسجل';

  @override
  String get originalScriptName => 'الاسم بالنص الأصلي';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get secondName => 'الاسم الثاني';

  @override
  String get thirdName => 'الاسم الثالث';

  @override
  String get fourthName => 'الاسم الرابع';

  @override
  String get name => 'الاسم';

  @override
  String get listType => 'نوع القائمة';

  @override
  String get referenceNumber => 'الرقم المرجعي';

  @override
  String get listSerial => 'الرقم التسلسلي';

  @override
  String get id => 'الرقم';

  @override
  String get entityType => 'نوع الكيان';

  @override
  String get legalStatus => 'الصفة القانونية';

  @override
  String get gender => 'الجنس';

  @override
  String get passport => 'جواز السفر';

  @override
  String get nationalId => 'الرقم الوطني';

  @override
  String get cpr => 'الرقم الشخصي';

  @override
  String get documentNumber => 'رقم الوثيقة';

  @override
  String get nicknameAlias => 'اللقب / الاسم الحركي';

  @override
  String get alsoKnownAs => 'يُعرف أيضاً بـ';

  @override
  String get description => 'الوصف';

  @override
  String get leadership => 'القيادة';

  @override
  String get activity => 'النشاط';

  @override
  String get priorityLevel => 'مستوى الأولوية';

  @override
  String get reasoning => 'المبرر';

  @override
  String get notes => 'ملاحظات';

  @override
  String get comments => 'تعليقات';

  @override
  String get designation => 'الصفة';

  @override
  String get quality => 'الجودة';

  @override
  String get type => 'النوع';

  @override
  String get countryOfIssue => 'بلد الإصدار';

  @override
  String get note => 'ملاحظة';

  @override
  String get detail => 'تفصيل';

  @override
  String get requestDate => 'تاريخ الطلب';

  @override
  String get classificationDate => 'تاريخ التصنيف';

  @override
  String get sourceListingDate => 'تاريخ الإدراج في المصدر';

  @override
  String get sentenceDate => 'تاريخ الحكم';

  @override
  String get created => 'تاريخ الإنشاء';

  @override
  String get updated => 'تاريخ التحديث';

  @override
  String get lastUpdated => 'آخر تحديث';

  @override
  String get recordId => 'رقم السجل';

  @override
  String get version => 'الإصدار';

  @override
  String get invalidRecordId => 'هذا السجل لا يحتوي على رقم بيانات صالح.';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get noNotificationsYet => 'لا توجد إشعارات حتى الآن';

  @override
  String get noNotificationsMessage => 'لا توجد لديك إشعارات في الوقت الحالي.';

  @override
  String get notificationDegreeHigh => 'عالي';

  @override
  String get notificationDegreeMedium => 'متوسط';

  @override
  String get notificationDegreeLow => 'منخفض';

  @override
  String get accountMenu => 'الحساب';

  @override
  String get signedInAs => 'تم تسجيل الدخول باسم';

  @override
  String get biometricLogin => 'تسجيل الدخول بالبصمة';

  @override
  String get biometricLoginDescription =>
      'استخدم المصادقة الحيوية لتسجيل الدخول';

  @override
  String get enableBiometric => 'تفعيل تسجيل الدخول بالبصمة';

  @override
  String get disableBiometric => 'تعطيل تسجيل الدخول بالبصمة';

  @override
  String get biometricEnabledTitle => 'تم تفعيل تسجيل الدخول بالبصمة';

  @override
  String get biometricEnabledMessage => 'تم تفعيل تسجيل الدخول بالبصمة بنجاح.';

  @override
  String get disableBiometricTitle => 'تعطيل تسجيل الدخول بالبصمة؟';

  @override
  String get disableBiometricMessage =>
      'هل أنت متأكد أنك تريد تعطيل تسجيل الدخول بالبصمة؟';

  @override
  String get disable => 'تعطيل';

  @override
  String get biometricDisabledTitle => 'تم تعطيل تسجيل الدخول بالبصمة';

  @override
  String get biometricDisabledMessage => 'تم تعطيل تسجيل الدخول بالبصمة.';

  @override
  String get biometricNotEnabledTitle => 'لم يتم تفعيل تسجيل الدخول بالبصمة';

  @override
  String get biometricNotEnabledMessage =>
      'يرجى تفعيل تسجيل الدخول بالبصمة من داخل التطبيق بعد تسجيل الدخول.';

  @override
  String get logoutQuestion => 'تسجيل الخروج؟';

  @override
  String get logoutConfirmQuestion => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get ok => 'حسناً';
}
