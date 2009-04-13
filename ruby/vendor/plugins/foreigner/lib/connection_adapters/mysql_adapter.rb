module ActiveRecord
  module ConnectionAdapters
    class MysqlAdapter < AbstractAdapter
      def supports_foreign_keys?
        true
      end
      
      def add_foreign_key(from_table, to_table, options = {})
        column  = options[:column] || "#{to_table.to_s.singularize}_id"
        dependency = dependency_sql(options[:dependent])
        
        execute %{
          alter table #{from_table}
          add constraint #{foreign_key_name(from_table, column, options)}
          foreign key (#{column}) references #{to_table}(id)
          #{dependency}
        }
      end

      def remove_foreign_key(table, options)        
        if Hash === options
          foreign_key_name = foreign_key_name(table, options[:column], options)
        else
          foreign_key_name = foreign_key_name(table, "#{options.to_s.singularize}_id")
        end

        execute "alter table #{table} drop foreign key #{foreign_key_name}"
      end

      private
        def foreign_key_name(table, column, options = {})
          if options[:name]
            options[:name]
          else
            "#{table}_#{column}_fk"
          end
        end

        def dependency_sql(dependency)
          case dependency
            when :nullify then "on delete set null"
            when :delete  then "on delete cascade"
            else ""
          end
        end
    end
  end
end
