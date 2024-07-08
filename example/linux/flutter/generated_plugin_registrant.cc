//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <bloc_infinity_list/bloc_infinity_list_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) bloc_infinity_list_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "BlocInfinityListPlugin");
  bloc_infinity_list_plugin_register_with_registrar(bloc_infinity_list_registrar);
}
