/**
 * Created by rodolfo on 12/09/15.
 */

// set the stage
var margin = {t:30, r:20, b:20, l:40 },
    w = 900 - margin.l - margin.r,
    h = 500 - margin.t - margin.b,
    x = d3.scale.linear().range([0, w]),
    y = d3.scale.linear().range([h - 60, 0]),
//colors that will reflect geographical regions
    color = d3.scale.category10();

var genres = d3.select("#genres").append("svg")
    .attr("width", w + margin.l + margin.r)
    .attr("height", h + margin.t + margin.b);

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
var groups1 = genres.append("g").attr("transform", "translate(" + margin.l + "," + margin.t + ")");

// array of the regions, used for the legend
var regions1 = ["Action", "Comedy", "Drama", "Others"]


// bring in the data, and do everything that is data-driven
d3.csv("top250IMDB.csv", function(data) {

    // sort data alphabetically by region, so that the colors match with legend


    var x0 = Math.max(-d3.min(data, function(d) { return d.countries; }), d3.max(data, function(d) { return d.countries; }));
    x.domain([-1, 255]);
    y.domain([7.8, 10])

    // style the circles, set their locations based on data
    var circles =
        groups1.selectAll("circle")
            .data(data)
            .enter().append("circle")
            .attr("class", "circles")
            .attr({
                cx: function(d) { return x(+d.countries); },
                cy: function(d) { return y(+d.rating); },
                r: 8,
                id: function(d) { return d.movieTitle; }
            })
            .style("fill", function(d) { return color(d.newgenres); });

    // what to do when we mouse over a bubble
    var mouseOn = function() {
        var circle = d3.select(this);

        // transition to increase size/opacity of bubble
        circle.transition()
            .duration(800).style("opacity", 1)
            .attr("r", 16).ease("elastic");

        // append lines to bubbles that will be used to show the precise data points.
        // translate their location based on margins
        genres.append("g")
            .attr("class", "guide")
            .append("line")
            .attr("x1", circle.attr("cx"))
            .attr("x2", circle.attr("cx"))
            .attr("y1", +circle.attr("cy") + 26)
            .attr("y2", h - margin.t - margin.b)
            .attr("transform", "translate(40,20)")
            .style("stroke", circle.style("fill"))
            .transition().delay(200).duration(400).styleTween("opacity",
            function() { return d3.interpolate(0, .5); })

        genres.append("g")
            .attr("class", "guide")
            .append("line")
            .attr("x1", +circle.attr("cx") - 16)
            .attr("x2", 0)
            .attr("y1", circle.attr("cy"))
            .attr("y2", circle.attr("cy"))
            .attr("transform", "translate(40,30)")
            .style("stroke", circle.style("fill"))
            .transition().delay(200).duration(400).styleTween("opacity",
            function() { return d3.interpolate(0, .5); });

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
            .attr("r", 8).ease("elastic");

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
        .text(function(d) { return d.movieTitle; })

    $(".circles").tipsy({ gravity: 's', });

    // the legend color guide
    var legend = genres.selectAll("rect")
        .data(regions1)
        .enter().append("rect")
        .attr({
            x: function(d, i) { return (40 + i*80); },
            y: h,
            width: 25,
            height: 12
        })
        .style("fill", function(d) { return color(d); });


    // legend labels
    genres.selectAll("text")
        .data(regions1)
        .enter().append("text")
        .attr({
            x: function(d, i) { return (40 + i*80); },
            y: h + 24,
        })
        .text(function(d) { return d; });

    // draw axes and axis labels
    genres.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(" + margin.l + "," + (h - 60 + margin.t) + ")")
        .call(xAxis);

    genres.append("g")
        .attr("class", "y axis")
        .attr("transform", "translate(" + margin.l + "," + margin.t + ")")
        .call(yAxis);

    // svg.append("text")
    //        .attr("class", "x label")
    //        .attr("text-anchor", "end")
    //        .attr("x", w + 50)
    //        .attr("y", h - margin.t - 5)
    //        .text("nota popular");

    genres.append("text")
        .attr("class", "y label")
        .attr("text-anchor", "end")
        .attr("x", -20)
        .attr("y", 45)
        .attr("dy", ".75em")
        .attr("transform", "rotate(-90)")
        .text("rating");
});


