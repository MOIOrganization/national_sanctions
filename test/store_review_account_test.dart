import 'package:flutter_test/flutter_test.dart';
import 'package:sanctions/session/store_review_account.dart';
import 'package:sanctions/session/store_review_sample_data.dart';

void main() {
  test('matches the Apple review credentials exactly', () {
    expect(
      StoreReviewAccount.matches(
        cpr: '900112233',
        expiry: '31/12/2030',
        block: '412',
        phone: '33001122',
      ),
      isTrue,
    );
  });

  test('rejects any field that does not match', () {
    expect(
      StoreReviewAccount.matches(
        cpr: '900112233',
        expiry: '31/12/2030',
        block: '412',
        phone: '00000000',
      ),
      isFalse,
    );
  });

  test('recognizes only the review user id', () {
    expect(StoreReviewAccount.isReviewUser('store-review'), isTrue);
    expect(StoreReviewAccount.isReviewUser('  store-review  '), isTrue);
    expect(StoreReviewAccount.isReviewUser('4821'), isFalse);
  });

  test('sample lists stay on the review account and page correctly', () {
    final individuals = StoreReviewSampleData.individualsPage(
      offset: 0,
      limit: 50,
    );

    expect(individuals.individuals, isNotEmpty);
    expect(individuals.totalRecords, individuals.individuals.length);
    expect(
      StoreReviewSampleData.individualsPage(offset: 50, limit: 50).individuals,
      isEmpty,
    );
    expect(
      StoreReviewSampleData.individualById(900001)?.referenceNumber,
      'QI.SAMPLE.001',
    );
    expect(StoreReviewSampleData.individualById(1), isNull);

    final entities = StoreReviewSampleData.entitiesPage(offset: 0, limit: 50);
    expect((entities['DATA'] as List), isNotEmpty);
    expect(
      StoreReviewSampleData.entityById(910001)?['REFERENCE_NUMBER'],
      'QE.SAMPLE.001',
    );
    expect(StoreReviewSampleData.entityById(1), isNull);

    expect(
      (StoreReviewSampleData.nationalPersonsPage(offset: 0, limit: 50)['DATA']
              as List)
          .length,
      2,
    );
    expect(
      (StoreReviewSampleData.nationalEntitiesPage(offset: 0, limit: 50)['DATA']
              as List)
          .length,
      2,
    );
    expect(StoreReviewSampleData.notifications, isNotEmpty);
  });
}
