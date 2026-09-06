import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'session_controller.dart';

/// Resets the signed-in idle timer on pointer and key activity, checks
/// elapsed time when the app resumes, and clears pushed routes on sign-out.
class IdleSessionGuard extends StatefulWidget {
  const IdleSessionGuard({
    super.key,
    required this.navigatorKey,
    required this.child,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  State<IdleSessionGuard> createState() => _IdleSessionGuardState();
}

class _IdleSessionGuardState extends State<IdleSessionGuard>
    with WidgetsBindingObserver {
  SessionController? _session;
  bool _wasSignedIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    HardwareKeyboard.instance.addHandler(_onKeyEvent);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final SessionController session = SessionScope.read(context);

    if (identical(session, _session)) {
      return;
    }

    _session?.removeListener(_onSessionChanged);
    _session = session;
    _wasSignedIn = session.isSignedIn;
    session.addListener(_onSessionChanged);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKeyEvent);
    WidgetsBinding.instance.removeObserver(this);
    _session?.removeListener(_onSessionChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _session?.checkIdleTimeout();
    }
  }

  bool _onKeyEvent(KeyEvent event) {
    _session?.recordActivity();
    return false;
  }

  void _onSessionChanged() {
    final bool signedIn = _session?.isSignedIn ?? false;

    if (_wasSignedIn && !signedIn) {
      widget.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }

    _wasSignedIn = signedIn;
  }

  void _onPointerActivity(PointerEvent event) {
    _session?.recordActivity();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerActivity,
      onPointerMove: _onPointerActivity,
      onPointerSignal: _onPointerActivity,
      child: widget.child,
    );
  }
}
