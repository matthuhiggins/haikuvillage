module HaikuRecord
  module ForeignKey
    def add_foreign_key(from_table, from_column, to_table, options = {})
      constraint_name = options[:name] || get_constraint_name(from_table, from_column, :fk)
      
      execute %{alter table #{from_table}
          add constraint #{constraint_name}
          foreign key (#{from_column})
          references #{to_table}(id)
          #{dependent_action(options)}}
    end
    
    def remove_foreign_key(from_table, from_columns)
      execute %{alter table #{from_table}
          drop foreign key #{get_constraint_name(from_table, from_column, :fk)}}
    end

    private
      def get_constraint_name(table, column, type)
        %{#{table}_#{column}_#{type}}
      end
      
      def dependent_action(options)
        if options[:dependent]
          " on delete #{options[:dependent] == :nullify ? 'set null' : 'cascade'} "
        else
          ""
        end
      end
  end
end