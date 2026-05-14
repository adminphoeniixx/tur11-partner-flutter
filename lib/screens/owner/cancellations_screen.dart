import 'package:flutter/material.dart';

import '../../controllers/booking_controller.dart';
import '../../models/booking_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class CancellationsScreen extends StatefulWidget {
  const CancellationsScreen({super.key});

  @override
  State<CancellationsScreen> createState() => _CancellationsScreenState();
}

class _CancellationsScreenState extends State<CancellationsScreen> {
  final CancellationController _controller = CancellationController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onCancellationsChanged);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.removeListener(_onCancellationsChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onCancellationsChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _controller.load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 78),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Cancellations & Refunds',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          const Text('Track cancellations and process refunds',
              style: TextStyle(fontSize: 12, color: AppColors.muted)),
          if (_controller.errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              _controller.errorMessage!,
              style: const TextStyle(color: AppColors.red, fontSize: 12),
            ),
          ],
          const SizedBox(height: 14),
          _stats(),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.all(12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Cancellation Log',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              if (_controller.isLoading && _controller.cancellations.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_controller.cancellations.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'No cancellations found.',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                )
              else
                ..._controller.cancellations.map(_cancelFromApi),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _stats() {
    final total = _controller.cancellations.length;
    final pending = _controller.cancellations
        .where((item) => item.status.toLowerCase().contains('pending') ||
            item.status.toLowerCase().contains('process'))
        .length;

    return LayoutBuilder(builder: (context, constraints) {
      final count = constraints.maxWidth < 360 ? 1 : 2;
      return GridView.count(
        crossAxisCount: constraints.maxWidth > 700 ? 4 : count,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: constraints.maxWidth < 360 ? 2.4 : 1.75,
        children: [
          StatCard(
              label: 'Cancellations',
              value: total.toString(),
              change: 'All cancellations',
              isUp: false),
          const StatCard(
              label: 'Refunds Issued',
              value: 'Rs 0',
              change: 'From API log',
              isUp: false,
              changeColor: AppColors.muted),
          const StatCard(
              label: 'Penalties',
              value: 'Rs 0',
              change: 'From API log'),
          StatCard(
              label: 'Pending Refunds',
              value: pending.toString(),
              change: 'Pending',
              isUp: false,
              changeColor: AppColors.amber),
        ],
      );
    });
  }

  Widget _cancelFromApi(CancellationItem item) {
    final status = _statusType(item.status);
    final beforeColor = _beforeColor(item.cancelledBefore);
    final refundColor = _refundColor(item.refund);

    return _cancelCard(
      item.id.startsWith('#') ? item.id : '#${item.id}',
      item.customerName,
      item.turfName,
      item.time,
      item.cancelledBefore,
      beforeColor.withOpacity(0.12),
      beforeColor,
      item.refund,
      refundColor,
      status,
      _statusLabel(item.status),
    );
  }

  Widget _cancelCard(
    String id,
    String name,
    String turf,
    String time,
    String before,
    Color beforeBg,
    Color beforeFg,
    String refund,
    Color refundColor,
    StatusType status,
    String statusLabel,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700))),
          StatusBadge(label: statusLabel, type: status),
        ]),
        const SizedBox(height: 4),
        Text('$id - $turf',
            style: const TextStyle(fontSize: 11, color: AppColors.muted)),
        const SizedBox(height: 12),
        Row(children: [
          AppBadge(label: before, bg: beforeBg, fg: beforeFg),
          const Spacer(),
          Text(refund,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: refundColor)),
        ]),
        const SizedBox(height: 4),
        Text(time, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
      ]),
    );
  }

  StatusType _statusType(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('pending') || normalized.contains('process')) {
      return StatusType.pending;
    }
    if (normalized.contains('cancel')) return StatusType.cancelled;
    return StatusType.active;
  }

  Color _beforeColor(String before) {
    final number = int.tryParse(RegExp(r'\d+').firstMatch(before)?.group(0) ?? '');
    if (number == null) return AppColors.amber;
    if (number >= 24) return AppColors.green;
    if (number >= 2) return AppColors.amber;
    return AppColors.red;
  }

  Color _refundColor(String refund) {
    final text = refund.toLowerCase();
    if (text.contains('0')) return AppColors.red;
    if (text.contains('50') || text.contains('half')) return AppColors.amber;
    return AppColors.green;
  }

  String _statusLabel(String status) {
    final cleaned = status.trim();
    if (cleaned.isEmpty) return 'Processed';
    return cleaned
        .split(RegExp(r'[_\s-]+'))
        .map((part) => part.isEmpty
            ? part
            : '${part.substring(0, 1).toUpperCase()}${part.substring(1).toLowerCase()}')
        .join(' ');
  }
}
