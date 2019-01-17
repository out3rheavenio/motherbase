local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();


{

  remove_dots(str)::
    assert std.type(str) == 'string';
    std.join('', std.split(str, '.')),


  resource: {
    google_compute_instance: {
      [deployer]: set {
      }
      for deployer in std.objectFields(inv.parameters.resources.deployer)
      for set in inv.parameters.resources.deployer[deployer]
    },
    google_dns_record_set: {
      [deployer]: set {
        name: deployer + "." + inv.parameters.domain,
        rrdatas: [ "${" + set.rrdatas.name + "." + deployer + "." + set.rrdatas.endpoint  + "}" ],
      }
      for deployer in std.objectFields(inv.parameters.resources.deployer_dns)
      for set in inv.parameters.resources.deployer_dns[deployer]
    },
  },


}
