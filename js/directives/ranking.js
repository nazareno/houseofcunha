angular.module('houseofcunha').directive('ranking', function ($parse) {
    var directiveDefinitionObject = {
        restrict: 'E',
        replace: false,
        scope: {
            ranking: '=rankingData'
        },
        link: function (scope, element, attrs) {

            scope.$watch('ranking', function (oldValue, newValue) {
                if (scope.ranking && scope.ranking.length > 0) {
                    scope.plotdata = [{
                        "key": "Total de Doações",
                        "color": "#d67777",
                        "values": scope.ranking.slice(1, 20)
                    }];

                    scope.redraw();
                }
            });

            scope.redraw = function () {


                nv.addGraph(function () {
                    var chart = nv.models.multiBarHorizontalChart()
                        .width(800)
                        .height(500)
                        .x(function (d) {
                            return d.nome
                        })
                        .y(function (d) {
                            return d.valor
                        })
                        .margin({
                            top: 30,
                            right: 20,
                            bottom: 50,
                            left: 275
                        })
                        .showControls(false);
                    //                        .showValues(true) //Show bar value next to each bar.
                    //                        .tooltips(true) //Show tooltips on hover.
                    //                        .transitionDuration(350)
                    //                        .showControls(true); //Allow user to switch between "Grouped" and "Stacked" mode.

                    chart.yAxis
                        .tickFormat(d3.format(',.2f'));

                    d3.select("#ranking")
                        .append('svg')
                        .datum(scope.plotdata)
                        .call(chart);

                    nv.utils.windowResize(chart.update);

                    return chart;
                });

                return;
            };
        }
    }
    return directiveDefinitionObject;
});