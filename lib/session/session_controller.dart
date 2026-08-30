import 'package:flutter/material.dart';

class SessionController extends ChangeNotifier {
  String? _cpr;
  bool _biometricEnabled = false;

  String? get cpr => _cpr;

  bool get biometricEnabled => _biometricEnabled;

  bool get isSignedIn => _cpr != null && _cpr!.trim().isNotEmpty;

  void setSignedInCpr(String cpr) {
    _cpr = cpr.trim();
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
    if (_cpr == null) {
      return;
    }

    _cpr = null;
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
