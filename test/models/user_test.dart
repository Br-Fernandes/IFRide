import 'package:flutter_test/flutter_test.dart';
import 'package:if_ride/models/user.dart';

void main() {
  group('User.fromJson', () {
    test('lê todos os campos', () {
      final user = User.fromJson({
        'id': 'u-1',
        'name': 'Bruno',
        'email': 'bruno@ifsp.edu.br',
        'role': 'DRIVER',
        'imageUrl': 'https://example.com/photo.jpg',
        'city': 'Campinas',
      });

      expect(user.id, equals('u-1'));
      expect(user.name, equals('Bruno'));
      expect(user.email, equals('bruno@ifsp.edu.br'));
      expect(user.role, equals('DRIVER'));
      expect(user.imageUrl, equals('https://example.com/photo.jpg'));
      expect(user.city, equals('Campinas'));
    });

    test('campos ausentes usam defaults', () {
      final user = User.fromJson({});
      expect(user.id, equals(''));
      expect(user.role, equals('PASSENGER'));
      expect(user.imageUrl, isNull);
      expect(user.city, isNull);
    });
  });

  group('User.isDriver', () {
    test('DRIVER é motorista', () {
      final user = User(id: '', name: '', email: '', role: 'DRIVER');
      expect(user.isDriver, isTrue);
    });

    test('ADMIN também é considerado motorista (acesso às funcionalidades)', () {
      final user = User(id: '', name: '', email: '', role: 'ADMIN');
      expect(user.isDriver, isTrue);
    });

    test('PASSENGER não é motorista', () {
      final user = User(id: '', name: '', email: '', role: 'PASSENGER');
      expect(user.isDriver, isFalse);
    });
  });

  group('User.isAdmin', () {
    test('ADMIN é admin', () {
      final user = User(id: '', name: '', email: '', role: 'ADMIN');
      expect(user.isAdmin, isTrue);
    });

    test('DRIVER não é admin', () {
      final user = User(id: '', name: '', email: '', role: 'DRIVER');
      expect(user.isAdmin, isFalse);
    });

    test('PASSENGER não é admin', () {
      final user = User(id: '', name: '', email: '', role: 'PASSENGER');
      expect(user.isAdmin, isFalse);
    });

    test('role vazio não é admin', () {
      final user = User(id: '', name: '', email: '', role: '');
      expect(user.isAdmin, isFalse);
      expect(user.isDriver, isFalse);
    });
  });
}
