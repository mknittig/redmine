# redMine - project management software
# Copyright (C) 2006  Jean-Philippe Lang
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

class IssueStatusesController < ApplicationController
  #before_filter :authorize, :only => [:index]
  before_filter :require_admin, :except => [:index]

  #verify :method => :post, :only => [ :destroy, :create, :update, :move ],
  #       :redirect_to => { :action => :list }
         
  def index
    respond_to do |format|
      format.html do
        if User.current.admin?
          list
          render :action => 'list' unless request.xhr?
        else
          render_403
        end
      end
      format.xml do
        issue_statuses = IssueStatus.find(:all)
        render :xml => issue_statuses.to_xml
      end
    end
    
  end

  def list
    @issue_status_pages, @issue_statuses = paginate :issue_statuses, :per_page => 25, :order => "position"
    render :action => "list", :layout => false if request.xhr?
  end

  def new
    @issue_status = IssueStatus.new
  end

  def create
    @issue_status = IssueStatus.new(params[:issue_status])
    if @issue_status.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action => 'index'
    else
      render :action => 'list'
    end
  end

  def edit
    @issue_status = IssueStatus.find(params[:id])
  end

  def update
    edit
    if @issue_status.update_attributes(params[:issue_status])
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action => 'index'
    else
      render :action => 'list'
    end
  end
  
  def move
    @issue_status = IssueStatus.find(params[:id])
    case params[:position]
    when 'highest'
      @issue_status.move_to_top
    when 'higher'
      @issue_status.move_higher
    when 'lower'
      @issue_status.move_lower
    when 'lowest'
      @issue_status.move_to_bottom
    end if params[:position]
    redirect_to :action => 'index'
  end

  def destroy
    IssueStatus.find(params[:id]).destroy
    redirect_to :action => 'index'
  rescue
    flash[:error] = "Unable to delete issue status"
    redirect_to :action => 'index'
  end  	
end
