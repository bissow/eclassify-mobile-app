import 'package:eClassify/features/ad_posting/screens/widgets/ad_posting_step_controller.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:flutter/material.dart';

class AdPostingFormButtons extends StatelessWidget {
  const AdPostingFormButtons({
    this.onPrevious,
    this.onNext,
    this.onSubmit,
    super.key,
  });

  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final stepController = AdPostingStepController.of(context);

    return ListenableBuilder(
      listenable: stepController,
      builder: (context, _) {
        final prev = onPrevious ?? stepController.onPrevious;
        final next = onNext ?? stepController.onNext;
        final submit = onSubmit ?? stepController.onSubmit;

        if (prev == null &&
            next == null &&
            submit == null &&
            !stepController.showNext) {
          return const SizedBox.shrink();
        }

        return _buildButtons(
          context,
          onPrevious: prev,
          onNext: next,
          onSubmit: submit,
          showNext: stepController.showNext,
        );
      },
    );
  }

  Widget _buildButtons(
    BuildContext context, {
    VoidCallback? onPrevious,
    VoidCallback? onNext,
    VoidCallback? onSubmit,
    bool showNext = false,
  }) {
    return ColoredBox(
      color: context.colorScheme.secondary,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          Constant.horizontalPadding,
          16,
          Constant.horizontalPadding,
          MediaQuery.paddingOf(context).bottom + 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          spacing: 16,
          children: [
            if (onPrevious != null)
              Expanded(
                child: AppButton(
                  variant: AppButtonVariant.outlined,
                  onPressed: onPrevious,
                  title: 'previous',
                ),
              ),
            if (onNext != null || showNext)
              Expanded(
                child: AppButton(
                  variant: AppButtonVariant.filled,
                  onPressed: onNext,
                  title: 'next',
                ),
              ),
            if (onSubmit != null)
              Expanded(
                child: AppButton(
                  variant: AppButtonVariant.filled,
                  onPressed: onSubmit,
                  title: 'submit',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
