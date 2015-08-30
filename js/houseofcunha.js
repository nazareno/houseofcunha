angular.module('houseofcunha', ['ngRoute']);

angular.module('houseofcunha')
    .config(function ($routeProvider) {
        $routeProvider
            .when('/ato1', {
                templateUrl: '/templates/pages/ato1/index.html',
            })
            .when('/ato2', {
                templateUrl: '/templates/pages/ato2/index.html',
            })
            .when('/ato3', {
                templateUrl: '/templates/pages/ato3/index.html'
            })
            .when('/ato4', {
                templateUrl: '/templates/pages/ato4/index.html'
            })
            .when('/extras', {
                templateUrl: '/templates/pages/extras/index.html'
            })
            .when('/', {
                templateUrl: '/templates/pages/ato1/index.html',
            })
            .otherwise({
                redirectTo: '/'
            });
    });
