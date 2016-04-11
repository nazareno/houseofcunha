function legenda() {
    var marginLegend = {t:0, r:20, b:20, l:75 },
        w = 900 - marginLegend.l - marginLegend.r,
        h = 60 - marginLegend.t - marginLegend.b,
        xLegend = d3.scale.linear().range([0, w]),
        yLegend = d3.scale.linear().range([h - 60, 0]),
        //colors that will reflect parties
        color = d3.scale.ordinal()
                  .domain(["outros","pmdb","psdb","psol","pt"])
                  .range(["#bdbdbd", "darkred", "#0066CC", "#E69F00", "#FF3300"]);

    var legenda = svgWrapper.append("svg")
        .attr("width", w + marginLegend.l + marginLegend.r)
        .attr("height", h + marginLegend.t + marginLegend.b);

    // group that will contain all of the plots
    var groups = legenda.append("g")
                        .attr("transform", "translate(" + marginLegend.l + "," + marginLegend.t + ")");

    // array of the parties, used for the legend
    var parties = ["outros", "pmdb", "psdb", "psol", "pt"]

    // add circles
    var legend = legenda.selectAll("circle")
                        .data(parties)
                        .enter()
                        .append("circle")
                        .attr({
                            cx: function(d, i) { return (75 + i*80); },
                            cy: (h + marginLegend.t) / 2,
                            r: 10
                        })
                        .style("fill", function(d) { return color(d); });

    // legend labels
    legenda.selectAll("text")
           .data(parties)
           .enter().append("text")
           .attr({
             x: function(d, i) { return (65 + i*80); },
             y: ((h + marginLegend.t) / 2) + 20
            })
            .text(function(d) { return d; });
}
