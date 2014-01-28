# RECIPE configure
## Imitate the function of gitzone-install script

#TODO: check bind is allready installed
#package "bind"

include_recipe "#{cookbook_name}::configure_users"
include_recipe "#{cookbook_name}::configure_bind"
include_recipe "#{cookbook_name}::configure_zonefile"

