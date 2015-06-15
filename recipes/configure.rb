# RECIPE configure
## Imitate the function of gitzone-install script

# TODO: check bind is allready installed (NOTE: for now bind cookbook is dependency)
# package "bind"

include_recipe "#{cookbook_name}::configure_gitzone"
include_recipe "#{cookbook_name}::configure_bind"
include_recipe "#{cookbook_name}::configure_zones"
