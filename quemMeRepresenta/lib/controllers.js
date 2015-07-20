'use strict';

/* Controllers */

var houseOfCunhaApp = angular.module('houseOfCunhaApp', []);

houseOfCunhaApp.controller('VotacoesCtrl', ['$scope', '$http', function($scope, $http) {
    $scope.estados = [];
    $scope.deputados = [];
    $scope.temas = [];

    $scope.estadoSelecionado = "TODOS";

    $http.get('dados/estados.json').success(function(data) {

        $scope.estados = data;


    });

    $http.get('dados/deputados_votos.json').success(function(data) {

        $scope.deputados = data;
    });

    $http.get('dados/temas.json').success(function(data) {

        $scope.temas = data;
    });



}]);

