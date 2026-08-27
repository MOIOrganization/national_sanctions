import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../services/sanctions_service.dart';
import '../theme/app_colors.dart';

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

  // ============================================================
  // SELECT CPR EXPIRY DATE
  // ============================================================

  Future<void> _selectExpiryDate() async {
    final DateTime now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 15),
    );

    if (picked == null) return;

    final String day = picked.day.toString().padLeft(2, '0');

    final String month = picked.month.toString().padLeft(2, '0');

    final String year = picked.year.toString();

    setState(() {
      _expiryController.text = '$day/$month/$year';
    });
  }

  // ============================================================
  // CONTINUE TO OTP
  // ============================================================

  Future<void> _continue() async {
    if (_isLoggingIn) {
      return;
    }

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoggingIn = true;
    });

    try {
      await _service.login(
        cpr: _cprController.text.trim(),
        blockNo: _blockController.text.trim(),
        expireDate: _expiryController.text.trim().replaceAll('/', ''),
      );

      if (!mounted) return;

      await _showOtpDialog();
    } on SanctionsApiException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to login. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
  }

  Future<void> _showOtpDialog() async {
    final TextEditingController otpController = TextEditingController();

    bool isVerifying = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              titlePadding: const EdgeInsets.fromLTRB(22, 22, 12, 0),
              contentPadding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
              actionsPadding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
              title: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'OTP Verification',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: isVerifying
                        ? null
                        : () {
                            Navigator.pop(dialogContext);
                          },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              content: SizedBox(
                width: 380,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.sms_outlined,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Enter the verification code sent to +973 ${_phoneController.text.trim()}.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 10,
                      ),
                      decoration: const InputDecoration(
                        hintText: '------',
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Demo mode: any 6-digit OTP will be accepted.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: isVerifying
                          ? null
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'A new demo OTP has been sent.',
                                  ),
                                ),
                              );
                            },
                      child: const Text('Resend OTP'),
                    ),
                  ],
                ),
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: isVerifying
                        ? null
                        : () async {
                            final String otp = otpController.text.trim();

                            if (otp.length != 6) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enter the 6-digit OTP.',
                                  ),
                                ),
                              );

                              return;
                            }

                            setDialogState(() {
                              isVerifying = true;
                            });

                            await Future.delayed(
                              const Duration(milliseconds: 600),
                            );

                            if (!mounted) return;

                            Navigator.pop(dialogContext);

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MainScreen(),
                              ),
                              (route) => false,
                            );
                          },
                    child: isVerifying
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Verify and Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    otpController.dispose();
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
    return Scaffold(
      body: Stack(
        children: [
          // ====================================================
          // BACKGROUND IMAGE
          // ====================================================
          Positioned.fill(
            child: Image.asset(
              'asset/images/background.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // ====================================================
          // DARK OVERLAY
          // ====================================================
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.55)),
          ),

          // ====================================================
          // LOGIN CONTENT
          // ====================================================
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    children: [
                      // ========================================
                      // LOGO
                      // ========================================
                      Container(
                        width: 140,
                        height: 140,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
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

                      const SizedBox(height: 10),

                      // ========================================
                      // APP NAME
                      // ========================================
                      const Text(
                        'Sanctions',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 7),

                      const Text(
                        'Enter your identification details to continue.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ========================================
                      // LOGIN CARD
                      // ========================================
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.96),
                          borderRadius: BorderRadius.circular(20),
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
                              const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),

                              const SizedBox(height: 6),

                              const Text(
                                'Please provide the required information below.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),

                              const SizedBox(height: 18),

                              // =================================
                              // CPR
                              // =================================
                              TextFormField(
                                controller: _cprController,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                maxLength: 9,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'CPR Number',
                                  hintText: 'Enter CPR number',
                                  prefixIcon: Icon(Icons.badge_outlined),
                                  counterText: '',
                                ),
                                validator: (value) {
                                  final String text = value?.trim() ?? '';

                                  if (text.isEmpty) {
                                    return 'Please enter your CPR number';
                                  }

                                  if (text.length != 9) {
                                    return 'CPR number must be 9 digits';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // =================================
                              // EXPIRY
                              // =================================
                              TextFormField(
                                controller: _expiryController,
                                readOnly: true,
                                onTap: _selectExpiryDate,
                                decoration: InputDecoration(
                                  labelText: 'CPR Expiry Date',
                                  hintText: 'DD/MM/YYYY',
                                  prefixIcon: const Icon(
                                    Icons.calendar_month_outlined,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: _selectExpiryDate,
                                    icon: const Icon(
                                      Icons.calendar_today_outlined,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please select the CPR expiry date';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // =================================
                              // BLOCK NUMBER
                              // =================================
                              TextFormField(
                                controller: _blockController,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                maxLength: 4,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Block Number',
                                  hintText: 'Enter block number',
                                  prefixIcon: Icon(Icons.location_on_outlined),
                                  counterText: '',
                                ),
                                validator: (value) {
                                  final String text = value?.trim() ?? '';

                                  if (text.isEmpty) {
                                    return 'Please enter your block number';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),
                              // =================================
                              // MOBILE
                              // =================================
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.done,
                                maxLength: 8,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onFieldSubmitted: (_) => _continue(),
                                decoration: const InputDecoration(
                                  labelText: 'Mobile Number',
                                  hintText: 'Enter mobile number',
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.phone_outlined),
                                        SizedBox(width: 7),
                                        Text(
                                          '+973',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  counterText: '',
                                ),
                                validator: (value) {
                                  final String text = value?.trim() ?? '';

                                  if (text.isEmpty) {
                                    return 'Please enter your mobile number';
                                  }

                                  if (text.length != 8) {
                                    return 'Mobile number must be 8 digits';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 20),

                              // =================================
                              // CONTINUE
                              // =================================
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: FilledButton(
                                  onPressed: _isLoggingIn ? null : _continue,
                                  child: _isLoggingIn
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Continue',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(
                                              Icons.arrow_forward,
                                              size: 19,
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
          ),
        ],
      ),
    );
  }
}
