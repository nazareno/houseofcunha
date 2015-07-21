var houseOfCunhaApp = angular.module('houseOfCunhaApp', ['ui.bootstrap']);

houseOfCunhaApp.controller('VotacoesCtrl', ['$scope', '$http', function($scope, $http) {
  $scope.singleModel = 1;

  $scope.radioModel = 'Middle';

  $scope.checkModel = {
    left: false,
    middle: true,
    right: false
  };
}]);
