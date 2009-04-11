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
      # ====== Creating a simple index
      #  add_foreign_key(:comments, :posts)
      # generates
      #  ALTER TABLE `comments` ADD CONSTRAINT
      #     `comments_post_id_fk` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`)
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
        foreign_key_name = options[:name] || "#{from_table}_#{from_column}_fk"
        dependency = dependency_sql(options[:dependent])

        execute %{alter table #{from_table}
            add constraint #{foreign_key_name}
            foreign key (#{from_column})
            references #{to_table}(id)
            #{dependency}
        }
      end
      
      private
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