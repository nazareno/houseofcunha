var margin = {t:30, r:20, b:20, l:40 },
    w = 900 - margin.l - margin.r,
    h = 60 - margin.t - margin.b,
    x = d3.scale.linear().range([0, w]),
    y = d3.scale.linear().range([h - 60, 0]),
//colors that will reflect geographical regions
    color = d3.scale.ordinal()
        .domain(["outros","pmdb","psdb","psol","pt"])
        .range(["#bdbdbd", "darkred", "#0066CC", "#E69F00", "#FF3300"]);

var legenda = d3.select("#legenda" +
    "").append("svg")
    .attr("width", w + margin.l + margin.r)
    .attr("height", h + margin.t + margin.b);


// group that will contain all of the plots
var groups = legenda.append("g").attr("transform", "translate(" + margin.l + "," + margin.t + ")");

// array of the regions, used for the legend
var regions = ["outros", "pmdb", "psdb", "psol", "pt"]



var legend = legenda.selectAll("rect")
    .data(regions)
    .enter().append("rect")
    .attr({
        x: function(d, i) { return (40 + i*80); },
        y: h,
        width: 25,
        height: 12
    })
    .style("fill", function(d) { return color(d); });


//             legend labels
legenda.selectAll("text")
    .data(regions)
    .enter().append("text")
    .attr({
        x: function(d, i) { return (40 + i*80); },
        y: h + 24,
    })
    .text(function(d) { return d; });