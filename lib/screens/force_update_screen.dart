import 'package:flutter/material.dart';

import '../models/app_config_models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/update_action_buttons.dart';

class ForceUpdateScreen extends StatelessWidget {
  final UpdateConfig update;

  const ForceUpdateScreen({
    super.key,
    required this.update,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.bg2,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Turf11PartnerLogo(markSize: 42, textSize: 21),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _UpdateImage(url: update.imageUrl),
                          const SizedBox(height: 28),
                          Text(
                            update.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.dark,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            update.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 15,
                              height: 1.45,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (update.whatsNew.isNotEmpty) ...[
                            const SizedBox(height: 22),
                            _WhatsNew(items: update.whatsNew),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                UpdateActionButtons(update: update),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WhatsNew extends StatelessWidget {
  final List<String> items;

  const _WhatsNew({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What's new",
            style: TextStyle(
              color: AppColors.dark,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.green,
                    size: 17,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: AppColors.dark2,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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

class _UpdateImage extends StatelessWidget {
  final String? url;

  const _UpdateImage({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return const Icon(
        Icons.system_update_alt_rounded,
        size: 104,
        color: AppColors.green,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url!,
        height: 210,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.system_update_alt_rounded,
          size: 104,
          color: AppColors.green,
        ),
      ),
    );
  }
}
