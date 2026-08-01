import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/tk_format.dart';
import '../../../shared/widgets/tk_async_error_body.dart';
import '../../../shared/widgets/tk_grid_table.dart';
import '../../code/domain/code.dart';
import '../../code/presentation/code_list_extensions.dart';
import '../domain/delivery_detail.dart';
import 'delivery_view_provider.dart';

class DeliveryViewDetailPanel extends ConsumerWidget {
  const DeliveryViewDetailPanel({
    super.key,
    required this.deliveryNo,
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

  final String deliveryNo;
  final List<Code> codes;
  final String Function(String productCode) productName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(deliveryViewDetailListProvider(deliveryNo));

    return detailsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => TkAsyncErrorBody(
        error: error,
        fallbackMessage: '출고 상세를 불러오지 못했습니다.',
      ),
      data: (details) {
        if (details.isEmpty) {
          return const Center(child: Text('출고 상세가 없습니다.'));
        }

        return TkGridTable(
          columns: _columns,
          itemCount: details.length,
          itemBuilder: (index) => _buildDetailRow(codes, details[index]),
        );
      },
    );
  }

  List<Widget> _buildDetailRow(List<Code> codes, DeliveryDetail detail) {
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
