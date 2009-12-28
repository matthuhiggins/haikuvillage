class FixSubjectNames < ActiveRecord::Migration
  def self.up
    Subject.all.each do |subject|
      subject.update_attribute(:name, subject.name.gsub(/[^\w| ]/, '').chomp)
    end
    
    Haiku.all.each do |haiku|
      next if haiku.subject_name.nil?
      haiku.update_attribute(:subject_name, haiku.subject_name)
    end
  end
  
  def self.down
  end
end
