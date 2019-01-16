local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();

{

  remove_dots(str)::
    assert std.type(str) == 'string';
    std.join('', std.split(str, '.')),


  resource: {
    google_compute_network: {
      [network]: set {
      }
      for network in std.objectFields(inv.parameters.resources.network)
      for set in inv.parameters.resources.network[network]
    },
    google_compute_firewall: {
      [set.name]: set {
        network: "${google_compute_network." + set.network + ".name}",
      }
      for set in inv.parameters.resources.firewall
    },
  },
}
