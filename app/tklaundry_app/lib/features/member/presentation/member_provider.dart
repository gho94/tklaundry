import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/member_api.dart';
import '../domain/member.dart';

class MemberListNotifier extends AsyncNotifier<List<Member>> {
  late final MemberApi _memberApi;

  @override
  Future<List<Member>> build() async {
    _memberApi = MemberApi();
    return [];
  }

  Future<void> search() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_memberApi.listMembers);
  }
}

final memberListProvider =
    AsyncNotifierProvider<MemberListNotifier, List<Member>>(
  MemberListNotifier.new,
);
