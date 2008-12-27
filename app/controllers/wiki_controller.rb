# redMine - project management software
# Copyright (C) 2006-2007  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require 'diff'

class WikiController < ApplicationController
  before_filter :find_wiki, :authorize
  before_filter :find_existing_page, :only => [:rename, :protect, :history, :diff, :annotate, :add_attachment, :destroy]
  
  #verify :method => :post, :only => [:destroy, :protect], :redirect_to => { :action => :index }

  helper :attachments
  include AttachmentsHelper   
  
  # display a page (in editing mode if it doesn't exist)
  def show
    page_title = params[:id]
    @page = @wiki.find_or_new_page(page_title)
    if @page.new_record?
      if User.current.allowed_to?(:edit_wiki_pages, @project)
        edit
        render :action => 'edit'
      else
        render_404
      end
      return
    end
    if params[:version] && !User.current.allowed_to?(:view_wiki_edits, @project)
      # Redirects user to the current version if he's not allowed to view previous versions
      redirect_to :version => nil
      return
    end
    @content = @page.content_for_version(params[:version])
    if params[:export] == 'html'
      export = render_to_string :action => 'export', :layout => false
      send_data(export, :type => 'text/html', :filename => "#{@page.title}.html")
      return
    elsif params[:export] == 'txt'
      send_data(@content.text, :type => 'text/plain', :filename => "#{@page.title}.txt")
      return
    end
	@editable = editable?
    render :action => 'show'
  end
  
  def index
    show
  end
  
  # edit an existing page or a new one
  def edit
    @page = @wiki.find_or_new_page(params[:id])    
    return render_403 unless editable?
    @page.content = WikiContent.new(:id => @page) if @page.new_record?
    
    @content = @page.content_for_version(params[:version])
    @content.text = initial_page_content(@page) if @content.text.blank?
    # don't keep previous comment
    @content.comments = nil
    if request.get?
      # To prevent StaleObjectError exception when reverting to a previous version
      @content.version = @page.content.version
    end
  end
  
  def update
    edit
    if !@page.new_record? && @content.text == params[:content][:text]
      # don't save if text wasn't changed
      redirect_to :action => 'show', :project_id => @project, :id => @page.title
      return
    end
    #@content.text = params[:content][:text]
    #@content.comments = params[:content][:comments]
    @content.attributes = params[:content]
    @content.author = User.current
    # if page is new @page.save will also save content, but not if page isn't a new record
    if (@page.new_record? ? @page.save : @content.save)
      redirect_to :action => 'show', :project_id => @project, :id => @page.title
    end
    rescue ActiveRecord::StaleObjectError
      # Optimistic locking exception
      flash[:error] = l(:notice_locking_conflict)
  end
  
  # rename a page
  def rename
    return render_403 unless editable?
    @page.redirect_existing_links = true
    # used to display the *original* title if some AR validation errors occur
    @original_title = @page.pretty_title
    if request.post? && @page.update_attributes(params[:wiki_page])
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action => 'show', :project_id => @project, :id => @page.title
    end
  end
  
  def protect
    @page.update_attribute :protected, params[:protected]
    redirect_to :action => 'show', :project_id => @project, :id => @page.title
  end

  # show page history
  def history
    @version_count = @page.content.versions.count
    @version_pages = Paginator.new self, @version_count, per_page_option, params['p']
    # don't load text    
    @versions = @page.content.versions.find :all, 
                                            :select => "id, author_id, comments, updated_on, version",
                                            :order => 'version DESC',
                                            :limit  =>  @version_pages.items_per_page + 1,
                                            :offset =>  @version_pages.current.offset

    render :layout => false if request.xhr?
  end
  
  def diff
    @diff = @page.diff(params[:version], params[:version_from])
    render_404 unless @diff
  end
  
  def annotate
    @annotate = @page.annotate(params[:version])
    render_404 unless @annotate
  end
  
  # remove a wiki page and its history
  def destroy
    return render_403 unless editable?
    @page.destroy
    redirect_to :action => 'special', :project_id => @project, :id => 'Page_index'
  end

  # display special pages
  def special
    page_title = params[:id].downcase
    case page_title
    # show pages index, sorted by title
    when 'page_index', 'date_index'
      # eager load information about last updates, without loading text
      @pages = @wiki.pages.find :all, :select => "#{WikiPage.table_name}.*, #{WikiContent.table_name}.updated_on",
                                      :joins => "LEFT JOIN #{WikiContent.table_name} ON #{WikiContent.table_name}.page_id = #{WikiPage.table_name}.id",
                                      :order => 'title'
      @pages_by_date = @pages.group_by {|p| p.updated_on.to_date}
      @pages_by_parent_id = @pages.group_by(&:parent_id)
    # export wiki to a single html file
    when 'export'
      @pages = @wiki.pages.find :all, :order => 'title'
      export = render_to_string :action => 'export_multiple', :layout => false
      send_data(export, :type => 'text/html', :filename => "wiki.html")
      return      
    else
      # requested special page doesn't exist, redirect to default page
      redirect_to :action => 'index', :project_id => @project, :id => nil and return
    end
    render :action => "special_#{page_title}"
  end
  
  def preview
    page = @wiki.find_page(params[:id])
    # page is nil when previewing a new page
    return render_403 unless page.nil? || editable?(page)
    if page
      @attachements = page.attachments
      @previewed = page.content
    end
    @text = params[:content][:text]
    render :partial => 'common/preview'
  end

  def add_attachment
    return render_403 unless editable?
    attach_files(@page, params[:attachments])
    redirect_to :action => 'show', :id => @page.title
  end

private
  
  def find_wiki
    @project = Project.find(params[:project_id])
    @wiki = @project.wiki
    render_404 unless @wiki
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  # Finds the requested page and returns a 404 error if it doesn't exist
  def find_existing_page
    @page = @wiki.find_page(params[:id])
    render_404 if @page.nil?
  end
  
  # Returns true if the current user is allowed to edit the page, otherwise false
  def editable?(page = @page)
    page.editable_by?(User.current)
  end

  # Returns the default content of a new wiki page
  def initial_page_content(page)
    helper = Redmine::WikiFormatting.helper_for(Setting.text_formatting)
    extend helper unless self.instance_of?(helper)
    helper.instance_method(:initial_page_content).bind(self).call(page)
  end
end
