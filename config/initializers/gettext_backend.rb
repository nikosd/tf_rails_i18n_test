require "i18n/backend/gettext"
I18n::Backend::Simple.send(:include, I18n::Backend::Gettext)

I18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml,po}')]
