class Membership < ActiveRecord::Base
  APPLIED = 1
  INVITED = 2
  MEMBER  = 3
  ADMIN   = 4
  CONTRIBUTORS = [MEMBER, ADMIN]
  NON_CONTRIBUTERS = [APPLIED, INVITED, nil]

  before_save :update_counter_cache
  before_destroy :decrement_counter_cache

  belongs_to :group
  belongs_to :author
  
  # default_scope :conditions => {:standing => [MEMBER, ADMIN]}
  named_scope :applications, :conditions => {:standing => APPLIED}
  named_scope :invitations, :conditions => {:standing => INVITED}
  named_scope :members, :conditions => {:standing => MEMBER}
  named_scope :admins, :conditions => {:standing => ADMIN}
  named_scope :contributors, :conditions => {:standing => CONTRIBUTORS}
  
  private
    def update_counter_cache
      if author_lost_contribution_standing?
        group.decrement!(:memberships_count)
      elsif author_gained_contribution_standing?
        group.increment!(:memberships_count)
      end
    end
    
    def decrement_counter_cache
      group.decrement!(:memberships_count) if CONTRIBUTORS.include?(standing)
    end
    
    def author_lost_contribution_standing?
      standing_changed? &&
        CONTRIBUTORS.include?(standing_was) &&
        NON_CONTRIBUTERS.include?(standing)
    end
    
    def author_gained_contribution_standing?
      standing_changed? &&
        NON_CONTRIBUTERS.include?(standing_was) &&
        CONTRIBUTORS.include?(standing)
    end
end