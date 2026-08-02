import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/tk_format.dart';
import '../../../shared/widgets/tk_async_error_body.dart';
import '../../../shared/widgets/tk_grid_table.dart';
import '../../code/domain/code.dart';
import '../../code/presentation/code_list_extensions.dart';
import '../domain/sales_detail.dart';
import 'sales_view_provider.dart';

class SalesViewDetailPanel extends ConsumerWidget {
  const SalesViewDetailPanel({
    super.key,
    required this.salesNo,
    required this.codes,
    required this.productName,
  });

  static const _columns = [
    TkGridColumn(label: '제품'),
    TkGridColumn(label: '처리 방법'),
    TkGridColumn(label: '단가', numeric: true),
    TkGridColumn(label: '할인', numeric: true),
    TkGridColumn(label: '금액', numeric: true),
    TkGridColumn(label: '수량', numeric: true),
    TkGridColumn(label: '비고'),
  ];

  final String salesNo;
  final List<Code> codes;
  final String Function(String productCode) productName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(salesViewDetailListProvider(salesNo));

    return detailsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => TkAsyncErrorBody(
        error: error,
        fallbackMessage: '매출 상세를 불러오지 못했습니다.',
      ),
      data: (details) {
        if (details.isEmpty) {
          return const Center(child: Text('매출 상세가 없습니다.'));
        }

        return TkGridTable(
          columns: _columns,
          itemCount: details.length,
          itemBuilder: (index) => _buildDetailRow(codes, details[index]),
        );
      },
    );
  }

  List<Widget> _buildDetailRow(List<Code> codes, SalesDetail detail) {
    return [
      Text(productName(detail.productCode)),
      Text(codes.displayName(detail.processCode)),
      Text(detail.price.formatted),
      Text(detail.discount.formatted),
      Text(detail.cost.formatted),
      Text(detail.qty.formatted),
      Text(detail.remark ?? ''),
    ];
  }
}
