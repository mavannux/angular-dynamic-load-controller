
angular.module 'controllerResolverModule', []
.provider 'controllerResolver', () ->

	controllers = []
	
	@$get = ->
		this

	@solve = (stateName) ->
		# login --> loginCtrl
		controller = stateName + "Ctrl"
		url: "/#{stateName}"
		name: stateName
		controller: controller
		templateUrl: "tpl/#{stateName}.html" 
		resolve: @resolve "js/controllers/#{stateName}.js"
		
	@resolve = (controller, moduleContext) ->
		if moduleContext == null || moduleContext == undefined
			moduleContext = ""
		load: ($q, $http, $cookieStore) ->
			defer = $q.defer()
			if (controllers.indexOf controller) > 0
				defer.resolve()
				return
			else
				token = $cookieStore.get("user-token")
				$http.get controller, { token: token, responseType: "text/javascript" }
					.success (data, status) ->
						head = document.getElementsByTagName('head')[0]
						script = document.createElement 'script'
						script.setAttribute 'type', 'text/javascript'
						script.innerHTML = data
						head.appendChild(script)
						controllers.push controller
						#$rootScope.$apply() 
						defer.resolve()
						return
					.error (data, status) ->
						defer.reject()
						return
				return defer.promise
				
		moduleContext: () ->
			moduleContext
		
	return 