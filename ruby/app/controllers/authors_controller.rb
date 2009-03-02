class AuthorsController < ApplicationController
  def index
    if params[:q]
      render_search(params[:q])
    else
      @active_authors = Author.active.all(:limit => 12)
      @new_authors = Author.brand_new.all(:limit => 12)
      @popular_authors = Author.popular.all(:limit => 40)
    end
  end
  
  def create
    @author = Author.new(params[:author])
    if @author.save
      session[:username] = @author.username
      redirect_to :controller => "journal"
    else
      render "new"
    end
  end

  def show
    respond_to do |f|
      f.html do
        @author = Author.find_by_username!(params[:id])
        @haikus = @author.haikus.recent.paginate({
          :page      => params[:page],
          :per_page  => 10,
          :total_entries => @author.haikus_count_total
        })
      end
      f.atom { render_atom(Author.find_by_username!(params[:id]).recent.all(:limit => 10)) }
    end
  end
  
  def invite
    return if request.get?
    Mailer.deliver_invite(params[:email], current_author)
    flash[:notice] = "The invite has been sent"
    redirect_to journal_path
  end
  
  def forgot
    return if request.get?

    PasswordReset.create(:login => params[:login])
    flash[:notice] = "You will receive an email with instructions."
    redirect_to(login_path)
  rescue ActiveRecord::RecordNotFound
    flash[:notice] = "We could not find an author with #{params[:login]}."
  end

  def reset_password
    @password_reset = PasswordReset.find_by_token!(params[:token])
    if request.post?
      session[:username] = @password_reset.author.username
      @password_reset.destroy
      @password_reset.author.update_attributes(:password => params[:password])
      flash[:notice] = "Your new password has been saved"
      redirect_to(journal_path)
    end
  end
  
  def friends
    @author = Author.find_by_username!(params[:id])
    @friends = @author.friends.recently_updated
  end
  
  private
    def render_search(query)
      if Author.find_by_username(query)
        redirect_to :action => 'show', :id => query
      else
        @authors = Author.all(:limit => 20, :conditions => ["username like ?", "%#{query}%"])
        render 'search'
      end
    end
end