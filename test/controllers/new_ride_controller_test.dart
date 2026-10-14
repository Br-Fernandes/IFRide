import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:if_ride/controllers/new_ride_controller.dart';

void main() {
  group('DayRideConfig — formatação de horário', () {
    test('apiTime formata com segundos (HH:mm:00)', () {
      final day = DayRideConfig(dayName: 'Segunda', apiDayName: 'MONDAY');
      day.time.value = const TimeOfDay(hour: 8, minute: 0);
      expect(day.apiTime, equals('08:00:00'));
    });

    test('apiTime preenche zeros à esquerda em hora e minuto', () {
      final day = DayRideConfig(dayName: 'Terça', apiDayName: 'TUESDAY');
      day.time.value = const TimeOfDay(hour: 7, minute: 5);
      expect(day.apiTime, equals('07:05:00'));
    });

    test('apiTime funciona para horário da tarde', () {
      final day = DayRideConfig(dayName: 'Quarta', apiDayName: 'WEDNESDAY');
      day.time.value = const TimeOfDay(hour: 17, minute: 30);
      expect(day.apiTime, equals('17:30:00'));
    });

    test('formattedTime sem segundos para exibição', () {
      final day = DayRideConfig(dayName: 'Quinta', apiDayName: 'THURSDAY');
      day.time.value = const TimeOfDay(hour: 9, minute: 45);
      expect(day.formattedTime, equals('09:45'));
    });
  });

  group('DayRideConfig — controle de passageiros', () {
    test('valor inicial de passengerCount é 1', () {
      final day = DayRideConfig(dayName: 'Sexta', apiDayName: 'FRIDAY');
      expect(day.passengerCount.value, equals(1));
    });

    test('increment aumenta passengerCount', () {
      final day = DayRideConfig(dayName: 'Sexta', apiDayName: 'FRIDAY');
      day.increment();
      expect(day.passengerCount.value, equals(2));
    });

    test('decrement diminui passengerCount', () {
      final day = DayRideConfig(dayName: 'Sexta', apiDayName: 'FRIDAY');
      day.increment();
      day.increment();
      day.decrement();
      expect(day.passengerCount.value, equals(2));
    });

    test('não incrementa além de 6', () {
      final day = DayRideConfig(dayName: 'Sexta', apiDayName: 'FRIDAY');
      for (var i = 0; i < 10; i++) {
        day.increment();
      }
      expect(day.passengerCount.value, equals(6));
      expect(day.canIncrement, isFalse);
    });

    test('não decrementa abaixo de 1', () {
      final day = DayRideConfig(dayName: 'Sexta', apiDayName: 'FRIDAY');
      day.decrement();
      day.decrement();
      expect(day.passengerCount.value, equals(1));
      expect(day.canDecrement, isFalse);
    });

    test('canIncrement é true quando < 6', () {
      final day = DayRideConfig(dayName: 'Sexta', apiDayName: 'FRIDAY');
      expect(day.canIncrement, isTrue);
    });

    test('canDecrement é false quando = 1', () {
      final day = DayRideConfig(dayName: 'Sexta', apiDayName: 'FRIDAY');
      expect(day.canDecrement, isFalse);
    });
  });

  group('Conversão de data UTC — lógica do controller', () {
    // Testa a lógica exata que _submitSingleRide usa:
    // DateTime(date, time) → toUtc() → toIso8601String()

    test('data local convertida para UTC termina com Z', () {
      const hour = 14;
      const minute = 30;
      final date = DateTime(2026, 2, 20);
      final dt = DateTime(date.year, date.month, date.day, hour, minute);
      final result = dt.toUtc().toIso8601String();

      expect(result.endsWith('Z'), isTrue,
          reason: 'O backend (Instant) exige o sufixo Z');
    });

    test('data local e sua versão UTC representam o mesmo instante', () {
      final dt = DateTime(2026, 6, 15, 8, 0); // horário local
      final utc = dt.toUtc();
      expect(dt.millisecondsSinceEpoch, equals(utc.millisecondsSinceEpoch));
    });

    test('string UTC parseia de volta para o mesmo instante', () {
      final dt = DateTime(2026, 3, 10, 10, 0);
      final utcStr = dt.toUtc().toIso8601String();
      final parsed = DateTime.parse(utcStr);
      expect(parsed.millisecondsSinceEpoch, equals(dt.millisecondsSinceEpoch));
    });

    test('toLocal() em string UTC retorna horário não-UTC', () {
      // Simula o parse que RideResponse.fromJson faz
      final utcStr = '2026-02-20T17:30:00Z';
      final local = DateTime.parse(utcStr).toLocal();
      expect(local.isUtc, isFalse);
      expect(local.millisecondsSinceEpoch,
          equals(DateTime.parse(utcStr).millisecondsSinceEpoch));
    });
  });
}
