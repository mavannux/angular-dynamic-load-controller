###
.config ['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) -> 
	$routeProvider
		.when '/', 
			templateUrl: 'tpl/index.html'
			controller: IndexCtrl
		.when '/login', 
			templateUrl: 'tpl/login.html' 
			controller: LoginCtrl
		.when '/auth/add', 
			templateUrl: 'p/auth.add.html' 
		.when '/auth/edit', 
			templateUrl: 'p/auth.edit.html' 
		.otherwise
			redirectTo: '/'

	return
]
###
###
.run ($rootScope, $location, $cookieStore, mobileServer) ->
	$rootScope.$on "$routeChangeStart", (event, next, current) ->
		
		redirect = () ->
			if ($location.path() != "/login") 
				$rootScope.wantsUrl = $location.path();
				$location.path "/login"
		
		if (!$rootScope.loggedUser || $rootScope.loggedUser == null)
			token = $cookieStore.get("user-token")
			if (token) 
				mobileServer.userinfo(token)
				.success (data, status) ->
					if (data && data.name != null) 
						$rootScope.loggedUser = data
					else redirect()
				.error (data, status) ->
					$cookieStore.remove("user-token")
					redirect()
			else 
				redirect()
###
app = angular.module 'clientMobileServer', ['ngCookies', 'ui.bootstrap', 'ui.router', 'controllerResolverModule']

app.config ['$controllerProvider', '$compileProvider', '$stateProvider', '$urlRouterProvider', '$httpProvider', 'controllerResolverProvider', 
($controllerProvider, $compileProvider, $stateProvider, $urlRouterProvider, $httpProvider, controllerResolverProvider) -> 

	app.register = 
		controllerResolver: controllerResolverProvider
		controller: $controllerProvider.register
		directive: $compileProvider.directive
		stateProvider: $stateProvider

	$httpProvider.interceptors.push "myHttpInterceptor"
		
	$urlRouterProvider.otherwise "/index"
	
	$stateProvider
	.state controllerResolverProvider.solve('login')
	.state controllerResolverProvider.solve('index')
	.state 'index.info',
		url: "/info"
		templateUrl: 'tpl/status.html' 
		#controller: "infoCtrl"
		#resolve: controllerResolverProvider.resolve("")
		
	.state 'index.auth',
		url: "/auth"
		templateUrl: 'tpl/authentication.html' 
		controller: "authenticationCtrl"
		resolve: controllerResolverProvider.resolve("js/controllers/authentication.js")
		
	return
	]

.run ($rootScope, $state, $cookieStore, mobileServer) ->
	$rootScope.$on '$stateChangeStart', (event, toState, toParams, fromState, fromParams) ->

		redirect = () ->
			if (toState.name != "login") 
				event.preventDefault()
				$rootScope.wantsState = toState.name
				$state.go 'login'
		
		if (!$rootScope.loggedUser || $rootScope.loggedUser == null)
			token = $cookieStore.get("user-token")
			#token=null
			if (token) 
				mobileServer.userinfo(token)
				.success (data, status) ->
					if (data && data.name != null) 
						$rootScope.loggedUser = data
					else redirect()
				.error (data, status) ->
					$cookieStore.remove("user-token")
					redirect()
			else 
				redirect()

.factory 'myHttpInterceptor', () ->
	return 'responseError': (rejection) ->
		console.log("responseError " + JSON.stringfy(rejection))
        return $q.reject(rejection);
      }
				
.factory 'mobileServer', ($http, $cookieStore) ->
	login: (usr, pwd) ->
		#return the promise directly.
		$http.get "admin/login?usr=#{usr}&pwd=#{pwd}"
	userinfo: (token) ->
		$http.get "admin/token?token=#{token}", responseType: "json"
	status: ->
		token = $cookieStore.get("user-token")
		$http.get "admin/status?token=#{token}", responseType: "json"
			
	currentAuthentication: ->
		token = $cookieStore.get("user-token")
		$http.get "admin/authentications/current?token=#{token}", responseType: "json"
	authentications: ->
		token = $cookieStore.get("user-token")
		$http.get "admin/authentications?token=#{token}", responseType: "json"
	authenticationEdit: (id) ->
		token = $cookieStore.get("user-token")
		$http.get "admin/authentications/#{id}/edit?token=#{token}", responseType: "json"
	logout: ->
		token = $cookieStore.get("user-token")
		$cookieStore.remove("user-token")
		$http.get "admin/logout?token=#{token}", responseType: "json"
		
	###
	<modal-dialog show='modalShown' width='750px' height='90%'>
		<p>Modal Content Goes here<p>
	</modal-dialog>
	###
.directive 'modalDialog', () -> 
	restrict: 'E'
	scope: 
		show: '='
	replace: true # Replace with the template below
	transclude: true # we want to insert custom content inside the directive
	link: (scope, element, attrs) ->
		scope.dialogStyle = {}
		if (attrs.width)
			scope.dialogStyle.width = attrs.width;
		if (attrs.height)
			scope.dialogStyle.height = attrs.height;
		scope.hideModal = () ->
			scope.show = false;
		template:
                "<div class='ng-modal' ng-show='show'>
                    <div class='ng-modal-overlay' ng-click='hideModal()'></div>
                    <div class='ng-modal-dialog' ng-style='dialogStyle'>
                        <div class='ng-modal-close' ng-click='hideModal()'>X</div>
                        <div class='ng-modal-dialog-content' ng-transclude></div>
                    </div>
                 </div>"
				 
.directive "required", () ->
	link: (scope, element, attrs) ->
		element.after "<div class=\"required-tick\">*</div>"
