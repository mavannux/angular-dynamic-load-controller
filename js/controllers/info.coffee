InfoCtrl = ($scope, mobileServer) ->

	$scope.status = "Updating..."
	$scope.version = ""
	
	mobileServer.status()
		.success (data, status) ->
			# {"version":null,"status":null}
			$scope.status = data.status
			$scope.version = data.version
		.error (data, status) ->
			console.log("error: #{status}")
			$scope.error = data
				
				