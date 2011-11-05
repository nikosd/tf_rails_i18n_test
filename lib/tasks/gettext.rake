# Handy tasks for managing localization files (Gettext).
#
# Inspired from the following :
#
#   require 'fast_gettext'
#   FastGettext.add_text_domain 'app', :path => 'config/locales/app', :type => :po
#   FastGettext.default_text_domain = 'app'
#   require "gettext_i18n_rails/tasks"
#
# but customized to our needs.

namespace :gettext do

  def load_gettext
    require 'gettext'
    require 'gettext/tools'
  end

  def text_domain
    ENV['TEXTDOMAIN'] || "app"
  end

  def files_to_translate
    Dir.glob("{app,lib,config,#{locale_path}}/**/*.{rb,erb,haml}")
  end

  def locale_path
    File.join(Rails.root, 'config', 'locales', 'app')
  end

  # Modified GetText.update_pofiles (as found in gettext/tools.rb) to create/merge various po files
  # in the following folder structure:
  #
  #   `po_root/textdomain.pot` and `po_root/lang.po` instead of `po_root/lang/textdomain.po`.
  #
  # It's a hack but this ways the po files work out of the box the I18n::Backends::Gettext.
  #
  # See the original GetText.update_pofiles for documentation.
  module GetText
    def update_i18n_po_files(textdomain, files, app_version, options = {})
      puts options.inspect if options[:verbose]

      #write found messages to tmp.pot
      temp_pot = "tmp.pot"
      rgettext(files, temp_pot)

      #merge tmp.pot and existing pot
      po_root = options.delete(:po_root) || "po"
      FileUtils.mkdir_p(po_root)
      msgmerge("#{po_root}/#{textdomain}.pot", temp_pot, app_version, options.dup)

      #update local po-files
      only_one_language = options.delete(:lang)
      if only_one_language
        msgmerge("#{po_root}/#{only_one_language}.po", temp_pot, app_version, options.dup)
      else
        Dir.glob("#{po_root}/*.po") do |po_file|
          msgmerge(po_file, temp_pot, app_version, options.dup)
        end
      end

      File.delete(temp_pot)
    end
  end

  # For OS X with homebrew : MSGMERGE_PATH=/usr/local/Cellar/gettext/0.18.1.1/bin/msgmerge rake gettext:find
  desc "Update pot/po files (set MSGMERGE_PATH for custom msgmerge path)"
  task :find => :environment do
    load_gettext
    $LOAD_PATH << File.join(File.dirname(__FILE__),'..','..','lib')
    #require 'gettext_i18n_rails/haml_parser'

    GetText.update_i18n_po_files(
      text_domain,
      files_to_translate,
      "version 0.0.1",
      :po_root => locale_path,
      :msgmerge=>['--sort-output']
    )
  end

  # For OS X with homebrew : MSGINIT_PATH=/usr/local/Cellar/gettext/0.18.1.1/bin/msginit rake gettext:add_language[pl]
  desc "add a new language (set MSGINIT_PATH for custom msginit path)"
  task :add_language, [:language] => :environment do |_, args|
    language = args.language || ENV["LANGUAGE"]

    # Let's do some pre-verification of the environment.
    if language.nil?
      puts "You need to specify the language to add. Either 'LANGUAGE=eo rake gettext:add_languange' or 'rake gettext:add_languange[eo]'"
      next
    end
    pot = File.join(locale_path, "#{text_domain}.pot")
    if !File.exists? pot
      puts "You don't have a pot file yet, you probably should run 'rake gettext:find' at least once. Tried '#{pot}'."
      next
    end

    # Create the po file for the new language.
    new_po = File.join(locale_path, "#{language}.po")
    puts "Initializing #{new_po} from #{pot}."
    system "#{ENV['MSGINIT_PATH'] || 'msginit'} --locale=#{language} --input=#{pot} --output=#{new_po}"
  end

end
