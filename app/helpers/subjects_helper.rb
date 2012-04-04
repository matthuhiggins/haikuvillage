module SubjectsHelper
  def subject_cloud(subjects)
    font_sizes = {}
    subjects.sort { |subject1, subject2| subject1.haikus_count_total <=> subject2.haikus_count_total }.each_with_index do |subject, index|
      font_sizes[subject.name] = number_to_percentage(80 + (120 * (index.to_f / subjects.size)), :precision => 0)
    end
    
    sorted_by_name = subjects.sort { |subject1, subject2| subject1.name <=> subject2.name }
    
    sorted_by_name.map do |subject|
      link_to_subject subject, {:style => "font-size: #{font_sizes[subject.name]}"}
    end.join(' ').html_safe
  end
  
  def subject_list(subjects)
    subjects.map { |subject| link_to_subject subject }.join(', ').html_safe
  end
  
  def link_to_subject(subject, html_options = {})
    subject_name = subject.is_a?(String) ? subject : subject.name
    link_to truncate(subject_name, :length => 24), subject, html_options
  end
end