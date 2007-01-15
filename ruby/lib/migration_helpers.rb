module MigrationHelpers

  def add_foreign_key(from_table, from_column, to_table)
    execute %{alter table #{from_table}
        add constraint #{get_constraint_name(from_table, from_column, :foreign_key)}
        foreign key (#{from_column})
        references #{to_table}(id)}
  end
  
  def remove_foreign_key(from_table, from_column)
    execute %{alter table #{from_table}
        drop foreign key #{get_constraint_name(from_table, from_column, :foreign_key)}}
  end
  
  private
  def remove_constraint(from_table, from_column, type)
    execute %{alter table #{from_table}
        drop constraint #{get_constraint_name(from_table, from_column, type)}}
  end
    
  def get_constraint_name(table, column, type)
    %{#{table}_#{column}_#{type}}
  end
  
end