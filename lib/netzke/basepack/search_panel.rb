module Netzke
  module Basepack
    # == Configuration
    # +load_last_preset+ - on load, tries to load the latest saved preset
    class SearchPanel < Base

      js_base_class "Ext.form.FormPanel"

      js_properties(
        :padding => 5
      )

      js_include :condition_field

      js_mixin :search_panel

      js_property :attribute_operators_map, {
        :integer => [
          ["eq", I18n.t('netzke.basepack.search_panel.equals')],
          ["gt", I18n.t('netzke.basepack.search_panel.greater_than')],
          ["lt", I18n.t('netzke.basepack.search_panel.less_than')]
        ],
        :text => [
          ["contains", I18n.t('netzke.basepack.search_panel.contains')] # same as matches => %string%
        ],
        :string => [
          ["contains", I18n.t('netzke.basepack.search_panel.contains')], # same as matches => %string%
          ["matches", I18n.t('netzke.basepack.search_panel.matches')]
        ],
        :boolean => [
          ["is_any", I18n.t('netzke.basepack.search_panel.is_true')],
          ["is_true", I18n.t('netzke.basepack.search_panel.is_true')],
          ["is_false", I18n.t('netzke.basepack.search_panel.is_false')]
        ],
        :datetime => [
          ["eq", I18n.t('netzke.basepack.search_panel.date_equals')],
          ["gt", I18n.t('netzke.basepack.search_panel.after')],
          ["lt", I18n.t('netzke.basepack.search_panel.before')]
        ]
      }

      action :clear_all, :icon => :cross
      action :reset, :icon => :application_form
      # action :add_condition, :icon => :add

      action :save_preset, :icon => :disk
      action :delete_preset, :icon => :cross

      action :apply, :icon => :accept

      # Builds default query search panel, where each field is presented
      def default_query
        data_class.column_names.map do |c|
          column_type = data_class.columns_hash[c].type
          operator = (self.class.js_property(:attribute_operators_map)[column_type] || []).first.try(:fetch, 0) || "matches"
          {:attr => c, :attr_type => column_type, :operator => operator}
        end
      end

      def data_class
        @data_class ||= config[:model].constantize
      end

      def js_config
        super.merge(
          :attrs => attributes,
          :attrs_hash => data_class.column_names.inject({}){ |hsh,c| hsh.merge(c => data_class.columns_hash[c].type) },
          :query => (config[:load_last_preset] ? last_preset.try(:fetch, "query") : config[:query]) || [],
          # :bbar => (config[:bbar] || []) + [:clear_all.action, :reset.action, "->",
            # I18n.t('netzke.basepack.search_panel.presets'),
            # {
            #   :xtype => "combo",
            #   :triggerAction => "all",
            #   :value => super[:load_last_preset] && last_preset.try(:fetch, "name"),
            #   :store => state[:presets].blank? ? [[[], ""]] : state[:presets].map{ |s| [s["query"], s["name"]] },
            #   :ref => "../presetsCombo",
            #   :listeners => {:before_select => {
            #     :fn => "function(combo, record){
            #       var form = Ext.getCmp('#{global_id}');
            #       form.removeAll();
            #       form.buildFormFromQuery(record.data.field1);
            #     }".l
            #   }}
            # }, :save_preset.action, :delete_preset.action
          # ]
        )
      end

      def attributes
        data_class.column_names.map do |name|
          [name, data_class.human_attribute_name(name)]
        end
      end

      def last_preset
        (state[:presets] || []).last
      end

    end
  end
end
