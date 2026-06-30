import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/member_api.dart';
import '../domain/member.dart';

class MemberListNotifier extends AutoDisposeAsyncNotifier<List<Member>> {
  late final MemberApi _memberApi;

  @override
  Future<List<Member>> build() async {
    _memberApi = MemberApi();
    return _memberApi.listMembers();
  }

  Future<void> search() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_memberApi.listMembers);
  }
}

final memberListProvider =
    AsyncNotifierProvider.autoDispose<MemberListNotifier, List<Member>>(
  MemberListNotifier.new,
);
