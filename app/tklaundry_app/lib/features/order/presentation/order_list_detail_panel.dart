import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/tk_format.dart';
import '../../../shared/widgets/tk_async_error_body.dart';
import '../../../shared/widgets/tk_grid_table.dart';
import '../../code/domain/code.dart';
import '../../code/presentation/code_list_extensions.dart';
import '../domain/order_detail.dart';
import 'order_provider.dart';

class OrderListDetailPanel extends ConsumerWidget {
  const OrderListDetailPanel({
    super.key,
    required this.orderNo,
    required this.codes,
    required this.productName,
  });

  static const _columns = [
    TkGridColumn(label: '순번', numeric: true),
    TkGridColumn(label: '제품'),
    TkGridColumn(label: '처리 방법'),
    TkGridColumn(label: '단가', numeric: true),
    TkGridColumn(label: '수량', numeric: true),
    TkGridColumn(label: '할인', numeric: true),
    TkGridColumn(label: '금액', numeric: true),
    TkGridColumn(label: '비고'),
  ];

  final String orderNo;
  final List<Code> codes;
  final String Function(String productCode) productName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(orderDetailListProvider(orderNo));

    return detailsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => TkAsyncErrorBody(
        error: error,
        fallbackMessage: '접수 상세를 불러오지 못했습니다.',
      ),
      data: (details) => TkGridTable(
        columns: _columns,
        itemCount: details.length,
        itemBuilder: (index) => _buildDetailRow(codes, details[index]),
      ),
    );
  }

  List<Widget> _buildDetailRow(List<Code> codes, OrderDetail detail) {
    return [
      Text(detail.orderSeq.formatted),
      Text(productName(detail.productCode)),
      Text(codes.displayName(detail.processCode)),
      Text(detail.price.formatted),
      Text(detail.qty.formatted),
      Text(detail.discount.formatted),
      Text(detail.cost.formatted),
      Text(detail.remark ?? ''),
    ];
  }
}
