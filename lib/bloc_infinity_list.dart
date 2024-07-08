
import 'bloc_infinity_list_platform_interface.dart';

class BlocInfinityList {
  Future<String?> getPlatformVersion() {
    return BlocInfinityListPlatform.instance.getPlatformVersion();
  }
}
