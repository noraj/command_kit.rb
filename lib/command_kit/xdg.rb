require 'command_kit/command_name'
require 'command_kit/env/home'

module CommandKit
  #
  # Provides access to [XDG directories].
  #
  # * `~/.config`
  # * `~/.local/share`
  # * `~/.cache`
  #
  # [XDG directories]: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
  #
  module XDG
    include CommandName
    include Env::Home

    module ModuleMethods
      #
      # Extends {ClassMethods}.
      #
      # @param [Class, Module] context
      #   The class or module which is including {XDG}.
      #
      def included(context)
        super(context)

        if context.class == Module
          context.extend ModuleMethods
        else
          context.extend ClassMethods
        end
      end
    end

    extend ModuleMethods

    module ClassMethods
      #
      # Gets or sets the XDG sub-directory name used by the command.
      #
      # @param [#to_s, nil] new_namespace
      #   If a new_namespace argument is given, it will set the class'es
      #   {#xdg_namespace} string.
      #
      # @return [String]
      #   The class'es or superclass'es {#xdg_namespace}. Defaults to
      #   {CommandName::ClassMethods#command_name} if no {#xdg_namespace} has
      #   been defined.
      #
      def xdg_namespace(new_namespace=nil)
        if new_namespace
          @xdg_namespace = new_namespace.to_s
        else
          @xdg_namespace || (superclass.xdg_namespace if superclass.kind_of?(ClassMethods)) || command_name
        end
      end
    end

    # The `~/.config/<xdg_namespace>` directory.
    #
    # @return [String]
    attr_reader :config_dir

    # The `~/.local/share/<xdg_namespace>` directory.
    #
    # @return [String]
    attr_reader :local_share_dir

    # The `~/.cache/<xdg_namespace>` directory.
    #
    # @return [String]
    attr_reader :cache_dir

    #
    # Initializes {#config_dir}, {#local_share_dir}, and {#cache_dir}.
    #
    # @param [Hash{Symbol => Object}] kwargs
    #   Additional keyword arguments.
    #
    # @note
    #   If the `$XDG_CONFIG_HOME` env variable is set, then {#config_dir} will
    #   be initialized to effectively `$XDG_CONFIG_HOME/<xdg_namespace>`.
    #   Otherwise {#config_dir} will be initialized to
    #   `~/.config/<xdg_namespace>`.
    #
    # @note
    #   If the `$XDG_DATA_HOME` env variable is set, then {#local_share_dir}
    #   will be initialized to effectively `$XDG_DATA_HOME/<xdg_namespace>`.
    #   Otherwise {#local_share_dir} will be initialized to
    #   `~/.local/share/<xdg_namespace>`.
    #
    # @note
    #   If the `$XDG_CACHE_HOME` env variable is set, then {#cache_dir} will
    #   be initialized to effectively `$XDG_CACHE_HOME/<xdg_namespace>`.
    #   Otherwise {#cache_dir} will be initialized to
    #   `~/.cache/<xdg_namespace>`.
    #
    def initialize(**kwargs)
      super(**kwargs)

      xdg_config_home = env.fetch('XDG_CONFIG_HOME') do
        File.join(home_dir,'.config')
      end

      @config_dir = File.join(xdg_config_home,xdg_namespace)

      xdg_data_home = env.fetch('XDG_DATA_HOME') do
        File.join(home_dir,'.local','share')
      end

      @local_share_dir = File.join(xdg_data_home,xdg_namespace)

      xdg_cache_home = env.fetch('XDG_CACHE_HOME') do
        File.join(home_dir,'.cache')
      end

      @cache_dir = File.join(xdg_cache_home,xdg_namespace)
    end

    #
    # @see ClassMethods#xdg_namespace
    #
    def xdg_namespace
      self.class.xdg_namespace
    end
  end
end
