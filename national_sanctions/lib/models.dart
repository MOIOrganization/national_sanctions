class IndividualResponse {
  final int totalRecords;
  final int offset;
  final int limit;
  final List<Individual> individuals;

  const IndividualResponse({
    required this.totalRecords,
    required this.offset,
    required this.limit,
    required this.individuals,
  });

  factory IndividualResponse.fromJson(Map<String, dynamic> json) {
    final data = json['DATA'];

    return IndividualResponse(
      totalRecords: _toInt(json['total_records']),
      offset: _toInt(json['offset']),
      limit: _toInt(json['limit']),
      individuals: data is List
          ? data
                .whereType<Map>()
                .map(
                  (item) =>
                      Individual.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
          : [],
    );
  }
}

class Individual {
  final int dataId;
  final int versionNumber;

  final String firstName;
  final String secondName;
  final String thirdName;
  final String fourthName;

  final String unListType;
  final String referenceNumber;
  final String comments;
  final String hasInterpolLink;

  final int sourceFileId;
  final DateTime? createdDate;
  final DateTime? lastUpdatedDate;

  final List<IndividualAddress> addresses;
  final List<IndividualAlias> aliases;
  final List<IndividualDateOfBirth> datesOfBirth;
  final List<IndividualDocument> documents;
  final List<IndividualPlaceOfBirth> placesOfBirth;
  final List<IndividualAttribute> attributes;

  const Individual({
    required this.dataId,
    required this.versionNumber,
    required this.firstName,
    required this.secondName,
    required this.thirdName,
    required this.fourthName,
    required this.unListType,
    required this.referenceNumber,
    required this.comments,
    required this.hasInterpolLink,
    required this.sourceFileId,
    required this.createdDate,
    required this.lastUpdatedDate,
    required this.addresses,
    required this.aliases,
    required this.datesOfBirth,
    required this.documents,
    required this.placesOfBirth,
    required this.attributes,
  });

  String get fullName {
    return [
      firstName,
      secondName,
      thirdName,
      fourthName,
    ].where((name) => name.trim().isNotEmpty).join(' ');
  }

  List<String> get designations {
    return attributes
        .where(
          (attribute) =>
              attribute.name.toUpperCase() == 'DESIGNATION' &&
              attribute.value.trim().isNotEmpty,
        )
        .map((attribute) => attribute.value)
        .toList();
  }

  String get nationality {
    for (final attribute in attributes) {
      if (attribute.name.toUpperCase() == 'NATIONALITY') {
        return attribute.value;
      }
    }

    return '';
  }

  factory Individual.fromJson(Map<String, dynamic> json) {
    return Individual(
      dataId: _toInt(json['DATAID']),
      versionNumber: _toInt(json['VERSIONNUM']),
      firstName: _toText(json['FIRST_NAME']),
      secondName: _toText(json['SECOND_NAME']),
      thirdName: _toText(json['THIRD_NAME']),
      fourthName: _toText(json['FOURTH_NAME']),
      unListType: _toText(json['UN_LIST_TYPE']),
      referenceNumber: _toText(json['REFERENCE_NUMBER']),
      comments: _toText(json['COMMENTS1']),
      hasInterpolLink: _toText(json['HAS_INTERPOL_LINK']),
      sourceFileId: _toInt(json['SOURCE_FILE_ID']),
      createdDate: _toDateTime(json['CREATED_DATE']),
      lastUpdatedDate: _toDateTime(json['LAST_UPDATED_DATE']),
      addresses: _parseList(json['ADDRESSES'], IndividualAddress.fromJson),
      aliases: _parseList(json['ALIASES'], IndividualAlias.fromJson),
      datesOfBirth: _parseList(json['DOBS'], IndividualDateOfBirth.fromJson),
      documents: _parseList(json['DOCUMENTS'], IndividualDocument.fromJson),
      placesOfBirth: _parseList(json['POBS'], IndividualPlaceOfBirth.fromJson),
      attributes: _parseList(json['ATTR_VALUES'], IndividualAttribute.fromJson),
    );
  }
}

class IndividualAddress {
  final int sequence;
  final String address;
  final String city;
  final String stateProvince;
  final String country;
  final String note;

  const IndividualAddress({
    required this.sequence,
    required this.address,
    required this.city,
    required this.stateProvince,
    required this.country,
    required this.note,
  });

  factory IndividualAddress.fromJson(Map<String, dynamic> json) {
    return IndividualAddress(
      sequence: _toInt(json['ADDR_SEQ']),
      address: _toText(json['ADDRESS']),
      city: _toText(json['CITY']),
      stateProvince: _toText(json['STATE_PROVINCE']),
      country: _toText(json['COUNTRY']),
      note: _toText(json['NOTE']),
    );
  }
}

class IndividualAlias {
  final int sequence;
  final String quality;
  final String name;

  const IndividualAlias({
    required this.sequence,
    required this.quality,
    required this.name,
  });

  factory IndividualAlias.fromJson(Map<String, dynamic> json) {
    return IndividualAlias(
      sequence: _toInt(json['ALIAS_SEQ']),
      quality: _toText(json['QUALITY']),
      name: _toText(json['ALIAS_NAME']),
    );
  }
}

class IndividualDateOfBirth {
  final int sequence;
  final String typeOfDate;
  final String dateValue;
  final String year;
  final String fromYear;
  final String toYear;

  const IndividualDateOfBirth({
    required this.sequence,
    required this.typeOfDate,
    required this.dateValue,
    required this.year,
    required this.fromYear,
    required this.toYear,
  });

  String get displayValue {
    if (dateValue.isNotEmpty) return dateValue;
    if (year.isNotEmpty) return year;

    if (fromYear.isNotEmpty || toYear.isNotEmpty) {
      return '$fromYear - $toYear';
    }

    return '';
  }

  factory IndividualDateOfBirth.fromJson(Map<String, dynamic> json) {
    return IndividualDateOfBirth(
      sequence: _toInt(json['DOB_SEQ']),
      typeOfDate: _toText(json['TYPE_OF_DATE']),
      dateValue: _toText(json['DATE_VAL']),
      year: _toText(json['YEAR']),
      fromYear: _toText(json['FROM_YEAR']),
      toYear: _toText(json['TO_YEAR']),
    );
  }
}

class IndividualDocument {
  final int sequence;
  final String type;
  final String number;
  final String countryOfIssue;
  final String note;

  const IndividualDocument({
    required this.sequence,
    required this.type,
    required this.number,
    required this.countryOfIssue,
    required this.note,
  });

  factory IndividualDocument.fromJson(Map<String, dynamic> json) {
    return IndividualDocument(
      sequence: _toInt(json['DOC_SEQ']),
      type: _toText(json['TYPE_OF_DOCUMENT']),
      number: _toText(json['DOC_NUMBER']),
      countryOfIssue: _toText(json['COUNTRY_OF_ISSUE']),
      note: _toText(json['NOTE']),
    );
  }
}

class IndividualPlaceOfBirth {
  final int sequence;
  final String city;
  final String stateProvince;
  final String country;

  const IndividualPlaceOfBirth({
    required this.sequence,
    required this.city,
    required this.stateProvince,
    required this.country,
  });

  factory IndividualPlaceOfBirth.fromJson(Map<String, dynamic> json) {
    return IndividualPlaceOfBirth(
      sequence: _toInt(json['POB_SEQ']),
      city: _toText(json['CITY']),
      stateProvince: _toText(json['STATE_PROVINCE']),
      country: _toText(json['COUNTRY']),
    );
  }
}

class IndividualAttribute {
  final String name;
  final int valueSequence;
  final String value;

  const IndividualAttribute({
    required this.name,
    required this.valueSequence,
    required this.value,
  });

  factory IndividualAttribute.fromJson(Map<String, dynamic> json) {
    return IndividualAttribute(
      name: _toText(json['ATTR_NAME']),
      valueSequence: _toInt(json['VALUE_SEQ']),
      value: _toText(json['ATTR_VALUE']),
    );
  }
}

List<T> _parseList<T>(dynamic source, T Function(Map<String, dynamic>) parser) {
  if (source is! List) {
    return [];
  }

  return source
      .whereType<Map>()
      .map((item) => parser(Map<String, dynamic>.from(item)))
      .toList();
}

String _toText(dynamic value) {
  return value?.toString().trim() ?? '';
}

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }

  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _toDateTime(dynamic value) {
  final text = value?.toString();

  if (text == null || text.trim().isEmpty) {
    return null;
  }

  return DateTime.tryParse(text);
}
