angular.module('houseofcunha', ['ngRoute']);

angular.module('houseofcunha')
    .config(function ($routeProvider) {
        $routeProvider
            .when('/ato1', {
                templateUrl: '/site-novo/templates/pages/ato1/index.html',
                controller: 'Ato1Controller',
                controllerAs: 'ato1Controller'
            })
            .when('/ato2', {
                templateUrl: '/site-novo/templates/pages/ato2/index.html',
            })
            .when('/ato3', {
                templateUrl: '/site-novo/templates/pages/ato3/index.html',
                controller: 'Ato3Controller',
                controllerAs: 'ato3Controller'
            })
            .when('/ato4', {
                templateUrl: '/site-novo/templates/pages/ato4/index.html'
            })
            .when('/extras', {
                templateUrl: '/site-novo/templates/pages/extras/index.html'
            })
            .when('/', {
                templateUrl: '/site-novo/templates/pages/ato1/index.html',
                controller: 'Ato1Controller',
                controllerAs: 'ato1Controller'

            })
            .otherwise({
                redirectTo: '/'
            });
    });

angular.module('houseofcunha')
    .controller('Ato1Controller', function ($scope, $http) {
        $scope.deputados = [];

        $http.get('data/deputados.json').then(function (response) {
            $scope.deputados = response.data;
        }, function (response) {
            console.log(response);
        });
    });

angular.module('houseofcunha')
    .controller('Ato3Controller', function ($scope, $http) {
        $scope.deputados = [];

        $http.get('data/rankingCPF.json').then(function (response) {
            $scope.rankingCPF = response.data;
        }, function (response) {
            console.log(response);
        });

        $http.get('data/rankingCNPJ.json').then(function (response) {
            response.data = response.data.map(function (e) {
                e.quant = parseInt(e.quant, 10);
                return e;
            });
            $scope.rankingCNPJ = response.data;
        }, function (response) {
            console.log(response);
        });
    });
