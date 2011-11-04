# FAIL!
#require "i18n/backend/pluralization"
#require "i18n/backend/gettext"
#
#I18n::Backend::Simple.send(:include, I18n::Backend::Pluralization)
#I18n::Backend::Simple.send(:include, I18n::Backend::Gettext)
#
#I18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml,po}')]

# WORKAROUND
#require "i18n/backend/pluralization"
#I18n::Backend::Simple.send(:include, I18n::Backend::Pluralization)
#I18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
#
#require "i18n/gettext"
## Monkey patch I18n::Gettext so we can set externally the plural keys
#module I18n
#  module Gettext
#    def self.plural_keys=(plural_keys)
#      @@plural_keys = plural_keys
#    end
#  end
#end
#
## Load and set the plural keys before loading the Gettext backend alongside the po files
#locale_plural_keys = {}
#I18n.available_locales.each do |l|
#  locale_plural_keys[l] = I18n.t(:'i18n.plural.keys', :locale => l, :resolve => false)
#end
#I18n::Gettext.plural_keys = locale_plural_keys
#
## Now load the Gettext backend
#require "i18n/backend/gettext"
#I18n::Backend::Simple.send(:include, I18n::Backend::Gettext)
#
## And finally the po files
#I18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{po}')]

# STANDARDIZED HACK (tm)
# See `lib/pluralized_gettext_backend` and https://github.com/svenfuchs/i18n/issues/113 for more info.
require "pluralized_gettext_backend"
I18n::Backend::Simple.send(:include, I18n::Backend::PluralizedGettext)
I18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml,po}')]

#include I18n::Gettext::Helpers
