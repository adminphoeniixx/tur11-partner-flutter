import 'package:flutter/material.dart';

import '../../controllers/payment_controller.dart';
import '../../models/payment_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final PaymentController _controller = PaymentController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onPaymentsChanged);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.removeListener(_onPaymentsChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onPaymentsChanged() {
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
          _header(),
          if (_controller.errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              _controller.errorMessage!,
              style: const TextStyle(color: AppColors.red, fontSize: 12),
            ),
          ],
          const SizedBox(height: 14),
          _stats(_controller.summary),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: AppCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Payment Transactions',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 14),
                    if (_controller.isLoading && _controller.payouts.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(18),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_controller.payouts.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No payment transactions found.',
                          style:
                              TextStyle(fontSize: 12, color: AppColors.muted),
                        ),
                      )
                    else
                      ..._controller.payouts.map(_txnFromApi),
                  ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _header() {
    const title = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Payments',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      SizedBox(height: 3),
      Text('Revenue & payout tracking',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: AppColors.muted)),
    ]);

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 420) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [title],
        );
      }

      return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(child: title),
      ]);
    });
  }

  Widget _stats(PayoutSummary summary) {
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
              label: 'Total Revenue',
              value: summary.totalRevenue,
              change: summary.totalRevenueChange),
          StatCard(
              label: 'Settled',
              value: summary.settled,
              change: summary.settledChange,
              changeColor: AppColors.muted),
          StatCard(
              label: 'Pending',
              value: summary.pending,
              change: summary.pendingChange,
              isUp: false,
              changeColor: AppColors.amber),
          StatCard(
              label: 'Platform Fee',
              value: summary.platformFee,
              change: summary.platformFeeChange,
              isUp: false,
              changeColor: AppColors.muted),
        ],
      );
    });
  }

  Widget _txnFromApi(PayoutItem item) {
    final typeColors = _typeColors(item.type);
    final status = _statusType(item.status);
    return _txnCard(
      item.id,
      _label(item.type),
      typeColors.$1,
      typeColors.$2,
      item.name,
      item.amount,
      item.fee,
      item.net,
      _netColor(item.net, status),
      item.date,
      status,
      _label(item.status),
    );
  }

  Widget _txnCard(
    String id,
    String type,
    Color typeBg,
    Color typeFg,
    String name,
    String amount,
    String fee,
    String net,
    Color netColor,
    String date,
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
        Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppBadge(label: type, bg: typeBg, fg: typeFg),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: Text(id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.muted)),
              ),
              StatusBadge(label: statusLabel, type: status),
            ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700))),
          const SizedBox(width: 8),
          Flexible(
            flex: 0,
            child: Text(net,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: netColor)),
          ),
        ]),
        const SizedBox(height: 4),
        Text('$date - Amount $amount - Fee $fee',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.muted)),
      ]),
    );
  }

  (Color, Color) _typeColors(String type) {
    final normalized = type.toLowerCase();
    if (normalized.contains('refund')) return (AppColors.redLt, AppColors.red);
    if (normalized.contains('tournament')) {
      return (AppColors.blueLt, AppColors.blue);
    }
    return (AppColors.greenLt, AppColors.green);
  }

  StatusType _statusType(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('refund') || normalized.contains('cancel')) {
      return StatusType.cancelled;
    }
    if (normalized.contains('pending') || normalized.contains('process')) {
      return StatusType.pending;
    }
    if (normalized.contains('complete')) return StatusType.completed;
    return StatusType.active;
  }

  Color _netColor(String net, StatusType status) {
    final normalized = net.toLowerCase();
    if (status == StatusType.cancelled || normalized.startsWith('-')) {
      return AppColors.red;
    }
    if (status == StatusType.pending || normalized.contains('pending')) {
      return AppColors.amber;
    }
    return AppColors.green;
  }

  String _label(String value) {
    final cleaned = value.trim();
    if (cleaned.isEmpty) return '-';
    return cleaned
        .split(RegExp(r'[_\s-]+'))
        .map((part) => part.isEmpty
            ? part
            : '${part.substring(0, 1).toUpperCase()}${part.substring(1).toLowerCase()}')
        .join(' ');
  }
}
