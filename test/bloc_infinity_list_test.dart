import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_infinity_list/bloc_infinity_list.dart';
import 'package:bloc_infinity_list/bloc_infinity_list_platform_interface.dart';
import 'package:bloc_infinity_list/bloc_infinity_list_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBlocInfinityListPlatform
    with MockPlatformInterfaceMixin
    implements BlocInfinityListPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final BlocInfinityListPlatform initialPlatform = BlocInfinityListPlatform.instance;

  test('$MethodChannelBlocInfinityList is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBlocInfinityList>());
  });

  test('getPlatformVersion', () async {
    BlocInfinityList blocInfinityListPlugin = BlocInfinityList();
    MockBlocInfinityListPlatform fakePlatform = MockBlocInfinityListPlatform();
    BlocInfinityListPlatform.instance = fakePlatform;

    expect(await blocInfinityListPlugin.getPlatformVersion(), '42');
  });
}
