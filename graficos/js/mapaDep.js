/**
 * Created by viana on 03/12/15.
 */

// set the stage
var margin = {t:30, r:20, b:20, l:40 },
    w = 900 - margin.l - margin.r,
    h = 500 - margin.t - margin.b,
    x = d3.scale.linear().range([0, w]),
    y = d3.scale.linear().range([h - 60, 0]),
//colors that will reflect geographical regions
    color = d3.scale.ordinal()
        .domain(["outros","pmdb","psdb","psol","pt"])
        .range(["#bdbdbd", "darkred", "#0066CC", "#E69F00", "#FF3300"]);

var svg = d3.select("#mapaDep").append("svg")
    .attr("width", w + margin.l + margin.r)
    .attr("height", h + margin.t + margin.b)
    .call(d3.behavior.zoom().on("zoom", function () {
        svg.attr("transform", "translate(" + d3.event.translate + ")" + " scale(" + d3.event.scale + ")")
    }))
    .append("g");

// set axes, as well as details on their ticks
var xAxis = d3.svg.axis()
    .scale(x)
    .ticks(20)
    .tickSubdivide(true)
    .tickSize(6, 3, 0)
    .orient("bottom");


var yAxis = d3.svg.axis()
    .scale(y)
    .ticks(20)
    .tickSubdivide(true)
    .tickSize(6, 3, 0)
    .orient("left");

// group that will contain all of the plots
var groups = svg.append("g").attr("transform", "translate(" + margin.l + "," + margin.t + ")");

// array of the regions, used for the legend
var regions = ["outros", "pmdb", "psdb", "psol", "pt"]

// bring in the data, and do everything that is data-driven
d3.csv("MCAtoplot.csv", function(data) {
    // sort data alphabetically by region, so that the colors match with legend
    var x0 = Math.max(-d3.min(data, function(d) { return d.Dim_1; }), d3.max(data, function(d) { return d.Dim_1; }));
    x.domain([-1, 1]);
    y.domain([-1, 1])
    // style the circles, set their locations based on data
    var circles =
        groups.selectAll("circle")
            .data(data)
            .enter().append("circle")
            .attr("class", "circles")
            .attr({
                cx: function(d) { return x(+d.Dim_1); },
                cy: function(d) { return y(+d.Dim_2); },
                r: 4,
                id: function(d) { return d.novo_nome; }
            })
            .style("fill", function(d) { return color(d.destaque_partido); });

    // what to do when we mouse over a bubble
    var mouseOn = function() {
        var circle = d3.select(this);
        // transition to increase size/opacity of bubble
        circle.transition()
            .duration(800).style("opacity", 0.6)
            .attr("r", 12).ease("elastic");
        // function to move mouseover item to front of SVG stage, in case
        // another bubble overlaps it
        d3.selection.prototype.moveToFront = function() {
            return this.each(function() {
                this.parentNode.appendChild(this);
            });
        };
        // skip this functionality for IE9, which doesn't like it
        if (!$.browser.msie) {
            circle.moveToFront();
        }
    };
    // what happens when we leave a bubble?
    var mouseOff = function() {
        var circle = d3.select(this);
        // go back to original size and opacity
        circle.transition()
            .duration(800).style("opacity", .5)
            .attr("r", 4).ease("elastic");
        // fade out guide lines, then remove them
        d3.selectAll(".guide").transition().duration(100).styleTween("opacity",
            function() { return d3.interpolate(.5, 0); })
            .remove()
    };
    // run the mouseon/out functions
    circles.on("mouseover", mouseOn);
    circles.on("mouseout", mouseOff);
    // tooltips (using jQuery plugin tipsy)
    circles.append("title")
        .text(function(d) { return d.novo_nome; })
    $(".circles").tipsy({ gravity: 's', });

    // draw axes and axis labels
    svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(" + margin.l + "," + (h - 60 + margin.t) + ")")
        .call(xAxis);
});
