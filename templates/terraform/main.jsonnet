local kap = import "lib/kapitan.libjsonnet";
local inv = kap.inventory();

local output = import "output.jsonnet";
local provider = import "provider.jsonnet";

local network = import "network.jsonnet";
local compute = import "compute.jsonnet";

{
  "provider.tf": provider,
  [if "network" in inv.parameters.resources then "network.tf"]: network,
  [if "deployer" in inv.parameters.resources then "compute.tf"]: compute,
}
