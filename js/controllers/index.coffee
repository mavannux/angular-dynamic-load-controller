#IndexCtrl = ($rootScope, $scope, $state, mobileServer) ->
app.register.controller "indexCtrl", ($rootScope, $scope, $state, mobileServer) ->
	
	self = this
	
	$scope.items = [
		{
			id: "info"
			title: "Info"
			template:"tpl/status.html"
			selected: false
		}
		{
			id: "authentication"
			title: "Authentication"
			template:"tpl/authentication.html"
			selected: false
		}
		{
			id: "repositories"
			title: "Repositories"
			template:"tpl/repositories.html"
			selected: false
		}
		{
			id: "modules"
			title: "Modules"
			template:"tpl/modules.html"
			selected: false
		}
	]
	
	$scope.content = 
		template: ""
	
	$scope.logout = () ->
		mobileServer.logout()
			.success (data, status) ->
				$state.go "login"
			.error (data, status) ->
				$state.go "login"
		return
		
	$scope.select = (item) ->
	
		if $scope.selected
			$scope.selected.selected = false
			
		$scope.selected = item
		$scope.selected.selected = true
		
		# call appropriate function
		self[item.id]();
		
		return
		
	self.info = ->
		$state.go "index.info"
		#$scope.content.title = "Info"
		#$scope.content.template = $scope.selected.template
		mobileServer.status()
			.success (data, status) ->
				# {"version":null,"status":null}
				$scope.status = data.status
				$scope.version = data.version
			.error (data, status) ->
				console.log("error: #{status}")
				$scope.error = data
		return

	self.authentication= ->
		$state.go "index.auth"
		#$scope.content.title = "Authentication"
		#$scope.content.template = $scope.selected.template
		return

	self.repositories= ->
		$scope.content.title = "Repositories"
		$scope.content.template = $scope.selected.template
		return

	self.modules= ->
		$scope.content.title = "Modules"
		$scope.content.template = $scope.selected.template
		return
	

	# Initialize content
	$scope.select($scope.items[0])
		
	return
	