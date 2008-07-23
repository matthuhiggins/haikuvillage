module ActiveRecord
  module ConnectionAdapters
    class MysqlAdapter < AbstractAdapter
      alias :original_native_database_types :native_database_types

      def native_database_types
        original_native_database_types.update(
            :big_integer  => { :name => "bigint", :limit => 21 })
      end
    end
  end
end