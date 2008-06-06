module SubjectsHelper
  def link_to_subject(subject)
    link_to subject.name, :action => :show, :id => subject.name
  end
end