import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/tk_format.dart';
import '../../../shared/widgets/tk_async_error_body.dart';
import '../../../shared/widgets/tk_grid_table.dart';
import '../../code/domain/code.dart';
import '../../code/presentation/code_list_extensions.dart';
import '../../expend/domain/expend.dart';
import '../../expend/presentation/expend_provider.dart';
import '../domain/sales.dart';
import '../domain/sales_detail.dart';
import 'sales_view_provider.dart';

class SalesViewDetailPanel extends ConsumerWidget {
  const SalesViewDetailPanel({
    super.key,
    required this.sales,
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

  final Sales sales;
  final List<Code> codes;
  final String Function(String productCode) productName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (sales.isExpendRow) {
      final idx = int.tryParse(sales.salesNo);
      if (idx == null) {
        return const Center(child: Text('지출 상세를 불러올 수 없습니다.'));
      }

      final expendAsync = ref.watch(expendDetailProvider(idx));

      return expendAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => TkAsyncErrorBody(
          error: error,
          fallbackMessage: '지출 상세를 불러오지 못했습니다.',
        ),
        data: (expend) {
          return TkGridTable(
            columns: _columns,
            itemCount: 1,
            itemBuilder: (_) => _buildExpendRow(codes, expend),
          );
        },
      );
    }

    final detailsAsync = ref.watch(salesViewDetailListProvider(sales.salesNo));

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
          itemBuilder: (index) => _buildSalesDetailRow(codes, details[index]),
        );
      },
    );
  }

  List<Widget> _buildExpendRow(List<Code> codes, Expend expend) {
    return [
      const Text(''),
      Text(codes.displayName(expend.expendCode)),
      Text(0.formatted),
      Text(0.formatted),
      Text(expend.cost.formatted),
      Text(0.formatted),
      Text(expend.remark),
    ];
  }

  List<Widget> _buildSalesDetailRow(List<Code> codes, SalesDetail detail) {
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
