'use strict';

/* Directives */

phonecatApp.directive('barChart', function($window){
    return{
        restrict:'EA',
        template:"<svg></svg>",
        link: function(scope, elem, attrs){

            var data1=scope[attrs.chartData];
            var data = _.map(data1.media_tags, function (value,key) {
                return {'letter':key,'frequency':value}
            })
            //var padding = 20;
            //var pathClass="path";
            //var xScale, yScale, xAxisGen, yAxisGen, lineFun;

            var d3 = $window.d3;
            var rawSvg=elem.find('svg');
            var svg = d3.select(rawSvg[0]);


            var margin = {top: 20, right: 20, bottom: 20, left: 70},
                width = 500 - margin.left - margin.right,
                height = 200 - margin.top - margin.bottom;

            var x = d3.scale.linear()
                .range([margin.left, width]);

            var y = d3.scale.ordinal()
                .rangeRoundBands([height, 0],.1);




            //var svg = d3.select("#teste").append("svg")
            svg
                .attr("width", width + margin.left + margin.right)
                .attr("height", height + margin.top + margin.bottom)
                .append("g")
                .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

            //d3.tsv("data.tsv", type, function(error, data) {

            x.domain([0, d3.max(data, function(d) { return d.frequency; })]);
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
                .attr("transform", "translate(0," + height + ")")
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

        }
    };
});