import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../session/session_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_alert.dart';

Future<void> showAccountDrawer({required BuildContext context}) {
  final bool isRtl = Directionality.of(context) == TextDirection.rtl;
  final SessionController session = SessionScope.read(context);

  return showGeneralDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return ListenableBuilder(
        listenable: session,
        builder: (context, _) {
          return AccountDrawerPanel(session: session);
        },
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final Animation<Offset> offset = Tween<Offset>(
        begin: isRtl ? const Offset(1, 0) : const Offset(-1, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      );

      return SlideTransition(position: offset, child: child);
    },
  );
}

class AccountDrawerPanel extends StatelessWidget {
  const AccountDrawerPanel({super.key, required this.session});

  final SessionController session;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final double maxWidth = MediaQuery.sizeOf(context).width * 0.82;
    final String cpr = session.cpr ?? '';

    return Align(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: 1,
      child: Material(
        color: AppColors.surface,
        elevation: 8,
        borderRadius: const BorderRadiusDirectional.only(
          topEnd: Radius.circular(AppRadius.standard),
          bottomEnd: Radius.circular(AppRadius.standard),
        ),
        child: SizedBox(
          width: maxWidth > 320 ? 320 : maxWidth,
          height: MediaQuery.sizeOf(context).height,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            AppSpacing.lg,
                            AppSpacing.lg,
                            AppSpacing.md,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.verified_user_outlined,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                l10n.signedInAs,
                                style: AppTextStyles.caption,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                l10n.cpr,
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.muted,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                cpr.isEmpty ? '—' : cpr,
                                textDirection: TextDirection.ltr,
                                style: AppTextStyles.heading.copyWith(
                                  color: AppColors.primary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.fingerprint,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      l10n.biometricLogin,
                                      style: AppTextStyles.subheading.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                l10n.biometricLoginDescription,
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.muted,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () => _onBiometricPressed(context),
                                  child: Text(
                                    session.biometricEnabled
                                        ? l10n.disableBiometric
                                        : l10n.enableBiometric,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Material(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: AppRadius.border,
                    child: InkWell(
                      borderRadius: AppRadius.border,
                      onTap: () => _onLogoutPressed(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.logout,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                l10n.logOut,
                                style: AppTextStyles.subheading.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onBiometricPressed(BuildContext context) async {
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (session.biometricEnabled) {
      final bool confirmed = await showAppConfirm(
        context: context,
        title: l10n.disableBiometricTitle,
        message: l10n.disableBiometricMessage,
        confirmLabel: l10n.disable,
        isDestructive: true,
      );

      if (!confirmed || !context.mounted) {
        return;
      }

      session.setBiometricEnabled(false);

      if (!context.mounted) {
        return;
      }

      await showAppAlert(
        context: context,
        title: l10n.biometricDisabledTitle,
        message: l10n.biometricDisabledMessage,
      );
      return;
    }

    session.setBiometricEnabled(true);

    if (!context.mounted) {
      return;
    }

    await showAppAlert(
      context: context,
      title: l10n.biometricEnabledTitle,
      message: l10n.biometricEnabledMessage,
    );
  }

  Future<void> _onLogoutPressed(BuildContext context) async {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final bool confirmed = await showAppConfirm(
      context: context,
      title: l10n.logoutQuestion,
      message: l10n.logoutConfirmQuestion,
      confirmLabel: l10n.logOut,
      isDestructive: true,
    );

    if (!confirmed || !context.mounted) {
      return;
    }

    final NavigatorState navigator = Navigator.of(
      context,
      rootNavigator: true,
    );

    navigator.popUntil((route) => route.isFirst);
    session.signOut();
  }
}
