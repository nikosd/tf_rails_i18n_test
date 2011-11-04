#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Tf18n::Application.load_tasks

#RAILS_ROOT = Rails.root
require 'fast_gettext'
FastGettext.add_text_domain 'app', :path => 'config/locales/app', :type => :po
FastGettext.default_text_domain = 'app'
require "gettext_i18n_rails/tasks"
