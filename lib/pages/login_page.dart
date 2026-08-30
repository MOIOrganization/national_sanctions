import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../main.dart';
import '../services/sanctions_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
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
  // OTP is not required by mob_un_login. Restore with the OTP dialog below.
  // final TextEditingController _phoneController = TextEditingController();

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

    if (picked == null) {
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
      );

      debugPrint('[LOGIN PAGE] mob_un_login response: $response');

      if (!mounted) {
        return;
      }

      // OTP is not required by mob_un_login. Restore by calling _showOtpDialog()
      // here instead of navigating to MainScreen.
      // await _showOtpDialog();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
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

  // OTP is not required by mob_un_login. Restore this dialog and the mobile
  // number field when OTP verification is added.
  //
  // Future<void> _showOtpDialog() async {
  //   final TextEditingController otpController = TextEditingController();
  //
  //   bool isVerifying = false;
  //
  //   await showDialog<void>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (dialogContext) {
  //       return StatefulBuilder(
  //         builder: (context, setDialogState) {
  //           return AlertDialog(
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(18),
  //             ),
  //             titlePadding: const EdgeInsets.fromLTRB(22, 22, 12, 0),
  //             contentPadding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
  //             actionsPadding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
  //             title: Row(
  //               children: [
  //                 const Expanded(
  //                   child: Text(
  //                     'OTP Verification',
  //                     style: TextStyle(fontWeight: FontWeight.bold),
  //                   ),
  //                 ),
  //                 IconButton(
  //                   onPressed: isVerifying
  //                       ? null
  //                       : () {
  //                           Navigator.pop(dialogContext);
  //                         },
  //                   icon: const Icon(Icons.close),
  //                 ),
  //               ],
  //             ),
  //             content: SizedBox(
  //               width: 380,
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   const Icon(
  //                     Icons.sms_outlined,
  //                     size: 48,
  //                     color: AppColors.primary,
  //                   ),
  //                   const SizedBox(height: 14),
  //                   Text(
  //                     'Enter the verification code sent to +973 ${_phoneController.text.trim()}.',
  //                     textAlign: TextAlign.center,
  //                     style: const TextStyle(
  //                       color: AppColors.textSecondary,
  //                       height: 1.5,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 22),
  //                   TextField(
  //                     controller: otpController,
  //                     keyboardType: TextInputType.number,
  //                     textAlign: TextAlign.center,
  //                     maxLength: 6,
  //                     inputFormatters: [
  //                       FilteringTextInputFormatter.digitsOnly,
  //                     ],
  //                     style: const TextStyle(
  //                       fontSize: 24,
  //                       fontWeight: FontWeight.bold,
  //                       letterSpacing: 10,
  //                     ),
  //                     decoration: const InputDecoration(
  //                       hintText: '------',
  //                       counterText: '',
  //                     ),
  //                   ),
  //                   const SizedBox(height: 8),
  //                   const Text(
  //                     'Demo mode: any 6-digit OTP will be accepted.',
  //                     textAlign: TextAlign.center,
  //                     style: TextStyle(
  //                       fontSize: 12,
  //                       color: AppColors.textSecondary,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 6),
  //                   TextButton(
  //                     onPressed: isVerifying
  //                         ? null
  //                         : () {
  //                             ScaffoldMessenger.of(context).showSnackBar(
  //                               const SnackBar(
  //                                 content: Text(
  //                                   'A new demo OTP has been sent.',
  //                                 ),
  //                               ),
  //                             );
  //                           },
  //                     child: const Text('Resend OTP'),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             actions: [
  //               SizedBox(
  //                 width: double.infinity,
  //                 height: 50,
  //                 child: FilledButton(
  //                   onPressed: isVerifying
  //                       ? null
  //                       : () async {
  //                           final String otp = otpController.text.trim();
  //
  //                           if (otp.length != 6) {
  //                             ScaffoldMessenger.of(context).showSnackBar(
  //                               const SnackBar(
  //                                 content: Text(
  //                                   'Please enter the 6-digit OTP.',
  //                                 ),
  //                               ),
  //                             );
  //
  //                             return;
  //                           }
  //
  //                           setDialogState(() {
  //                             isVerifying = true;
  //                           });
  //
  //                           await Future.delayed(
  //                             const Duration(milliseconds: 600),
  //                           );
  //
  //                           if (!mounted) return;
  //
  //                           Navigator.pop(dialogContext);
  //
  //                           Navigator.pushAndRemoveUntil(
  //                             context,
  //                             MaterialPageRoute(
  //                               builder: (_) => const MainScreen(),
  //                             ),
  //                             (route) => false,
  //                           );
  //                         },
  //                   child: isVerifying
  //                       ? const SizedBox(
  //                           height: 22,
  //                           width: 22,
  //                           child: CircularProgressIndicator(
  //                             strokeWidth: 2,
  //                             color: Colors.white,
  //                           ),
  //                         )
  //                       : const Text(
  //                           'Verify and Login',
  //                           style: TextStyle(
  //                             fontSize: 16,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                 ),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  //
  //   otpController.dispose();
  // }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _cprController.dispose();
    _expiryController.dispose();
    _blockController.dispose();
    // _phoneController.dispose();

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
                const Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: LanguageToggleButton(),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: AppSpacing.xl,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            padding: const EdgeInsets.all(10),
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
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.appTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            l10n.loginSubtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
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
                                    textInputAction: TextInputAction.done,
                                    textDirection: TextDirection.ltr,
                                    maxLength: 4,
                                    enabled: !_isLoggingIn,
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
                                  // OTP is not required by mob_un_login. Restore this
                                  // field with the OTP dialog when OTP is added.
                                  //
                                  // const SizedBox(height: 16),
                                  // TextFormField(
                                  //   controller: _phoneController,
                                  //   keyboardType: TextInputType.phone,
                                  //   textInputAction: TextInputAction.done,
                                  //   maxLength: 8,
                                  //   inputFormatters: [
                                  //     FilteringTextInputFormatter.digitsOnly,
                                  //   ],
                                  //   onFieldSubmitted: (_) => _continue(),
                                  //   decoration: const InputDecoration(
                                  //     labelText: 'Mobile Number',
                                  //     hintText: 'Enter mobile number',
                                  //     prefixIcon: Padding(
                                  //       padding: EdgeInsets.symmetric(
                                  //         horizontal: 12,
                                  //       ),
                                  //       child: Row(
                                  //         mainAxisSize: MainAxisSize.min,
                                  //         children: [
                                  //           Icon(Icons.phone_outlined),
                                  //           SizedBox(width: 7),
                                  //           Text(
                                  //             '+973',
                                  //             style: TextStyle(
                                  //               fontWeight: FontWeight.w600,
                                  //             ),
                                  //           ),
                                  //         ],
                                  //       ),
                                  //     ),
                                  //     counterText: '',
                                  //   ),
                                  //   validator: (value) {
                                  //     final String text = value?.trim() ?? '';
                                  //
                                  //     if (text.isEmpty) {
                                  //       return 'Please enter your mobile number';
                                  //     }
                                  //
                                  //     if (text.length != 8) {
                                  //       return 'Mobile number must be 8 digits';
                                  //     }
                                  //
                                  //     return null;
                                  //   },
                                  // ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
