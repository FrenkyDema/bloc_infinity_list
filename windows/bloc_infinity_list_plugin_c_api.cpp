#include "include/bloc_infinity_list/bloc_infinity_list_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "bloc_infinity_list_plugin.h"

void BlocInfinityListPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  bloc_infinity_list::BlocInfinityListPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
