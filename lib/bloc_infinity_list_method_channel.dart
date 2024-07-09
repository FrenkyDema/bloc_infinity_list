import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'bloc_infinity_list_platform_interface.dart';

/// An implementation of [BlocInfinityListPlatform] that uses method channels.
class MethodChannelBlocInfinityList extends BlocInfinityListPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('bloc_infinity_list');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
