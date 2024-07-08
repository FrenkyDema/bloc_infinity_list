import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'bloc_infinity_list_method_channel.dart';

abstract class BlocInfinityListPlatform extends PlatformInterface {
  /// Constructs a BlocInfinityListPlatform.
  BlocInfinityListPlatform() : super(token: _token);

  static final Object _token = Object();

  static BlocInfinityListPlatform _instance = MethodChannelBlocInfinityList();

  /// The default instance of [BlocInfinityListPlatform] to use.
  ///
  /// Defaults to [MethodChannelBlocInfinityList].
  static BlocInfinityListPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BlocInfinityListPlatform] when
  /// they register themselves.
  static set instance(BlocInfinityListPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
