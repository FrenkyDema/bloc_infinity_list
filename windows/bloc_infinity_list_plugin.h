#ifndef FLUTTER_PLUGIN_BLOC_INFINITY_LIST_PLUGIN_H_
#define FLUTTER_PLUGIN_BLOC_INFINITY_LIST_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace bloc_infinity_list {

class BlocInfinityListPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  BlocInfinityListPlugin();

  virtual ~BlocInfinityListPlugin();

  // Disallow copy and assign.
  BlocInfinityListPlugin(const BlocInfinityListPlugin&) = delete;
  BlocInfinityListPlugin& operator=(const BlocInfinityListPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace bloc_infinity_list

#endif  // FLUTTER_PLUGIN_BLOC_INFINITY_LIST_PLUGIN_H_
