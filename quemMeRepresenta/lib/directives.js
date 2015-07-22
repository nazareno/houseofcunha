'use strict';

/* Directives */

houseOfCunhaApp.directive('barChart1', function($parse,$window){
    return{
        restrict:'E',
        template:"<svg style='width:100%'></svg>",
        scope: {
            data: "=data"
        },
        link: function(scope, elem, attrs){

            $window.onresize = function() {
                scope.$apply();
            };
            scope.$watch(function() {
                return angular.element($window)[0].innerWidth;
            }, function() {
                scope.render(scope.data);
            });

            scope.$watch('data', function (newVal, oldVal) {
                var chartEl = d3.select(element[0]);
                chartEl.datum(newVal).call(chart);
            });




            //var margin = parseInt(attrs.margin) || 20,
            //    barHeight = parseInt(attrs.barHeight) || 20,
            //    barPadding = parseInt(attrs.barPadding) || 5;
            //



            scope.render = function (data) {

                var data1=data;
                //var data = _.map(data1.media_tags, function (value,key) {
                //    return {'letter':key,'frequency':value}
                //})

                //data = _.sortBy(data,'frequency');

                var d3 = $window.d3;

                var rawSvg=elem.find('svg');
                var svg = d3.select(rawSvg[0]);
                svg.selectAll("*").remove();

                var margin = {top: 20, right: 20, bottom: 20, left: 70},
                    height = 200 - margin.top - margin.bottom;

                var width = d3.select(elem[0]).node().offsetWidth;
                //height = data1.length * (barHeight + barPadding);
                if (width == 0){
                    width = 500 - margin.left - margin.right;
                }
                width = width - margin.left;
                var x = d3.scale.linear()
                    .range([0, width]);

                var y = d3.scale.ordinal()
                    .rangeRoundBands([height, 0],.1);


                //var svg = d3.select("#teste").append("svg")
                svg .style('width', '100%')
                    //.attr("width", width + margin.left + margin.right)
                    .attr("height", height + margin.top + margin.bottom)
                    .append("g")
                    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

                //d3.tsv("data.tsv", type, function(error, data) {

                //x.domain([0, d3.max(data, function(d) { return d.frequency; })]);
                x.domain([0, 1]);

                y.domain(data.map(function(d) { return d.letter; }));

                var xAxis = d3.svg.axis()
                    .scale(x)
                    .orient("bottom")
                    .ticks(10, "%");

                var yAxis = d3.svg.axis()
                    .scale(y)
                    .orient("left")

                svg.append("g")
                    .attr("class", "x axis")
                    .attr("transform", "translate("+margin.left+"," + height + ")")
                    .call(xAxis);

                svg.append("g")
                    .attr("class", "y axis")
                    .attr("transform", "translate("+margin.left +"," + 0 + ")")
                    .call(yAxis);

                svg.selectAll(".bar")
                    .data(data)
                    .enter().append("rect")
                    .attr("class", "bar")
                    .attr("x", function(d) { return margin.left; })
                    .attr("width",function(d){ return x(d.frequency);})
                    .attr("y", function(d) { return y(d.letter); })
                    .attr("height", function(d) { return y.rangeBand(); });

                var insertLinebreaks = function (d) {
                    var el = d3.select(this);
                    var words = d.split(' ');
                    el.text('');
                    var string = "";
                    el.append('tspan').text(words[0]);

                    for (var i = 1; i < words.length; i++) {
                        string += words[i] + " ";
                    }
                    if (words.length > 1){
                        var tspan = el.append('tspan').text(string);
                        tspan.attr('x', 0).attr('dy', '11');

                    }
                };

                svg.selectAll('g.y.axis g.tick text').each(insertLinebreaks);

            }


        }
    };
});

houseOfCunhaApp.directive('barChart', function(){
    var chart = d3.custom.barChart();
    return {
        restrict: 'E',
        replace: true,
        template: '<div class="chart"></div>',
        scope:{
            height: '=height',
            data: '=data',
            hovered: '&hovered'
        },
        link: function(scope, element, attrs) {
            var chartEl = d3.select(element[0]);
            chart.on('customHover', function(d, i){
                scope.hovered({args:d});
            });

            scope.$watch('data', function (newVal, oldVal) {
                chartEl.datum(newVal).call(chart);
            });

            scope.$watch('height', function(d, i){
                chartEl.call(chart.height(scope.height));
            })
        }
    }
})
.directive('chartForm', function(){
    return {
        restrict: 'E',
        replace: true,
        controller: function AppCtrl ($scope) {
            $scope.update = function(d, i){ $scope.data = randomData(); };
            function randomData(){
                return d3.range(~~(Math.random()*50)+1).map(function(d, i){return ~~(Math.random()*1000);});
            }
        },
        template: '<div class="form">' +
        'Height: {{options.height}}<br />' +
        '<input type="range" ng-model="options.height" min="100" max="800"/>' +
        '<br /><button ng-click="update()">Update Data</button>' +
        '<br />Hovered bar data: {{barValue}}</div>'
    }
});
