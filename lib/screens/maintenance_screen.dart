import 'package:flutter/material.dart';

import '../models/app_config_models.dart';
import '../services/app_config_service.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class MaintenanceScreen extends StatefulWidget {
  final MaintenanceConfig maintenance;
  final VoidCallback onResolved;

  const MaintenanceScreen({
    super.key,
    required this.maintenance,
    required this.onResolved,
  });

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  bool _retrying = false;
  String? _error;

  Future<void> _retry() async {
    setState(() {
      _retrying = true;
      _error = null;
    });

    final config = await AppConfigService.checkAppConfig();
    if (!mounted) return;

    if (config == null || config.maintenance?.isActive != true) {
      widget.onResolved();
      return;
    }

    setState(() {
      _retrying = false;
      _error = 'Maintenance is still active. Please check again shortly.';
    });
  }

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
                        children: [
                          _RemoteImage(url: widget.maintenance.imageUrl),
                          const SizedBox(height: 28),
                          Text(
                            widget.maintenance.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.dark,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.maintenance.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 15,
                              height: 1.45,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (widget.maintenance.estimatedEnd != null) ...[
                            const SizedBox(height: 18),
                            _BackBy(time: widget.maintenance.estimatedEnd!),
                          ],
                          if (_error != null) ...[
                            const SizedBox(height: 18),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.red,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _retrying ? null : _retry,
                    icon: _retrying
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh_rounded),
                    label: Text(_retrying ? 'Checking...' : 'Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
}

class _BackBy extends StatelessWidget {
  final DateTime time;

  const _BackBy({required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.greenLt,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Back by ${_formatTime(time)}',
        style: const TextStyle(
          color: AppColors.green,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _formatTime(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final suffix = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}

class _RemoteImage extends StatelessWidget {
  final String? url;

  const _RemoteImage({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return const Icon(
        Icons.engineering_rounded,
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
          Icons.engineering_rounded,
          size: 104,
          color: AppColors.green,
        ),
      ),
    );
  }
}
