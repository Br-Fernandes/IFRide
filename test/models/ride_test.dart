import 'package:flutter_test/flutter_test.dart';
import 'package:if_ride/models/ride.dart';

// JSON mínimo reutilizável para evitar repetição
Map<String, dynamic> _rideJson({
  String id = 'ride-1',
  String? departureTime,
  String rideStatus = 'SCHEDULED',
  List<String> pickupPoints = const [],
}) =>
    {
      'id': id,
      'driver': {'id': 'driver-1', 'name': 'João', 'cnhCategory': 'B'},
      'vehicle': {
        'id': 'v-1',
        'model': 'Gol',
        'plate': 'ABC-1234',
        'color': 'Branco',
        'owner': {'id': 'driver-1', 'name': 'João', 'cnhCategory': 'B'},
      },
      'origin': 'Campinas',
      'destination': 'São Paulo',
      'pickupPoints': pickupPoints,
      'availableSeats': 3,
      'price': 15.0,
      if (departureTime != null) 'departureTime': departureTime,
      'rideStatus': rideStatus,
    };

void main() {
  group('RideResponse.fromJson — timezone', () {
    test('converte UTC para horário local', () {
      final ride = RideResponse.fromJson(
        _rideJson(departureTime: '2026-02-20T17:30:00Z'),
      );

      expect(ride.departureTime, isNotNull);
      // Deve ser local, não UTC
      expect(ride.departureTime!.isUtc, isFalse);
      // O instante subjacente deve ser preservado
      expect(
        ride.departureTime!.toUtc().toIso8601String(),
        equals('2026-02-20T17:30:00.000Z'),
      );
    });

    test('departureTime nulo para carona recorrente', () {
      final ride = RideResponse.fromJson(_rideJson());
      expect(ride.departureTime, isNull);
    });

    test('dois horários UTC diferentes resultam em instantes diferentes', () {
      final ride1 = RideResponse.fromJson(
          _rideJson(id: 'a', departureTime: '2026-02-20T17:30:00Z'));
      final ride2 = RideResponse.fromJson(
          _rideJson(id: 'b', departureTime: '2026-02-21T17:30:00Z'));

      expect(ride1.departureTime!.isBefore(ride2.departureTime!), isTrue);
    });
  });

  group('RideResponse.fromJson — campos', () {
    test('lê todos os campos básicos', () {
      final ride = RideResponse.fromJson(
        _rideJson(
          id: 'ride-abc',
          rideStatus: 'IN_PROGRESS',
          pickupPoints: ['Ponto A', 'Ponto B'],
        ),
      );

      expect(ride.id, equals('ride-abc'));
      expect(ride.origin, equals('Campinas'));
      expect(ride.destination, equals('São Paulo'));
      expect(ride.availableSeats, equals(3));
      expect(ride.price, equals(15.0));
      expect(ride.rideStatus, equals('IN_PROGRESS'));
      expect(ride.pickupPoints, equals(['Ponto A', 'Ponto B']));
    });

    test('todos os rideStatus possíveis são lidos corretamente', () {
      for (final status in [
        'SCHEDULED',
        'FULL',
        'IN_PROGRESS',
        'FINISHED',
        'CANCELLED',
      ]) {
        final ride = RideResponse.fromJson(_rideJson(rideStatus: status));
        expect(ride.rideStatus, equals(status),
            reason: 'status $status não foi lido corretamente');
      }
    });

    test('pickupPoints vazio não causa erro', () {
      final ride = RideResponse.fromJson(_rideJson(pickupPoints: []));
      expect(ride.pickupPoints, isEmpty);
    });

    test('campos ausentes usam defaults sem crash', () {
      final ride = RideResponse.fromJson(<String, dynamic>{
        'driver': <String, dynamic>{},
        'vehicle': <String, dynamic>{},
      });
      expect(ride.origin, equals(''));
      expect(ride.availableSeats, equals(0));
      expect(ride.price, equals(0.0));
    });
  });

  group('RideRequest.toJson — carona avulsa', () {
    test('inclui departureTime em UTC ISO-8601', () {
      final req = RideRequest(
        vehicleId: 'v-1',
        origin: 'Campinas',
        destination: 'São Paulo',
        pickupPoints: [],
        departureTime: '2026-02-20T17:30:00.000Z',
        availableSeats: 2,
        price: 15.0,
      );

      final json = req.toJson();
      expect(json['departureTime'], equals('2026-02-20T17:30:00.000Z'));
      expect(json['isRecurrent'], isFalse);
      expect(json.containsKey('recurrentDay'), isFalse);
      expect(json.containsKey('recurrencyDeparture'), isFalse);
    });

    test('formato UTC termina com Z', () {
      // Reproduz a lógica exata do controller: dt.toUtc().toIso8601String()
      final localTime = DateTime(2026, 2, 20, 14, 30); // horário local
      final utcStr = localTime.toUtc().toIso8601String();

      expect(utcStr.endsWith('Z'), isTrue,
          reason: 'backend exige Z no final para Instant');
      expect(utcStr, contains('T'));
    });
  });

  group('RideRequest.toJson — carona recorrente', () {
    test('omite departureTime e inclui campos de recorrência', () {
      final req = RideRequest(
        vehicleId: 'v-1',
        origin: 'Campinas',
        destination: 'São Paulo',
        pickupPoints: ['Terminal'],
        availableSeats: 3,
        price: 10.0,
        isRecurrent: true,
        recurrentDay: 'MONDAY',
        recurrencyDeparture: '08:00:00',
      );

      final json = req.toJson();
      expect(json.containsKey('departureTime'), isFalse,
          reason: 'caronas recorrentes não têm departureTime');
      expect(json['isRecurrent'], isTrue);
      expect(json['recurrentDay'], equals('MONDAY'));
      expect(json['recurrencyDeparture'], equals('08:00:00'));
    });

    test('pickupPoints são incluídos', () {
      final req = RideRequest(
        vehicleId: 'v-1',
        origin: 'A',
        destination: 'B',
        pickupPoints: ['P1', 'P2'],
        availableSeats: 2,
        price: 5.0,
        isRecurrent: true,
        recurrentDay: 'FRIDAY',
        recurrencyDeparture: '07:30:00',
      );

      expect(req.toJson()['pickupPoints'], equals(['P1', 'P2']));
    });
  });

  group('RideParticipantResponse.fromJson', () {
    test('mapeia passenger.name e passenger.id do objeto aninhado', () {
      final json = {
        'id': 'part-1',
        'ride': _rideJson(),
        'passenger': {'id': 'pass-1', 'name': 'Maria'},
        'status': 'PENDING',
        'requestedAt': '2026-02-20T14:00:00Z',
      };

      final p = RideParticipantResponse.fromJson(json);
      expect(p.passengerId, equals('pass-1'));
      expect(p.passengerName, equals('Maria'));
      expect(p.status, equals('PENDING'));
      expect(p.id, equals('part-1'));
    });

    test('status padrão PENDING quando campo ausente', () {
      final json = {
        'ride': _rideJson(),
        'passenger': {'id': 'p', 'name': 'Ana'},
        'requestedAt': '2026-02-20T14:00:00Z',
      };

      expect(RideParticipantResponse.fromJson(json).status, equals('PENDING'));
    });

    test('passenger ausente não causa crash', () {
      final json = {
        'ride': _rideJson(),
        'status': 'REJECTED',
        'requestedAt': '2026-02-20T14:00:00Z',
      };

      final p = RideParticipantResponse.fromJson(json);
      expect(p.passengerName, equals(''));
      expect(p.passengerId, equals(''));
    });
  });
}
