#
# Cookbook Name:: gitzone
# Recipe:: default
#
# Copyright (C) 2014 Petr Michalec
# 
# All rights reserved - Do Not Redistribute
#

#Changes against original install:
# - this cookbook for now install only one user/zone by default
#Changes expected:
# - not like having $HOME/zones/$username dir. May change to just zones/.

include_recipe "#{cookbook_name}::install"
include_recipe "#{cookbook_name}::configure"

