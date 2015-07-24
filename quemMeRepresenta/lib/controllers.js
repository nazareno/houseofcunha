'use strict';

/* Controllers */

var houseOfCunhaApp = angular.module('houseOfCunhaApp', ['ui.bootstrap']);

houseOfCunhaApp.controller('VotacoesCtrl', ['$scope', '$http', function($scope, $http) {

    $scope.title = "DemoCtrl";
    $scope.d3Data = [
        {name: "Greg", score:98},
        {name: "Ari", score:96},
        {name: "Loser", score: 48}
    ];
    $scope.d3OnClick = function(item){
        alert(item.nome);
    };







    $scope.estadoSelecionado = "";

    $scope.estados = [];
    $scope.deputadosDaParada = [];
    $scope.temas = [];

    $scope.deputados = [];



    $http.get('dados/estados.json').success(function(data) {

        $scope.estados = data;


    });

    $http.get('dados/deputados_votos.json').success(function(data) {

        $scope.deputados = data;
        _.map($scope.deputados,function (deputado){
            _.extend(deputado,{"score":0})
        })
        $scope.deputadosDaParada = $scope.deputados;
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

    $scope.filter =  function() {
        if ($scope.estadoSelecionado != ""){
            //TODOS
            if ($scope.estadoSelecionado == null){
                $scope.deputadosDaParada = $scope.deputados;
            }else{
                $scope.deputadosDaParada = _.filter($scope.deputados, function(deputados){
                    return deputados.uf == $scope.estadoSelecionado.uf;
                });

            }


            $scope.deputadosDaParada = _.sortBy($scope.deputadosDaParada, function(deputado) {
                return -deputado.score;
            });

        }


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
                deputado.score = score * 100;
            }
        })


        if ($scope.estadoSelecionado != "" && $scope.estadoSelecionado != null){
            $scope.deputadosDaParada = _.filter($scope.deputados, function(deputados){
                return deputados.uf == $scope.estadoSelecionado.uf;
            });
        }

        $scope.deputadosDaParada = _.sortBy($scope.deputadosDaParada, function(deputado) {
            return -deputado.score;
        }); // [3, 2, 1, 0, -1, -2, -3]
    };


}]);

