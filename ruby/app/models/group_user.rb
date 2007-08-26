class GroupUser < ActiveRecord::Base
  belongs_to :group, :foreign_key => 'group_id'
  belongs_to :user, :foreign_key => 'user_id'
end