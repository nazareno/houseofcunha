angular.module('houseofcunha').directive('camara2d', function ($parse) {
    var directiveDefinitionObject = {
        restrict: 'E',
        replace: false,
        scope: {
            deputados: '=chartData'
        },
        link: function (scope, element, attrs) {


            var opts = {
                "dom": "chart15ac5988c8a0",
                "width": 800,
                "height": 500,
                "x": "Dim.1",
                "y": "Dim.2",
                "group": "destaque_partido",
                "type": "scatterChart",
                "id": "chart15ac5988c8a0"
            };

            var svg = d3.select("#" + opts.id)
                .append('svg');


            scope.$watch('deputados', function (oldValue, newValue) {
                if (scope.deputados && scope.deputados.length > 0) {
                    scope.redraw();
                }
            });

            scope.redraw = function () {

                if (!(opts.type === "pieChart" || opts.type === "sparklinePlus" || opts.type === "bulletChart")) {
                    var data = d3.nest()
                        .key(function (d) {
                            //return opts.group === undefined ? 'main' : d[opts.group]
                            //instead of main would think a better default is opts.x
                            return opts.group === undefined ? opts.y : d[opts.group];
                        })
                        .entries(scope.deputados);
                }

                if (opts.disabled != undefined) {
                    data.map(function (d, i) {
                        d.disabled = opts.disabled[i]
                    });
                }

                nv.addGraph(function () {
                    var chart = nv.models[opts.type]()
                        .width(opts.width)
                        .height(opts.height);

                    if (opts.type != "bulletChart") {
                        chart.x(function (d) {
                                return d[opts.x]
                            })
                            .y(function (d) {
                                return d[opts.y]
                            });
                    }


                    chart.color(["#BDBDBD", "#FF3300", "darkred", "#0066CC", "#E69F00"])
                        .tooltipContent(function (key, x, y, e) {
                            return key.point.nome + ', ' + (key.point.partido.toUpperCase()) + '(' + (key.point.uf) + ')';
                        })
                        .tooltipXContent(null)
                        .tooltipYContent(null)
                        //                        .size(1)
                        .showXAxis(false)
                        .showYAxis(false);

                    svg.datum(data)
                        .transition()
                        .duration(500)
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