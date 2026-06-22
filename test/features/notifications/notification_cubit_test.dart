import 'package:bloc_test/bloc_test.dart';
import 'package:expense_tracker/features/notifications/domain/models/notification_model.dart';
import 'package:expense_tracker/features/notifications/domain/repositories/notification_repository.dart';
import 'package:expense_tracker/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late _MockNotificationRepository repo;

  NotificationModel makeNotification({
    required int id,
    bool isRead = false,
  }) =>
      NotificationModel(
        id: id,
        title: 'Test $id',
        message: 'Message $id',
        type: 'GENERAL',
        isRead: isRead,
        createdAt: '2024-01-01T10:00:00Z',
      );

  setUp(() => repo = _MockNotificationRepository());

  NotificationCubit build() => NotificationCubit(repo);

  group('load', () {
    blocTest<NotificationCubit, NotificationState>(
      'emits [Loading, Loaded] on success',
      build: build,
      setUp: () => when(() => repo.getNotifications())
          .thenAnswer((_) async => [makeNotification(id: 1)]),
      act: (c) => c.load(),
      expect: () => [isA<NotificationLoading>(), isA<NotificationLoaded>()],
    );

    blocTest<NotificationCubit, NotificationState>(
      'emits [Loading, Error] on failure',
      build: build,
      setUp: () =>
          when(() => repo.getNotifications()).thenThrow(Exception('Network')),
      act: (c) => c.load(),
      expect: () => [isA<NotificationLoading>(), isA<NotificationError>()],
    );
  });

  group('markRead', () {
    blocTest<NotificationCubit, NotificationState>(
      'optimistically marks notification as read',
      build: build,
      seed: () => NotificationLoaded([
        makeNotification(id: 1, isRead: false),
        makeNotification(id: 2, isRead: false),
      ]),
      setUp: () => when(() => repo.markRead(1)).thenAnswer((_) async {}),
      act: (c) => c.markRead(1),
      expect: () => [isA<NotificationLoaded>()],
      verify: (c) {
        final loaded = c.state as NotificationLoaded;
        expect(loaded.notifications.firstWhere((n) => n.id == 1).isRead, true);
        expect(loaded.notifications.firstWhere((n) => n.id == 2).isRead, false);
      },
    );

    blocTest<NotificationCubit, NotificationState>(
      'reverts optimistic update on API failure',
      build: build,
      seed: () => NotificationLoaded([makeNotification(id: 1, isRead: false)]),
      setUp: () =>
          when(() => repo.markRead(1)).thenThrow(Exception('Failed')),
      act: (c) => c.markRead(1),
      expect: () => [
        isA<NotificationLoaded>(), // optimistic (isRead=true)
        isA<NotificationLoaded>(), // reverted (isRead=false)
      ],
      verify: (c) {
        expect((c.state as NotificationLoaded).notifications.first.isRead, false);
      },
    );
  });

  group('markAllRead', () {
    blocTest<NotificationCubit, NotificationState>(
      'marks all notifications as read',
      build: build,
      seed: () => NotificationLoaded([
        makeNotification(id: 1),
        makeNotification(id: 2),
      ]),
      setUp: () => when(() => repo.markAllRead()).thenAnswer((_) async {}),
      act: (c) => c.markAllRead(),
      expect: () => [isA<NotificationLoaded>()],
      verify: (c) {
        final loaded = c.state as NotificationLoaded;
        expect(loaded.notifications.every((n) => n.isRead), true);
      },
    );
  });

  group('unreadCount', () {
    test('returns correct unread count', () {
      final state = NotificationLoaded([
        makeNotification(id: 1, isRead: false),
        makeNotification(id: 2, isRead: true),
        makeNotification(id: 3, isRead: false),
      ]);
      expect(state.notifications.where((n) => !n.isRead).length, 2);
    });
  });
}