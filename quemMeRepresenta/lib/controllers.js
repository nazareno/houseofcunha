'use strict';

/* Controllers */

var houseOfCunhaApp = angular.module('houseOfCunhaApp', ['ui.bootstrap']);

houseOfCunhaApp.controller('VotacoesCtrl', ['$scope', '$http', function($scope, $http) {
    $scope.estados = [];
    $scope.deputados = [];
    $scope.temas = [];

    //$scope.estadoSelecionado = {"uf":"PB"};

    $http.get('dados/estados.json').success(function(data) {

        $scope.estados = data;


    });

    $http.get('dados/deputados_votos.json').success(function(data) {

        $scope.deputados = data;
        _.map($scope.deputados,function (deputado){
            _.extend(deputado,{"score":0})
        })

    });

    $http.get('dados/temas.json').success(function(data) {

        $scope.temas = data;
        _.map($scope.temas,function (tema){
            _.extend(tema,{"value":-1})
        })
    });

    $scope.click =  function(data,value) {
        if(value == "s"){
            data.value = 1;
        }else if (value == "n"){
            data.value = 0;
        }else{
            data.value = -1;
        }

        $scope.refresh_values(data,value);
    };


    $scope.refresh_values =  function(data,value) {

        _.map($scope.deputados,function (deputado){
            var temas_deputado = deputado.temas;

        var sumEquals =
            _.reduce(temas_deputado,function (memo,tema_deputado,index) {
                if (tema_deputado.value >= 0 && $scope.temas[index].value >= 0){
                    if (tema_deputado.value == $scope.temas[index].value){
                        memo['sum'] = memo['sum'] + 1;
                        memo['total'] = memo['total'] + 1;

                        return memo;
                    }else{
                        memo['total'] = memo['total'] + 1;
                        return memo;
                    }
                }
                else{
                    return memo;
                }
            },{sum:0,total:0})
            if (! sumEquals["total"] == 0){
                var score = sumEquals["sum"] / sumEquals["total"];
                deputado.score = score;
            }
        })
    };


}]);

