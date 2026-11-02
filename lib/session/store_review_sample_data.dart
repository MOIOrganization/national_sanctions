import '../models.dart';
import '../models/app_notification.dart';

/// Demonstration records shown only while the Apple review account
/// is signed in. Live users never read this data.
class StoreReviewSampleData {
  const StoreReviewSampleData._();

  static IndividualResponse individualsPage({
    required int offset,
    required int limit,
  }) {
    return IndividualResponse(
      totalRecords: _individuals.length,
      offset: offset,
      limit: limit,
      individuals: _page(_individuals, offset, limit),
    );
  }

  static Individual? individualById(int dataId) {
    for (final Individual individual in _individuals) {
      if (individual.dataId == dataId) {
        return individual;
      }
    }

    return null;
  }

  static Map<String, dynamic> entitiesPage({
    required int offset,
    required int limit,
  }) {
    return _pageMap(_entities, offset, limit);
  }

  static Map<String, dynamic>? entityById(int dataId) {
    for (final Map<String, dynamic> entity in _entities) {
      if (_toInt(entity['DATAID']) == dataId) {
        return Map<String, dynamic>.from(entity);
      }
    }

    return null;
  }

  static Map<String, dynamic> nationalPersonsPage({
    required int offset,
    required int limit,
  }) {
    return _pageMap(_nationalPersons, offset, limit);
  }

  static Map<String, dynamic> nationalEntitiesPage({
    required int offset,
    required int limit,
  }) {
    return _pageMap(_nationalEntities, offset, limit);
  }

  static List<AppNotification> get notifications =>
      List<AppNotification>.unmodifiable(_notifications);

  static Map<String, dynamic> _pageMap(
    List<Map<String, dynamic>> records,
    int offset,
    int limit,
  ) {
    return {
      'total_records': records.length,
      'offset': offset,
      'limit': limit,
      'DATA': _page(
        records,
        offset,
        limit,
      ).map((item) => Map<String, dynamic>.from(item)).toList(),
    };
  }

