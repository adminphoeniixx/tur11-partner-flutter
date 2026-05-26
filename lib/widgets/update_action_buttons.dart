import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_config_models.dart';
import '../theme/app_theme.dart';

class UpdateActionButtons extends StatelessWidget {
  final UpdateConfig update;
  final bool compact;

  const UpdateActionButtons({
    super.key,
    required this.update,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final actions = _actions();

    if (actions.isEmpty) {
      return Text(
        'Update link is not available. Please try again later.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.red,
          fontSize: compact ? 12 : 13,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    if (actions.length == 1) {
      return SizedBox(
        width: double.infinity,
        child: _UpdateButton(action: actions.first, compact: compact),
      );
    }

    return Row(
      children: [
        for (var index = 0; index < actions.length; index++) ...[
          if (index > 0) const SizedBox(width: 10),
          Expanded(
            child: _UpdateButton(action: actions[index], compact: compact),
          ),
        ],
      ],
    );
  }

  List<_UpdateAction> _actions() {
    final mode = update.updateMode.toLowerCase();
    final storeUrl = _storeUrl;
    final storeLabel = _isIos ? 'App Store' : 'Play Store';
    final actions = <_UpdateAction>[];

    if ((mode == 'playstore' || mode == 'both') && storeUrl != null) {
      actions.add(
        _UpdateAction(
          label: mode == 'both' ? storeLabel : 'Update on $storeLabel',
          icon: _isIos ? Icons.apple : Icons.shop_2_outlined,
          url: storeUrl,
        ),
      );
    }

    if ((mode == 'download' || mode == 'both') && update.downloadUrl != null) {
      actions.add(
        _UpdateAction(
          label: mode == 'both' ? 'Download APK' : 'Download Update',
          icon: Icons.download_rounded,
          url: update.downloadUrl!,
        ),
      );
    }

    return actions;
  }

  String? get _storeUrl => _isIos ? update.appstoreUrl : update.playstoreUrl;

  bool get _isIos => !kIsWeb && Platform.isIOS;
}

class _UpdateButton extends StatelessWidget {
  final _UpdateAction action;
  final bool compact;

  const _UpdateButton({
    required this.action,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _openUrl(action.url),
      icon: Icon(action.icon, size: compact ? 17 : 19),
      label: Text(
        action.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        minimumSize: Size.fromHeight(compact ? 44 : 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _UpdateAction {
  final String label;
  final IconData icon;
  final String url;

  const _UpdateAction({
    required this.label,
    required this.icon,
    required this.url,
  });
}
