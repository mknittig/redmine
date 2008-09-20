ActionController::Routing::Routes.draw do |map|
  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  map.home '', :controller => 'welcome'
  map.signin 'login', :controller => 'account', :action => 'login'
  map.signout 'logout', :controller => 'account', :action => 'logout'
  
  map.connect 'roles/workflow/:id/:role_id/:tracker_id', :controller => 'roles', :action => 'workflow'
  map.connect 'help/:ctrl/:page', :controller => 'help'
  #map.connect ':controller/:action/:id/:sort_key/:sort_order'
  
  map.connect 'projects/:id/wiki/destroy', :controller => 'wikis', :action => 'destroy', :conditions => {:method => :get}
  map.connect 'projects/:id/wiki/destroy', :controller => 'wikis', :action => 'destroy', :conditions => {:method => :post}
  map.with_options :controller => 'wiki' do |wiki_routes|
    wiki_routes.with_options :conditions => {:method => :get} do |wiki_views|
      wiki_views.connect 'projects/:id/wiki/:page', :action => 'special', :page => /page_index|date_index|export/i
      wiki_views.connect 'projects/:id/wiki/:page', :action => 'index', :page => nil
      wiki_views.connect 'projects/:id/wiki/:page/edit', :action => 'edit'
      wiki_views.connect 'projects/:id/wiki/:page/rename', :action => 'rename'
      wiki_views.connect 'projects/:id/wiki/:page/history', :action => 'history'
      wiki_views.connect 'projects/:id/wiki/:page/diff/:version/vs/:version_from', :action => 'diff'
      wiki_views.connect 'projects/:id/wiki/:page/annotate/:version', :action => 'annotate'
    end
    
    wiki_routes.connect 'projects/:id/wiki/:page/:action', 
      :action => /edit|rename|destroy|preview|protect/,
      :conditions => {:method => :post}
  end
  
  map.with_options :controller => 'messages' do |messages_routes|
    messages_routes.connect 'boards/:board_id/topics/new', :action => 'new', :conditions => {:method => :get}
    messages_routes.connect 'boards/:board_id/topics/new', :action => 'new', :conditions => {:method => :post}
    messages_routes.connect 'boards/:board_id/topics/:id', :action => 'show', :conditions => {:method => :get}
    messages_routes.connect 'boards/:board_id/topics/:id', :action => 'reply', :conditions => {:method => :post}
    messages_routes.connect 'boards/:board_id/topics/:id/edit', :action => 'edit', :conditions => {:method => :get}
    messages_routes.connect 'boards/:board_id/topics/:id/edit', :action => 'edit', :conditions => {:method => :post}
    messages_routes.connect 'boards/:board_id/topics/:id/replies', :action => 'reply', :conditions => {:method => :post}
    messages_routes.connect 'boards/:board_id/topics/:id/destroy', :action => 'destroy', :conditions => {:method => :post}
  end
  map.with_options :controller => 'boards' do |board_routes|
    board_routes.connect 'projects/:project_id/boards', :action => 'index', :conditions => {:method => :get}
    board_routes.connect 'projects/:project_id/boards/new', :action => 'new', :conditions => {:method => :get}
    board_routes.connect 'projects/:project_id/boards', :action => 'new', :conditions => {:method => :post}
    board_routes.connect 'projects/:project_id/boards/:id', :action => 'show', :conditions => {:method => :get}
    board_routes.connect 'projects/:project_id/boards/:id/edit', :action => 'edit', :conditions => {:method => :get}
    board_routes.connect 'projects/:project_id/boards/:id/edit', :action => 'edit', :conditions => {:method => :post}
    board_routes.connect 'projects/:project_id/boards/:id/destroy', :action => 'destroy', :conditions => {:method => :post}
  end
  
  map.with_options :controller => 'documents' do |document_routes|
    document_routes.connect 'projects/:project_id/documents', :action => 'index', :conditions => {:method => :get}
    document_routes.connect 'projects/:project_id/documents/new', :action => 'new', :conditions => {:method => :get}
    document_routes.connect 'projects/:project_id/documents', :action => 'new', :conditions => {:method => :post}
    
    document_routes.connect 'documents/:id', :action => 'show', :conditions => {:method => :get}
    document_routes.connect 'documents/:id/destroy', :action => 'destroy', :conditions => {:method => :post}
    document_routes.connect 'documents/:id/edit', :action => 'edit', :conditions => {:method => :get}
    document_routes.connect 'documents/:id/edit', :action => 'edit', :conditions => {:method => :post}
  end
  
  map.with_options :controller => 'issues' do |issues_routes|
    issues_routes.with_options :conditions => {:method => :get} do |issues_views|
      issues_views.connect 'issues', :action => 'index'
      issues_views.connect 'issues.:format', :action => 'index'
      issues_views.connect 'projects/:project_id/issues.:format', :action => 'index'
      issues_views.connect 'projects/:project_id/issues/new', :action => 'new'
      issues_views.connect 'projects/:project_id/issues/new.:format', :action => 'new'
      issues_views.connect 'projects/:project_id/issues/:copy_from/copy', :action => 'new'
      issues_views.connect 'issues/:id', :action => 'show'
      issues_views.connect 'issues/:id.:format', :action => 'show'
      issues_views.connect 'issues/:id/edit', :action => 'edit'
      issues_views.connect 'issues/:id/edit.:format', :action => 'edit'
      issues_views.connect 'issues/:id/quoted', :action => 'reply'
      issues_views.connect 'issues/:id/move', :action => 'move'
    end
    issues_routes.connect 'projects/:project_id/issues', :action => 'new', :conditions => {:method => :post}
    issues_routes.connect 'issues/:id/:action',
      :action => /edit|move|destroy/,
      :conditions => {:method => :post}
  end
  map.with_options  :controller => 'issue_relations', :conditions => {:method => :post} do |relations|
    relations.connect 'issues/:issue_id/relations/:id', :action => 'new'
    relations.connect 'issues/:issue_id/relations/:id/destroy', :action => 'destroy'
  end
  map.with_options :controller => 'reports', :action => 'issue_report', :conditions => {:method => :get} do |reports|
    reports.connect 'projects/:id/issues/report'
    reports.connect 'projects/:id/issues/report/:detail'
  end
  
  map.with_options :controller => 'news' do |news_routes|
    news_routes.with_options :conditions => {:method => :get} do |news_views|
      news_views.connect 'news', :action => 'index'
      news_views.connect 'projects/:project_id/news', :action => 'index'
      news_views.connect 'projects/:project_id/news.:format', :action => 'index'
      news_views.connect 'news.:format', :action => 'index'
      news_views.connect 'projects/:project_id/news/new', :action => 'new'
      news_views.connect 'news/:id', :action => 'show'
      news_views.connect 'news/:id/edit', :action => 'edit'
    end
    news_routes.with_options do |news_actions|
      news_actions.connect 'projects/:project_id/news', :action => 'new'
      news_actions.connect 'news/:id/edit', :action => 'edit'
      news_actions.connect 'news/:id/destroy', :action => 'destroy'
    end
  end
  
  map.connect 'projects/:id/members/new', :controller => 'members', :action => 'new'
  map.connect 'projects/:id/wiki', :controller => 'wikis', :action => 'edit', :conditions => {:method => :post}
  
  map.with_options :controller => 'projects' do |projects|
    projects.connect 'projects', :action => 'index', :conditions => {:method => :get}
    projects.connect 'projects.:format', :action => 'index', :conditions => {:method => :get}
    projects.connect 'projects/new', :action => 'add', :conditions => {:method => :get}
    projects.connect 'projects', :action => 'add', :conditions => {:method => :post}
    projects.connect 'projects/:id', :action => 'show', :conditions => {:method => :get}
    
    projects.connect 'projects/:id/roadmap', :action => 'roadmap', :conditions => {:method => :get}
    projects.connect 'projects/:id/changelog', :action => 'changelog', :conditions => {:method => :get}
    
    projects.connect 'projects/:id/files', :action => 'list_files', :conditions => {:method => :get}
    projects.connect 'projects/:id/files/new', :action => 'add_file', :conditions => {:method => :get}
    projects.connect 'projects/:id/files/new', :action => 'add_file', :conditions => {:method => :post}
    
    projects.connect 'projects/:id/versions/new', :action => 'add_version', :conditions => {:method => :get}
    projects.connect 'projects/:id/versions/new', :action => 'add_version', :conditions => {:method => :post}

    projects.connect 'projects/:id/categories/new', :action => 'add_issue_category', :conditions => {:method => :get}
    projects.connect 'projects/:id/categories/new', :action => 'add_issue_category', :conditions => {:method => :post}
    
    projects.connect 'projects/:id/settings', :action => 'settings', :conditions => {:method => :get}
    projects.connect 'projects/:id/settings/:tab', :action => 'settings', :conditions => {:method => :get}
    
    projects.with_options :action => 'activity', :conditions => {:method => :get} do |activity|
      activity.connect 'projects/:id/activity'
      activity.connect 'projects/:id/activity.:format'
      activity.connect 'activity'
      activity.connect 'activity.:format'
    end
  end
  
  map.with_options :controller => 'repositories' do |repositories|
    repositories.connect 'projects/:id/repository', :action => 'show', :conditions => {:method => :get}
    repositories.connect 'projects/:id/repository/edit', :action => 'edit', :conditions => {:method => :post}
    repositories.connect 'projects/:id/repository/edit', :action => 'edit', :conditions => {:method => :get}
    repositories.connect 'projects/:id/repository/statistics', :action => 'stats', :conditions => {:method => :get}
    repositories.connect 'projects/:id/repository/revisions', :action => 'revisions', :conditions => {:method => :get}
    repositories.connect 'projects/:id/repository/revisions.:format', :action => 'revisions', :conditions => {:method => :get}
    repositories.connect 'projects/:id/repository/revisions/:rev', :action => 'revision', :conditions => {:method => :get}
    repositories.connect 'projects/:id/repository/revisions/:rev/diff', :action => 'diff', :conditions => {:method => :get}
    repositories.connect 'projects/:id/repository/revisions/:rev/diff.:format', :action => 'diff', :conditions => {:method => :get}

    repositories.connect 'projects/:id/repository/:action/*path', :conditions => {:method => :get}
  end
  
  map.connect 'attachments/:id', :controller => 'attachments', :action => 'show', :id => /\d+/
  map.connect 'attachments/:id/:filename', :controller => 'attachments', :action => 'show', :id => /\d+/, :filename => /.*/
  map.connect 'attachments/download/:id/:filename', :controller => 'attachments', :action => 'download', :id => /\d+/, :filename => /.*/
   

  #left old routes at the bottom for backwards compat
  map.connect 'projects/:project_id/issues/:action', :controller => 'issues'
  map.connect 'projects/:project_id/documents/:action', :controller => 'documents'
  map.connect 'projects/:project_id/boards/:action/:id', :controller => 'boards'
  map.connect 'boards/:board_id/topics/:action/:id', :controller => 'messages'
  map.connect 'wiki/:id/:page/:action', :page => nil, :controller => 'wiki'
  map.connect 'issues/:issue_id/relations/:action/:id', :controller => 'issue_relations'
  map.connect 'projects/:project_id/news/:action', :controller => 'news'  
  map.connect 'projects/:project_id/timelog/:action/:id', :controller => 'timelog', :project_id => /.+/
  map.with_options :controller => 'repositories' do |omap|
    omap.repositories_show 'repositories/browse/:id/*path', :action => 'browse'
    omap.repositories_changes 'repositories/changes/:id/*path', :action => 'changes'
    omap.repositories_diff 'repositories/diff/:id/*path', :action => 'diff'
    omap.repositories_entry 'repositories/entry/:id/*path', :action => 'entry'
    omap.repositories_entry 'repositories/annotate/:id/*path', :action => 'annotate'
    omap.connect 'repositories/revision/:id/:rev', :action => 'revision'
  end
   
  # XML stuff
  map.connect '/versions.:format', :controller => 'versions', :action => 'index', :conditions => {:method => :get} 
  map.connect '/projects/:id/categories.:format', :controller => 'issues_categories', :action => 'index', :conditions => {:method => :get} 
  map.connect '/users.:format', :controller => 'users', :action => 'index', :conditions => {:method => :get} 
  map.connect '/enumerations.:format', :controller => 'enumerations', :action => 'index', :conditions => {:method => :get} 
  map.connect '/projects/:id/members.:format', :controller => 'members', :action => 'index', :conditions => {:method => :get} 
  map.connect '/projects/:id/trackers.:format', :controller => 'trackers', :action => 'index', :conditions => {:method => :get} 
  map.connect '/projects/:id/statuses.:format', :controller => 'issues_statuses', :action => 'index', :conditions => {:method => :get} 
  
  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wadl'
 
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
