ActionController::Routing::Routes.draw do |map|
  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Allow Redmine plugins to map routes and potentially override them
  Rails.plugins.each do |plugin|
    map.from_plugin plugin.name.to_sym
  end

  map.home '', :controller => 'welcome'
  map.signin 'login', :controller => 'account', :action => 'login'
  map.signout 'logout', :controller => 'account', :action => 'logout'
  
  map.mail_handler 'mail_handler', :controller => 'mail_handler', :action => 'index'

  map.with_options :controller => 'repositories' do |omap|
    omap.repositories_show 'repositories/browse/:id/*path', :action => 'browse'
    omap.repositories_changes 'repositories/changes/:id/*path', :action => 'changes'
    omap.repositories_diff 'repositories/diff/:id/*path', :action => 'diff'
    omap.repositories_entry 'repositories/entry/:id/*path', :action => 'entry'
    omap.repositories_entry 'repositories/annotate/:id/*path', :action => 'annotate'
    omap.repositories_revision 'repositories/revision/:id/:rev', :action => 'revision'
  end
  
  #map.connect 'attachments/:id', :controller => 'attachments', :action => 'show', :id => /\d+/
  map.connect 'attachments/:id/:filename', :controller => 'attachments', :action => 'show', :id => /\d+/, :filename => /.*/
  map.connect 'attachments/download/:id', :controller => 'attachments', :action => 'download', :id => /\d+/
  map.connect 'attachments/download/:id/:filename', :controller => 'attachments', :action => 'download', :id => /\d+/, :filename => /.*/

  map.resources :projects, :collection => { :activity => :get, :add => :get }, :member => { :activity => :get, :roadmap => :get, :changelog => :get, :destroy => :get, :list_files => :get, :settings => :any, :modules => :any, :archive => :post, :archive => :post, :unarchive => :post, :add_file => :any, :add_version => :any, :add_issue_category => :any } do |project|
    project.resources :issues, :new => { :preview => :post }, :member => { :preview => :post, :move => :any, :reply => :post, :quote => :post, :destroy_attachment => :post, :update_from => :post }, :collection => { :calendar => :get, :gantt => :get, :context_menu => :any, :changes => :get, :bulk_edit => :any, :move => :any, :bulk_destroy => :post }
    project.resources :news, :new => { :preview => :post }, :member => { :preview => :post, :add_comment => :post, :destroy_comment => :post }
    project.resources :documents
    project.resources :boards
    project.resources :timelog, :collection => { :details => :get, :report => :any }, :except => [:show]
    project.resources :reports, :collection => { :issue_report => :get }
    project.resources :members
    project.resources :queries
    project.resources :wikis
  end
  
  map.resources :documents do |document|
    document.resources :attachment
  end
  
  map.resources :versions, :member => { :destroy_attachment => :post }, :collection => { :status_by => :get }, :except => [:create, :index]
  
  map.resources :timelog, :collection => { :details => :get, :report => :get}, :except => [:show]
  
  map.resources :documents, :member => { :add_attachment => :post, :destroy_attachment => :post}
  
  map.resources :issues, :new => { :preview => :post }, :member => { :preview => :post, :move => :any, :reply => :post, :quote => :post, :destroy_attachment => :post, :update_from => :post }, :collection => { :calendar => :get, :gantt => :get, :context_menu => :any, :changes => :get, :bulk_edit => :any, :move => :any, :bulk_destroy => :post }
  
  map.resources :journals, :only => :update
  
  map.resources :reports, :collection => { :issue_report => :post }
  
  map.resources :members
  
  map.resources :issue_categories, :except => [:index, :show, :create]
  
  map.resources :issue_statuses, :collection => { :move => :post }
  
  map.resources :issue_relations, :except => [:index, :show, :update]
  
  map.resources :custom_fields, :member => { :list => :get, :move => :post }, :except => :show
  
  map.resources :news, :new => { :preview => :post }, :member => { :preview => :post, :add_comment => :post, :destroy_comment => :post }

  map.resources :account, :collection => { :login => :any, :logout => :get, :register => :any, :lost_password => :any, :activate => :get }, :only => :show

  map.resources :admin, :collection => { :projects => :get, :info => :get, :test_email => :get, :default_configuration => :post, :plugins => :get }, :only => :index

  map.resources :users, :collection => { :add => :get, :list => :get }, :member => { :destroy_membership => :post, :edit_membership => :post }
  
  map.resources :roles, :collection => { :report => :any, :workflow => :any, :move => :post, :list => :get }
  
  map.resource :settings, :collection => { :plugin => :any }
  
  map.resources :trackers, :collection => { :list => :get, :move => :post }

  map.resources :search, :only => :index
  
  map.resources :queries

  map.resources :my, :collection => { :password => :any, :account => :any, :page => :get, :add_block => :post, :order_blocks => :post, :page_layout => :get, :page_layout_save => :post, :remove_block => :post, :reset_rss_key => :post }, :except => [:index, :show, :create, :update, :destroy]
  
  map.resources :watchers, :collection => { :watch => :post, :unwatch => :post }, :only => [:new, :create] 

  map.resource :wiki
  
  map.resources :wikis, :only => [:edit, :update, :destroy] 

  map.resources :repositories, :member => { :browse => :get, :changes => :get, :revision => :get, :revisions => :get, :entry => :get, :annotate => :get, :diff => :get, :stats => :get, :graph => :get, :committers => :any }, :except => :index
  
  map.resources :attachments, :member => { :download => :get }, :only => :show

  map.resources :auth_sources, :member => { :list => :get, :test_connection => :post }

  map.resources :enumerations, :member => { :move => :post }
  
  map.resource :workflows

  map.resources :issues do |issue|
    issue.resources :issue_relations, :as => 'relations'
    issue.resources :issue_statuses
    issue.resources :attachment
  end

  map.resources :boards do |board|
    board.resources :messages, :as => 'topics', :new => { :preview => :post }, :member => { :preview => :post, :reply => :post, :quote => :post }, :except => :index
  end
  
  map.connect 'wiki/:id/:page/:action', :controller => 'wiki', :page => nil
  map.connect 'roles/workflow/:id/:role_id/:tracker_id', :controller => 'roles', :action => 'workflow'
  map.connect 'help/:ctrl/:page', :controller => 'help'
  #map.connect ':controller/:action/:id/:sort_key/:sort_order'
  
  #map.connect 'issues/:issue_id/relations/:action/:id', :controller => 'issue_relations'
  #map.connect 'projects/:project_id/issues/:action', :controller => 'issues'
  #map.connect 'projects/:project_id/news/:action', :controller => 'news'
  #map.connect 'projects/:project_id/documents/:action', :controller => 'documents'
  #map.connect 'projects/:project_id/boards/:action/:id', :controller => 'boards'
  #map.connect 'projects/:project_id/timelog/:action/:id', :controller => 'timelog', :project_id => /.+/
  #map.connect 'boards/:board_id/topics/:action/:id', :controller => 'messages'
   
  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  #map.connect ':controller/service.wsdl', :action => 'wsdl'

 
  # Install the default route as the lowest priority.
  #map.connect ':controller/:action/:id'
end
