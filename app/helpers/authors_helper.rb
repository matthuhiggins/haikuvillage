module AuthorsHelper
  def author_cloud(authors)
    font_sizes = {}
    authors.sort { |author1, author2| author1.favorited_count_total <=> author2.favorited_count_total }.each_with_index do |author, index|
      font_sizes[author.username] = number_to_percentage(80 + (120 * (index.to_f / authors.size)), :precision => 0)
    end
    
    sorted_by_name = authors.sort { |author1, author2| author1.username <=> author2.username }
    
    sorted_by_name.map do |author|
      link_to_author author, {:style => "font-size: #{font_sizes[author.username]}"}
    end.join(' ')
  end
  
  def author_list(authors)
    authors.map { |author| link_to_author author }.join(', ')
  end
  
  def link_to_author(author, html_options = {})
    link_to(author.username, author_path(author.username), html_options)
  end  
end