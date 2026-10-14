import 'package:flutter_test/flutter_test.dart';
import 'package:if_ride/models/driver_application.dart';

void main() {
  group('DriverApplicationSummary.fromJson', () {
    test('lê id do campo raiz', () {
      final summary = DriverApplicationSummary.fromJson({
        'id': 'app-123',
        'requester': {'id': 'user-1'},
        'applicationStatus': 'PENDING',
        'cnhNumber': '12345678900',
        'cnhCategory': 'B',
        'cnhExpiration': '2030-01-01',
      });

      expect(summary.id, equals('app-123'));
    });

    test('lê requesterId do objeto requester aninhado', () {
      final summary = DriverApplicationSummary.fromJson({
        'id': 'app-1',
        'requester': {'id': 'user-42'},
        'applicationStatus': 'PENDING',
        'cnhNumber': '111',
        'cnhCategory': 'B',
        'cnhExpiration': '2030-01-01',
      });

      expect(summary.requesterId, equals('user-42'));
    });

    test('todos os status possíveis são lidos corretamente', () {
      for (final status in ['PENDING', 'APPROVED', 'DENIED']) {
        final summary = DriverApplicationSummary.fromJson({
          'id': 'app-1',
          'requester': {'id': 'u-1'},
          'applicationStatus': status,
          'cnhNumber': '1',
          'cnhCategory': 'B',
          'cnhExpiration': '2030-01-01',
        });
        expect(summary.applicationStatus, equals(status),
            reason: 'status $status não lido corretamente');
      }
    });

    test('rejectionReason é nulo quando ausente', () {
      final summary = DriverApplicationSummary.fromJson({
        'id': 'app-1',
        'requester': {'id': 'u-1'},
        'applicationStatus': 'PENDING',
        'cnhNumber': '1',
        'cnhCategory': 'B',
        'cnhExpiration': '2030-01-01',
      });

      expect(summary.rejectionReason, isNull);
    });

    test('rejectionReason presente quando DENIED com motivo', () {
      final summary = DriverApplicationSummary.fromJson({
        'id': 'app-2',
        'requester': {'id': 'u-2'},
        'applicationStatus': 'DENIED',
        'cnhNumber': '1',
        'cnhCategory': 'B',
        'cnhExpiration': '2030-01-01',
        'rejectionReason': 'CNH vencida',
      });

      expect(summary.rejectionReason, equals('CNH vencida'));
    });

    test('requester ausente não causa crash', () {
      final summary = DriverApplicationSummary.fromJson({
        'id': 'app-3',
        'applicationStatus': 'PENDING',
        'cnhNumber': '1',
        'cnhCategory': 'B',
        'cnhExpiration': '2030-01-01',
      });

      expect(summary.requesterId, equals(''));
    });

    test('id ausente retorna string vazia', () {
      final summary = DriverApplicationSummary.fromJson({
        'requester': {'id': 'u-1'},
        'applicationStatus': 'PENDING',
        'cnhNumber': '1',
        'cnhCategory': 'B',
        'cnhExpiration': '2030-01-01',
      });

      expect(summary.id, equals(''));
    });
  });

  group('DriverApplicationRequest.toJson', () {
    test('serializa todos os campos corretamente', () {
      final req = DriverApplicationRequest(
        requesterId: 'user-1',
        cnhNumber: '12345678900',
        cnhCategory: 'B',
        expiration: '2030-12-31',
      );

      final json = req.toJson();
      expect(json['requesterId'], equals('user-1'));
      expect(json['cnhNumber'], equals('12345678900'));
      expect(json['cnhCategory'], equals('B'));
      expect(json['expiration'], equals('2030-12-31'));
    });
  });
}
