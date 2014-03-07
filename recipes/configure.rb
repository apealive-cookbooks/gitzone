# RECIPE configure
## Imitate the function of gitzone-install script

#FIXME: check bind is allready installed
#package "bind"

include_recipe "#{cookbook_name}::configure_gitzone"
include_recipe "#{cookbook_name}::configure_bind"
include_recipe "#{cookbook_name}::configure_zones"

