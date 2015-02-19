#AuthenticationCtrl = ($rootScope, $scope, $location, $cookieStore, $sce, mobileServer) ->
app.register.controller  "authenticationCtrl", ($state, $scope, $location, $cookieStore, $sce, mobileServer) ->

	if (!$state.get("index.auth.add"))
		app.register.stateProvider

			.state "index.auth.add", 
				url: "/add"
				templateUrl: "tpl/auth.add.html"
				
			.state "index.auth.edit", 
				url: "/edit"
				templateUrl: "p/auth.edit.html"

	###
		.state 'index.auth.edit',
			url: "/edit"
			templateUrl: "p/auth.edit.html"
			controller: "authenticationCtrl"
			resolve: controllerResolverProvider.resolve("js/controllers/authentication.js")
	###			
	$scope.moduleTitle = ""
	$scope.moduleType = ""
	$scope.moduleConfig = ""
	$scope.moduleStatus = ""
	$scope.errVisible = false
	$scope.loading = true
	$scope.content = 
		visible: false
				
	init = () ->
		$scope.loading = true
		mobileServer.currentAuthentication()
			.success (data, status) ->
				$scope.loading = false
				if data.status == "Unknown"
					$scope.status = data.status
					$scope.data = data.msg
					$scope.errVisible = false
					$scope.hasCurrent = false
				else
					$scope.moduleTitle = data.moduleTitle
					$scope.moduleType = data.moduleType
					$scope.moduleConfig = data.configTitle
					$scope.moduleStatus = data.status
					$scope.errVisible = false
					$scope.hasCurrent = true
				return
			.error (data, status) ->
				$scope.loading = false
				$scope.status = status
				$scope.data = data
				$scope.errVisible = true
				return
	init()
	
	###
	$scope.addConfig = () ->
		# load dal server html + js + risorse
		#$scope.content.url = "http://localhost/"
	###
	
	$scope.onAddAuth = () ->
		mobileServer.authentications()
			.success (data, status) ->
				$scope.loading = false
				$scope.auths = data
				$state.go "index.auth.add"
				return
			.error (data, status) ->
				$scope.loading = false
				$scope.status = status
				$scope.data = data
				$scope.errVisible = true
				return
		
	$scope.onSelectAuth = (auth) ->
		console.log("selected: #{auth.id}, #{auth.title} ")
		moduleContext = "admin/authentications/#{auth.id}"
		mobileServer.authenticationEdit(auth.id)
			.success (data, status) ->
				$scope.loading = false
				# controller: 
				# templateHTML: "tpl.html"
				console.log("data:"+JSON.stringify(data))
				modState = "index.auth.add.#{auth.id}"
				if (!$state.get(modState))
					app.register.stateProvider
						.state modState, 
						url: "/#{auth.id}"
						templateUrl: data.templateHTML
						#template: data.template
						controller: data.controllerName
						# templateHTML":"/admin/authentications/0/tpl.html"
						resolve: app.register.controllerResolver.resolve(data.controllerHref, moduleContext)
				$state.go modState
				return
			.error (data, status) ->
				$scope.loading = false
				$scope.status = status
				$scope.data = data
				$scope.errVisible = true
				return
	return