#LoginCtrl = ($rootScope, $scope, $state, $cookieStore, $sce, mobileServer) ->
app.register.controller 'loginCtrl', ($rootScope, $scope, $state, $cookieStore, $sce, mobileServer) ->
	$scope.user =
		name: ""
		pwd: ""
	
	$scope.loading =
		show: false
		text: ""
		
	$scope.status = ""
	$scope.errVisible = false
	
	$scope.to_trusted = (html_code) ->
		if (html_code)
			i1 = html_code.indexOf("<script>")
			i2 = html_code.indexOf("</script>")
			if i1 > 0 && i2 > 0
				html_code = html_code.substring(0,i1) + html_code.substring(i2+9)
		$sce.trustAsHtml(html_code)

	$scope.login = () ->
		#$scope.loading.show = true
		elUsr = document.getElementById("inputUsername")
		elPwd = document.getElementById("inputPassword")
		$scope.user.name = elUsr.value
		$scope.user.pwd = elPwd.value
		user = $scope.user
		mobileServer.login user.name, user.pwd
			.success (data, status) ->
				#$scope.loading.show = false
				user.token = data
				$cookieStore.put("user-token", user.token)
				$rootScope.loggedUser = angular.copy(user)
				
				if $rootScope.wantsState?
					s = $rootScope.wantsState 
					$rootScope.wantsState = null
					$state.go s
				else
					$state.go "index"
				return
				
				#if $rootScope.wantsUrl?
				#	$location.path($rootScope.wantsUrl)
				#else 
				#	$location.path "/"
				#$scope.$apply()
			.error (data, status) ->
				#$scope.loading.show = false
				$scope.status = status
				$scope.data = data
				$scope.errVisible = true
				#$cookieStore.remove("user-token")
				return