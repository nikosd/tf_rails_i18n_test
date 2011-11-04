require "i18n/backend/pluralization"
require "i18n/backend/gettext"

module I18n
  module Backend
    # Hacking I18n::Backend::Pluralization and I18n::Backend::Gettext to play well together.
    # See https://github.com/svenfuchs/i18n/issues/113 for more info and status update.
    # TODO : Remove this once https://github.com/svenfuchs/i18n/issues/113 gets fixed.
    #
    # This is an abstraction of the following initializer hack
    # (for example config/initializers/i18n.rb) :
    #
    #  require "i18n/backend/pluralization"
    #  I18n::Backend::Simple.send(:include, I18n::Backend::Pluralization)
    #
    #  I18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    #
    #  locale_plural_keys = {}
    #  I18n.available_locales.each do |l|
    #    locale_plural_keys[l] = I18n.t(:'i18n.plural.keys', :locale => l, :resolve => false)
    #  end
    #  I18n::Gettext.plural_keys = locale_plural_keys
    #
    #  require "i18n/backend/gettext"
    #  I18n::Backend::Simple.send(:include, I18n::Backend::Gettext)
    #
    #  I18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{po}')]
    #
    # For this to work you need the following :
    #
    #   * plurals.rb under config/locales
    #   * Something like the following on your initializer :
    #
    #  require "pluralized_gettext_backend"
    #  I18n::Backend::Simple.send(:include, I18n::Backend::PluralizedGettext)
    #  I18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml,po}')]
    #
    #
    # You can find the `plurals.rb` under https://github.com/svenfuchs/i18n/blob/master/test/test_data/locales/plurals.rb
    # Kudos to http://stackoverflow.com/questions/6166064/i18n-pluralization/6166091#6166091 !
    #
    # Have fun!
    module PluralizedGettext
      include Pluralization
      include Gettext

      def init_translations
        # load the plurals
        rules = load_rb(Rails.root.join('config', 'locales', 'plurals.rb'))

        # set the plural_forms
        rules.each do |locale, rule|
          I18n::Gettext.plural_keys[locale] = rule[:i18n][:plural][:keys]
        end

        Rails.logger.debug(I18n::Gettext.plural_keys.inspect) if defined?(Rails)

        # go on with your life...
        super
      end
    end
  end

  module Gettext
    def self.plural_keys(*args)
      args.length == 0 ? @@plural_keys : @@plural_keys[args.first] || @@plural_keys[:en]
    end
  end
end
