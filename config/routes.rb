ActionController::Routing::Routes.draw do |map|
  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  map.resources :projects, :member => { :activity => :get, :roadmap => :get, :changelog => :get, :list_files => :get, :settings => :get }, :shallow => true do |project|
    project.resources :issues, :member => { :preview => :post }
    project.resources :news, :member => { :preview => :post }
    project.resources :documents
    project.resources :boards
    project.resources :timelog, :collection => { :details => :get, :report => :get }
    project.resources :reports, :collection => { :issue_report => :get }
    project.resources :members
  end

  map.resources :account, :member => { :my => :get }

  map.resources :news

  map.resources :versions

  map.resources :watchers, :collection => { :watch => :post, :unwatch => :post }

  map.resource :wiki

  map.resources :repositories

  map.resources :issues, :collection => { :calendar => :get, :gantt => :get, :preview => :post } do |project|
    project.resources :relations
    project.resources :statuses
  end

  map.resources :boards do |project|
    project.resources :messages, :as => 'topics', :member => { :preview => :post }
  end

  map.resources :attachments

  map.resources :enumerations

  map.home '', :controller => 'welcome'
  map.signin 'login', :controller => 'account', :action => 'login'
  map.signout 'logout', :controller => 'account', :action => 'logout'
  
  map.connect 'wiki/:id/:page/:action', :controller => 'wiki', :page => nil
  map.connect 'roles/workflow/:id/:role_id/:tracker_id', :controller => 'roles', :action => 'workflow'
  map.connect 'help/:ctrl/:page', :controller => 'help'
  #map.connect ':controller/:action/:id/:sort_key/:sort_order'
  
  map.connect 'issues/:issue_id/relations/:action/:id', :controller => 'issue_relations'
  map.connect 'projects/:project_id/issues/:action', :controller => 'issues'
  map.connect 'projects/:project_id/news/:action', :controller => 'news'
  map.connect 'projects/:project_id/documents/:action', :controller => 'documents'
  map.connect 'projects/:project_id/boards/:action/:id', :controller => 'boards'
  map.connect 'projects/:project_id/timelog/:action/:id', :controller => 'timelog', :project_id => /.+/
  map.connect 'boards/:board_id/topics/:action/:id', :controller => 'messages'

  map.with_options :controller => 'repositories' do |omap|
    omap.repositories_show 'repositories/browse/:id/*path', :action => 'browse'
    omap.repositories_changes 'repositories/changes/:id/*path', :action => 'changes'
    omap.repositories_diff 'repositories/diff/:id/*path', :action => 'diff'
    omap.repositories_entry 'repositories/entry/:id/*path', :action => 'entry'
    omap.repositories_entry 'repositories/annotate/:id/*path', :action => 'annotate'
    omap.repositories_revision 'repositories/revision/:id/:rev', :action => 'revision'
  end
  
  map.connect 'attachments/:id', :controller => 'attachments', :action => 'show', :id => /\d+/
  map.connect 'attachments/:id/:filename', :controller => 'attachments', :action => 'show', :id => /\d+/, :filename => /.*/
  map.connect 'attachments/download/:id/:filename', :controller => 'attachments', :action => 'download', :id => /\d+/, :filename => /.*/
   
  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

 
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
