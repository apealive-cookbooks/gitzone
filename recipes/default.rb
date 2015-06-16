 #
 # Cookbook Name:: gitzone
 # Recipe:: default
 #
 # Copyright (C) 2014 Petr Michalec
 #
 # All rights reserved - Do Not Redistribute
 #

 # Changes against original install:
 # - this cookbook for now install only one user/zone by default
 # Changes expected:
 # - not like having $HOME/zones/$username dir. May change to just zones/.

 ## INSTALL GENERIC DEPENDENCIES
 %w(make).each do |pkg|
   package pkg
 end
 include_recipe 'git'

 # TODO, review zsh include
 include_recipe 'zsh'

 include_recipe 'bind'
 include_recipe 'sudo'
 # include_recipe 'system'

 include_recipe "#{cookbook_name}::install"
 include_recipe "#{cookbook_name}::configure"