  static List<T> _page<T>(List<T> records, int offset, int limit) {
    if (offset >= records.length || limit <= 0) {
      return <T>[];
    }

    final int end = offset + limit;
    final int safeEnd = end > records.length ? records.length : end;

    return records.sublist(offset, safeEnd);
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static final List<Individual> _individuals = [
    _individual(
      dataId: 900001,
      firstName: 'Ahmad',
      secondName: 'Bin Salem',
      thirdName: 'Al Tajribi',
      originalScriptName: 'أحمد بن سالم التجريبي',
      referenceNumber: 'QI.SAMPLE.001',
      unListType: 'Sample list',
      nationality: 'Sample nationality',
      designation: 'Demonstration record',
      comments:
          'Sample record for app review. This person is fictional and is not on a live sanctions list.',
      alias: 'Ahmad Sample',
      city: 'Manama',
      country: 'Bahrain',
      documentNumber: 'S-100001',
    ),
    _individual(
      dataId: 900002,
      firstName: 'Fatima',
      secondName: 'Ali',
      thirdName: 'Al Namuthajia',
      originalScriptName: 'فاطمة علي النموذجية',
      referenceNumber: 'QI.SAMPLE.002',
      unListType: 'Sample list',
      nationality: 'Sample nationality',
      designation: 'Demonstration record',
      comments:
          'Sample record for app review. This person is fictional and is not on a live sanctions list.',
      alias: 'Fatima Sample',
      city: 'Riffa',
      country: 'Bahrain',
      documentNumber: 'S-100002',
    ),
    _individual(
      dataId: 900003,
      firstName: 'Yousif',
      secondName: 'Hassan',
      thirdName: 'Al Ard',
      originalScriptName: 'يوسف حسن العرض',
      referenceNumber: 'QI.SAMPLE.003',
      unListType: 'Sample list',
      nationality: 'Sample nationality',
      designation: 'Demonstration record',
      comments:
          'Sample record for app review. This person is fictional and is not on a live sanctions list.',
      alias: 'Yousif Sample',
      city: 'Muharraq',
      country: 'Bahrain',
      documentNumber: 'S-100003',
    ),
  ];

  static Individual _individual({
    required int dataId,
    required String firstName,
    required String secondName,
    required String thirdName,
    required String originalScriptName,
    required String referenceNumber,
    required String unListType,
    required String nationality,
    required String designation,
    required String comments,
    required String alias,
    required String city,
    required String country,
    required String documentNumber,
  }) {
    return Individual(
      dataId: dataId,
      versionNumber: 1,
      firstName: firstName,
      secondName: secondName,
      thirdName: thirdName,
      fourthName: '',
      originalScriptName: originalScriptName,
      unListType: unListType,
      referenceNumber: referenceNumber,
      comments: comments,
      hasInterpolLink: '',
      interpolLink: '',
      sourceFileId: 0,
      createdDate: DateTime.utc(2026, 1, 15),
      lastUpdatedDate: DateTime.utc(2026, 6, 1),
      addresses: [
        IndividualAddress(
          sequence: 1,
          address: 'Sample Street 12',
          city: city,
          stateProvince: 'Capital',
          country: country,
          note: 'Demonstration address',
        ),
      ],
      aliases: [IndividualAlias(sequence: 1, quality: 'Good', name: alias)],
      datesOfBirth: [
        const IndividualDateOfBirth(
          sequence: 1,
          typeOfDate: 'Exact',
          dateValue: '1985-04-12',
          year: '1985',
          fromYear: '',
          toYear: '',
        ),
      ],
      documents: [
        IndividualDocument(
          sequence: 1,
          type: 'Passport',
          number: documentNumber,
          countryOfIssue: country,
          note: 'Sample document',
        ),
      ],
      placesOfBirth: [
        IndividualPlaceOfBirth(
          sequence: 1,
          city: city,
          stateProvince: 'Capital',
          country: country,
        ),
      ],
      attributes: [
        IndividualAttribute(
          name: 'NATIONALITY',
          valueSequence: 1,
          value: nationality,
        ),
        IndividualAttribute(
          name: 'DESIGNATION',
          valueSequence: 1,
          value: designation,
        ),
      ],
      rawData: const {},
    );
  }

  static final List<Map<String, dynamic>> _entities = [
    {
      'DATAID': 910001,
      'VERSIONNUM': 1,
      'FIRST_NAME': 'Sample Gulf Trading Co.',
      'NAME_ORIGINAL_SCRIPT': 'شركة الخليج النموذجية',
      'UN_LIST_TYPE': 'Sample list',
      'REFERENCE_NUMBER': 'QE.SAMPLE.001',
      'COMMENTS1':
          'Sample entity for app review. This organization is fictional and is not on a live sanctions list.',
      'CREATED_DATE': '2026-01-15',
      'LAST_UPDATED_DATE': '2026-06-01',
      'ALIASES': [
        {'ALIAS_SEQ': 1, 'ALIAS_NAME': 'Gulf Sample Co.', 'QUALITY': 'Good'},
      ],
      'ADDRESSES': [
        {
          'ADDR_SEQ': 1,
          'STREET': 'Sample Avenue 4',
          'CITY': 'Manama',
          'STATE_PROVINCE': 'Capital',
          'COUNTRY': 'Bahrain',
          'NOTE': 'Demonstration address',
        },
      ],
      'ATTR_VALUES': [
        {'ATTR_NAME': 'Type', 'ATTR_VALUE': 'Demonstration company'},
      ],
    },
    {
      'DATAID': 910002,
      'VERSIONNUM': 1,
      'FIRST_NAME': 'Al Noor Demonstration Foundation',
      'NAME_ORIGINAL_SCRIPT': 'مؤسسة النور التجريبية',
      'UN_LIST_TYPE': 'Sample list',
      'REFERENCE_NUMBER': 'QE.SAMPLE.002',
      'COMMENTS1':
          'Sample entity for app review. This organization is fictional and is not on a live sanctions list.',
      'CREATED_DATE': '2026-02-02',
      'LAST_UPDATED_DATE': '2026-07-10',
      'ALIASES': [
        {'ALIAS_SEQ': 1, 'ALIAS_NAME': 'Noor Sample', 'QUALITY': 'Low'},
      ],
      'ADDRESSES': [
        {
          'ADDR_SEQ': 1,
          'STREET': 'Review Road 8',
          'CITY': 'Isa Town',
          'STATE_PROVINCE': 'Southern',
          'COUNTRY': 'Bahrain',
          'NOTE': 'Demonstration address',
        },
      ],
      'ATTR_VALUES': [
        {'ATTR_NAME': 'Type', 'ATTR_VALUE': 'Demonstration foundation'},
      ],
    },
  ];

  static final List<Map<String, dynamic>> _nationalPersons = [
    {
      'ID': 'NP-9001',
      'LS': 'LS-01',
      'PERSON_NAME_IN_ARABIC': 'سالم محمد التجريبي',
      'PERSON_NAME_IN_ENGLISH': 'Salem Mohammed Al Tajribi',
      'RECORDED_NAME': 'Salem Mohammed Al Tajribi',
      'FIRST_NAME': 'Salem',
      'SECOND_NAME': 'Mohammed',
      'THIRD_NAME': 'Al Tajribi',
      'NATIONALITY': 'Sample nationality',
      'DATE_OF_BIRTH': '1990-08-20',
      'PLACE_OF_BIRTH': 'Manama',
      'GENDER': 'Male',
      'PASSPORT_NUMBER': 'P-9001001',
      'CPR_NUMBER': '900100001',
      'NICKNAME_OR_ALIAS': 'Salem Sample',
      'PRIORITY_LEVEL': 'Sample',
      'REASONING': 'Demonstration listing for app review.',
      'NOTES': 'Fictional person. Not retrieved from the live database.',
      'REQUEST_DATE': '2026-01-10',
      'CLASSIFICATION_DATE': '2026-01-12',
      'CREATED': '2026-01-10',
      'UPDATED': '2026-05-01',
    },
    {
      'ID': 'NP-9002',
      'LS': 'LS-02',
      'PERSON_NAME_IN_ARABIC': 'مريم عبدالله النموذجية',
      'PERSON_NAME_IN_ENGLISH': 'Mariam Abdulla Al Namuthajia',
      'RECORDED_NAME': 'Mariam Abdulla Al Namuthajia',
      'FIRST_NAME': 'Mariam',
      'SECOND_NAME': 'Abdulla',
      'THIRD_NAME': 'Al Namuthajia',
      'NATIONALITY': 'Sample nationality',
      'DATE_OF_BIRTH': '1988-11-03',
      'PLACE_OF_BIRTH': 'Muharraq',
      'GENDER': 'Female',
      'PASSPORT_NUMBER': 'P-9001002',
      'CPR_NUMBER': '900100002',
      'NICKNAME_OR_ALIAS': 'Mariam Sample',
      'PRIORITY_LEVEL': 'Sample',
      'REASONING': 'Demonstration listing for app review.',
      'NOTES': 'Fictional person. Not retrieved from the live database.',
      'REQUEST_DATE': '2026-02-14',
      'CLASSIFICATION_DATE': '2026-02-16',
      'CREATED': '2026-02-14',
      'UPDATED': '2026-06-18',
    },
  ];

  static final List<Map<String, dynamic>> _nationalEntities = [
    {
      'ID': 'NE-9101',
      'LS': 'LS-11',
      'ENTITY_NAME_IN_ARABIC': 'مؤسسة العرض الوطنية',
      'ENTITY_NAME_IN_ENGLISH': 'National Demonstration Office',
      'RECORDED_NAME': 'National Demonstration Office',
      'NICKNAME_OR_ALIAS': 'NDO Sample',
      'ENTITY_TYPE': 'Sample office',
      'LEGAL_STATUS': 'Demonstration',
      'ENTITY_DESCRIPTION':
          'Fictional national entity used only for app review.',
      'LEADERSHIP': 'Sample director',
      'ACTIVITY': 'Demonstration activity',
      'PRIORITY_LEVEL': 'Sample',
      'REASONING': 'Shown only to the Apple review account.',
      'NOTES': 'Not retrieved from the live database.',
      'REQUEST_DATE': '2026-03-01',
      'CLASSIFICATION_DATE': '2026-03-04',
      'CREATED': '2026-03-01',
      'UPDATED': '2026-07-01',
    },
    {
      'ID': 'NE-9102',
      'LS': 'LS-12',
      'ENTITY_NAME_IN_ARABIC': 'شركة النموذج البحرينية',
      'ENTITY_NAME_IN_ENGLISH': 'Bahrain Sample Company',
      'RECORDED_NAME': 'Bahrain Sample Company',
      'NICKNAME_OR_ALIAS': 'BSC Sample',
      'ENTITY_TYPE': 'Sample company',
      'LEGAL_STATUS': 'Demonstration',
      'ENTITY_DESCRIPTION':
          'Fictional national entity used only for app review.',
      'LEADERSHIP': 'Sample board',
      'ACTIVITY': 'Demonstration trade',
      'PRIORITY_LEVEL': 'Sample',
      'REASONING': 'Shown only to the Apple review account.',
      'NOTES': 'Not retrieved from the live database.',
      'REQUEST_DATE': '2026-04-09',
      'CLASSIFICATION_DATE': '2026-04-11',
      'CREATED': '2026-04-09',
      'UPDATED': '2026-08-20',
    },
  ];

  static final List<AppNotification> _notifications = [
    AppNotification(
      id: 'sample-1',
      title: 'Sample notice',
      message:
          'This notification is demonstration data for the Apple review account.',
      timestamp: DateTime.utc(2026, 9, 1, 8, 30),
      degree: NotificationDegree.medium,
    ),
    AppNotification(
      id: 'sample-2',
      title: 'Review lists ready',
      message:
          'United Nations and national lists on this account use sample records only.',
      timestamp: DateTime.utc(2026, 8, 15, 10, 0),
      degree: NotificationDegree.low,
    ),
  ];
}
