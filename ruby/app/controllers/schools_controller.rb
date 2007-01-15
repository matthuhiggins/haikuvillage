class SchoolsController < ApplicationController
  layout "haikus"
  
  # GET /schools
  # GET /schools.xml
  def index
    @schools = School.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @schools.to_xml }
    end
  end

  # GET /schools/1
  # GET /schools/1.xml
  def show
    @school = School.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @school.to_xml }
    end
  end

  # GET /schools/new
  def new
    @school = School.new
  end

  # GET /schools/1;edit
  def edit
    @school = School.find(params[:id])
  end

  # POST /schools
  # POST /schools.xml
  def create
    @school = School.new(params[:school])

    respond_to do |format|
      if @school.save
        #a school always has at least one member
        @school.school_users.create(:user_id => session[:user_id], 
                                    :user_type => "admin")
        
        flash[:notice] = 'School was successfully created.'
        format.html { redirect_to school_url(@school) }
        format.xml  { head :created, :location => school_url(@school) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @school.errors.to_xml }
      end
    end
  end

  # PUT /schools/1
  # PUT /schools/1.xml
  def update
    @school = School.find(params[:id])

    respond_to do |format|
      if @school.update_attributes(params[:school])
        flash[:notice] = 'School was successfully updated.'
        format.html { redirect_to school_url(@school) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @school.errors.to_xml }
      end
    end
  end

  # DELETE /schools/1
  # DELETE /schools/1.xml
  def destroy
    @school = School.find(params[:id])
    @school.destroy

    respond_to do |format|
      format.html { redirect_to schools_url }
      format.xml  { head :ok }
    end
  end
end
