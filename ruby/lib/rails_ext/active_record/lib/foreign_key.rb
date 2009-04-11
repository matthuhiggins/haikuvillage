module ActiveRecord
  module ConnectionAdapters
    class AbstractAdapter
      def supports_foreign_keys?
        false
      end
      
      # Adds a new foreign key to the +from_table+, referencing the primary key of +to_table+
      #
      # The foreign key will be named after the from and to tables unless you pass
      # <tt>:name</tt> as an option.
      #
      # ===== Examples
      # ====== Creating a foreign key
      #  add_foreign_key(:comments, :posts)
      # generates
      #  ALTER TABLE `comments` ADD CONSTRAINT
      #     `comments_post_id_fk` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`)
      # 
      # ====== Removing a foreign key
      #  remove_foreign_key(:comments, :posts)
      # generates
      #  ALTER TABLE `comments` DROP FOREIGN KEY `comments_post_id_fk`
      # 
      # 
      # === Supported options
      # [:column]
      #   Specify the column name on the from_table that references the to_table. By default this is guessed
      #   to be the singular name of the to_table with "_id" suffixed. So a to_table of :posts will use "post_id"
      #   as the default <tt>:column</tt>.
      # [:name]
      #   Specify the name of the foreign key constraint. This defaults to use the from table and column.
      # [:dependent]
      #   If set to <tt>:delete</tt>, the associated records in from_table are deleted when records in to_table table are deleted.
      #   If set to <tt>:nullify</tt>, the from_table column is set to +NULL+.
      def add_foreign_key(from_table, to_table, options = {})
      end
    end
  end
end

module ActiveRecord
  module ConnectionAdapters
    class MysqlAdapter < AbstractAdapter
      def supports_foreign_keys?
        true
      end
      
      def add_foreign_key(from_table, to_table, options = {})
        from_column  = options[:column] || "#{to_table.to_s.singularize}_id"
        dependency = dependency_sql(options[:dependent])

        execute %{
            alter table #{from_table}
            add constraint #{foreign_key_name(from_table, from_column, options)}
            foreign key (#{from_column}) references #{to_table}(id)
            #{dependency}
        }
      end
      
      def remove_foreign_key(from_table, to_table, options = {})
        execute %{
          alter table #{from_table}
          drop foreign key #{foreign_key_name(from_table, from_column, options)}"
        }
      end
      
      def change_foreign_key(*args)
        remove_foreign_key(*args)
        add_foreign_key(*args)
      end
      
      private
        def foreign_key_name(table_name, column, options)
          if options[:name]
            options[:name]
          else
            "#{table_name}_#{column}_fk"
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

module ActiveRecord
  module ConnectionAdapters
    class TableDefinition
      Table.class_eval do
        # In addition to the default behavior of 'references, adds a
        # foreign key to the table. See SchemaStatements#add_foreign_key
        def references_with_foreign_key(*args)
          options = args.extract_options!
          references_without_foreign_key(*(args.dup << options))
          args.each do |column|
            foreign_key(column.to_s.pluralize, options)
          end
        end
        alias_method_chain :references, :foreign_key
        
        def foreign_key(*args)
          options = args.extract_options!
          args.each do |table|
            @base.add_foreign_key(@table_name, table, options)
          end
        end
        
        # In addition to the default behavior of 'remove_references', removes the
        # foreign key from the table. See SchemaStatements#add_foreign_key
        def remove_references_with_foreign_key(*args)
          options = args.extract_options!
          remove_references_without_foreign_key(*(args.dup << options))
          args.each do |column|
            @base.remove_foreign_key(@table_name, column.to_s.pluralize, options)
          end
        end
        alias_method_chain :remove_references, :foreign_key
      end
    end
  end
end