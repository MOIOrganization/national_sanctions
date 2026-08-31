import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../models/app_notification.dart';
import '../services/sanctions_service.dart';
import '../session/session_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/app_alert.dart';
import '../widgets/language_toggle.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final SanctionsService _service = SanctionsService();

  final TextEditingController _cprController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _blockController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoggingIn = false;
  String? _formError;

  // ============================================================
  // SELECT CPR EXPIRY DATE
  // ============================================================

  Future<void> _selectExpiryDate() async {
    if (_isLoggingIn) {
      return;
    }

    final DateTime now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 15),
    );

    if (picked == null || !mounted) {
      return;
    }

    final String day = picked.day.toString().padLeft(2, '0');
    final String month = picked.month.toString().padLeft(2, '0');
    final String year = picked.year.toString();

    setState(() {
      _expiryController.text = '$day/$month/$year';
      _formError = null;
    });
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _continue() async {
    if (_isLoggingIn) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _formError = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoggingIn = true;
    });

    try {
      final Map<String, dynamic> response = await _service.login(
        cpr: _cprController.text.trim(),
        blockNo: _blockController.text.trim(),
        expireDate: _expiryController.text.trim().replaceAll('/', ''),
        phone: _phoneController.text.trim(),
      );

      debugPrint('[LOGIN PAGE] mob_un_login response: $response');

      if (!mounted) {
        return;
      }

      await _completeSignIn(response);
    } on SanctionsApiException catch (error) {
      debugPrint('[LOGIN PAGE] mob_un_login error: $error');

      if (!mounted) {
        return;
      }

      setState(() {
        _formError = error.message;
      });
    } catch (error) {
      debugPrint('[LOGIN PAGE] mob_un_login unexpected error: $error');

      if (!mounted) {
        return;
      }

      setState(() {
        _formError = AppLocalizations.of(context).unableToLogin;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
  }

  Future<void> _onBiometricLoginPressed() async {
    final SessionController session = SessionScope.read(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (!session.biometricEnabled) {
      await showAppAlert(
        context: context,
        title: l10n.biometricNotEnabledTitle,
        message: l10n.biometricNotEnabledMessage,
      );
      return;
    }

    await session.authenticateForLogin();
  }

  Future<void> _completeSignIn(Map<String, dynamic> loginResponse) async {
    final String phone = _phoneController.text.trim();
    final String cpr = _cprController.text.trim();
    final String? userId = SanctionsService.userIdFromLogin(loginResponse);

    debugPrint('[LOGIN PAGE] login user_id: $userId');

    if (userId == null || userId.isEmpty) {
      setState(() {
        _formError = AppLocalizations.of(context).unableToLogin;
      });
      return;
    }

    final bool? verified = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _OtpVerificationDialog(
          phone: phone,
          userId: userId,
          service: _service,
        );
      },
    );

    if (!mounted || verified != true) {
      return;
    }

    List<AppNotification> notifications = const [];

    try {
      notifications = await _service.getUserNotifications(userId: userId);
    } catch (error) {
      debugPrint('[LOGIN PAGE] bl_get_user_notifications error: $error');
    }

    if (!mounted) {
      return;
    }

    SessionScope.read(context).setSignedIn(
      cpr: cpr,
      userId: userId,
      notifications: notifications,
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _cprController.dispose();
    _expiryController.dispose();
    _blockController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  // ============================================================
  // PAGE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'asset/images/background.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.55)),
          ),
          SafeArea(
            child: Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      22,
                      48,
                      22,
                      AppSpacing.xl,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        children: [
                          Container(
                            width: 350,
                            height: 350,
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppRadius.hero,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.20),
                                  blurRadius: 18,
                                  offset: const Offset(0, 7),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'asset/images/logo.png',
                              fit: BoxFit.contain,
                              alignment: Alignment.bottomCenter,
                            ),
                          ),
                          // Text(
                          //   l10n.appTitle,
                          //   textAlign: TextAlign.center,
                          //   style: const TextStyle(
                          //     color: Colors.white,
                          //     fontSize: 27,
                          //     fontWeight: FontWeight.bold,
                          //     height: 1,
                          //   ),
                          // ),
                          // const SizedBox(height: 4),
                          // Text(
                          //   l10n.loginSubtitle,
                          //   textAlign: TextAlign.center,
                          //   style: const TextStyle(
                          //     color: Colors.white70,
                          //     fontSize: 14,
                          //     height: 1.5,
                          //   ),
                          // ),
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.96),
                              borderRadius: BorderRadius.circular(
                                AppRadius.hero,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.20),
                                  blurRadius: 22,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.login,
                                    style: AppTextStyles.heading.copyWith(
                                      fontSize: 21,
                                      height: 28 / 21,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    l10n.loginCardHint,
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.muted,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  TextFormField(
                                    controller: _cprController,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                    textDirection: TextDirection.ltr,
                                    maxLength: 9,
                                    enabled: !_isLoggingIn,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    onChanged: (_) {
                                      if (_formError != null) {
                                        setState(() {
                                          _formError = null;
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                      labelText: l10n.cprNumber,
                                      hintText: l10n.enterCpr,
                                      prefixIcon: const Icon(
                                        Icons.badge_outlined,
                                      ),
                                      counterText: '',
                                    ),
                                    validator: (value) {
                                      final String text = value?.trim() ?? '';

                                      if (text.isEmpty) {
                                        return l10n.cprRequired;
                                      }

                                      if (text.length != 9) {
                                        return l10n.cprMustBe9;
                                      }

                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  TextFormField(
                                    controller: _expiryController,
                                    readOnly: true,
                                    enabled: !_isLoggingIn,
                                    textDirection: TextDirection.ltr,
                                    onTap: _selectExpiryDate,
                                    decoration: InputDecoration(
                                      labelText: l10n.cprExpiry,
                                      hintText: 'DD/MM/YYYY',
                                      prefixIcon: const Icon(
                                        Icons.calendar_month_outlined,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return l10n.selectExpiry;
                                      }

                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  TextFormField(
                                    controller: _blockController,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                    textDirection: TextDirection.ltr,
                                    maxLength: 4,
                                    enabled: !_isLoggingIn,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    onChanged: (_) {
                                      if (_formError != null) {
                                        setState(() {
                                          _formError = null;
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                      labelText: l10n.blockNumber,
                                      hintText: l10n.enterBlock,
                                      prefixIcon: const Icon(
                                        Icons.location_on_outlined,
                                      ),
                                      counterText: '',
                                    ),
                                    validator: (value) {
                                      final String text = value?.trim() ?? '';

                                      if (text.isEmpty) {
                                        return l10n.blockRequired;
                                      }

                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.done,
                                    textDirection: TextDirection.ltr,
                                    enabled: !_isLoggingIn,
                                    maxLength: 8,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    onFieldSubmitted: (_) => _continue(),
                                    onChanged: (_) {
                                      if (_formError != null) {
                                        setState(() {
                                          _formError = null;
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                      labelText: l10n.mobileNumber,
                                      hintText: l10n.enterMobile,
                                      prefixIcon: const Icon(
                                        Icons.phone_outlined,
                                      ),
                                      prefixText: '+973 ',
                                      counterText: '',
                                    ),
                                    validator: (value) {
                                      final String text = value?.trim() ?? '';

                                      if (text.isEmpty) {
                                        return l10n.mobileRequired;
                                      }

                                      if (text.length != 8) {
                                        return l10n.mobileMustBe8;
                                      }

                                      return null;
                                    },
                                  ),
                                  if (_formError != null) ...[
                                    const SizedBox(height: AppSpacing.lg),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(
                                        AppSpacing.md,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.error.withValues(
                                          alpha: 0.08,
                                        ),
                                        borderRadius: AppRadius.border,
                                        border: Border.all(
                                          color: AppColors.error.withValues(
                                            alpha: 0.35,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.error_outline,
                                            color: AppColors.error,
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Expanded(
                                            child: Text(
                                              _formError!,
                                              style: AppTextStyles.body
                                                  .copyWith(
                                                    color: AppColors.error,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: FilledButton(
                                      onPressed: _isLoggingIn
                                          ? null
                                          : _continue,
                                      child: _isLoggingIn
                                          ? const SizedBox(
                                              height: 22,
                                              width: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Text(l10n.login),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: OutlinedButton(
                                      onPressed: _isLoggingIn
                                          ? null
                                          : _onBiometricLoginPressed,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.fingerprint,
                                            size: 20,
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Flexible(
                                            child: Text(
                                              l10n.biometricLogin,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ),
                ),
                const Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: LanguageToggleButton(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpVerificationDialog extends StatefulWidget {
  const _OtpVerificationDialog({
    required this.phone,
    required this.userId,
    required this.service,
  });

  final String phone;
  final String userId;
  final SanctionsService service;

  @override
  State<_OtpVerificationDialog> createState() =>
      _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<_OtpVerificationDialog> {
  final TextEditingController _otpController = TextEditingController();
  bool _isVerifying = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_isVerifying) {
      return;
    }

    final AppLocalizations l10n = AppLocalizations.of(context);
    final String otp = _otpController.text.trim();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterSixDigitOtp)),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      await widget.service.verifyOtp(userId: widget.userId, otp: otp);

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } on SanctionsApiException catch (error) {
      debugPrint('[OTP] un_chk_valid_otp error: $error');

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      debugPrint('[OTP] un_chk_valid_otp unexpected error: $error');

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.unableToVerifyOtp)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final double maxContentWidth =
        (MediaQuery.sizeOf(context).width - 56).clamp(200, 360);

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(22, 22, 12, 0),
      contentPadding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
      actionsPadding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
      title: Row(
        children: [
          Expanded(
            child: Text(
              l10n.otpVerification,
              style: AppTextStyles.heading,
            ),
          ),
          IconButton(
            onPressed: _isVerifying ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.phone_android_outlined,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.enterOtpSentTo(widget.phone),
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _otpController,
              enabled: !_isVerifying,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                fontSize: maxContentWidth < 280 ? 20 : 24,
                fontWeight: FontWeight.bold,
                letterSpacing: maxContentWidth < 280 ? 4 : 8,
                height: 1.2,
              ),
              decoration: const InputDecoration(
                hintText: '------',
                counterText: '',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextButton(
              onPressed: _isVerifying
                  ? null
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.otpResent)),
                      );
                    },
              child: Text(l10n.resendOtp),
            ),
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            onPressed: _isVerifying ? null : _verify,
            child: _isVerifying
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(l10n.verifyAndLogin),
          ),
        ),
      ],
    );
  }
}
