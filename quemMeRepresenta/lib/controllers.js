'use strict';

/* Controllers */

var houseOfCunhaApp = angular.module('houseOfCunhaApp', []);

houseOfCunhaApp.controller('VotacoesCtrl', ['$scope', '$http', function($scope, $http) {
    $scope.estados = [];
    $scope.deputados = [];

    $scope.estadoSelecionado = "TODOS";

    $http.get('dados/estados.json').success(function(data) {

        $scope.estados = data;


    });

    $http.get('dados/deputados.json').success(function(data) {

        $scope.deputados = data;
        var a = 1;

    });



}]);

