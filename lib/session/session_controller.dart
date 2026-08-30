import 'package:flutter/material.dart';

import '../models/app_notification.dart';

class SessionController extends ChangeNotifier {
  String? _cpr;
  String? _userId;
  bool _biometricEnabled = false;
  List<AppNotification> _notifications = const [];

  String? get cpr => _cpr;

  String? get userId => _userId;

  List<AppNotification> get notifications => _notifications;

  int get unreadCount => _notifications.length;

  bool get biometricEnabled => _biometricEnabled;

  bool get isSignedIn => _cpr != null && _cpr!.trim().isNotEmpty;

  void setSignedIn({
    required String cpr,
    String? userId,
    List<AppNotification> notifications = const [],
  }) {
    _cpr = cpr.trim();
    _userId = userId?.trim();
    _notifications = List<AppNotification>.unmodifiable(notifications);
    notifyListeners();
  }

  void setNotifications(List<AppNotification> notifications) {
    _notifications = List<AppNotification>.unmodifiable(notifications);
    notifyListeners();
  }

  /// UI preference only. This does not enable device biometrics
  /// or store login credentials.
  void setBiometricEnabled(bool enabled) {
    if (_biometricEnabled == enabled) {
      return;
    }

    _biometricEnabled = enabled;
    notifyListeners();
  }

  /// Placeholder for future `local_auth` integration.
  /// Always returns false until device biometrics are connected.
  Future<bool> authenticateForLogin() async {
    if (!_biometricEnabled) {
      return false;
    }

    return false;
  }

  void signOut() {
    if (_cpr == null && _userId == null) {
      return;
    }

    _cpr = null;
    _userId = null;
    _notifications = const [];
    notifyListeners();
  }
}

class SessionScope extends InheritedNotifier<SessionController> {
  const SessionScope({
    super.key,
    required SessionController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Registers [context] as a dependent. Use from widgets that must
  /// rebuild when the session changes (for example the auth gate).
  static SessionController of(BuildContext context) {
    final SessionScope? scope = context
        .dependOnInheritedWidgetOfExactType<SessionScope>();

    assert(scope != null, 'SessionScope is missing from the widget tree.');

    return scope!.notifier!;
  }

  /// Reads the session without registering a dependency.
  /// Use from event handlers so the calling widget is not rebuilt
  /// when the session changes during navigation.
  static SessionController read(BuildContext context) {
    final SessionScope? scope = context
        .getInheritedWidgetOfExactType<SessionScope>();

    assert(scope != null, 'SessionScope is missing from the widget tree.');

    return scope!.notifier!;
  }
}
