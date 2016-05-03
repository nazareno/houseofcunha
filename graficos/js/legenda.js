var legenda = function (options) {
    this.marginLegend = {t:0, r:20, b:20, l:75 };
    this.w = 900 - this.marginLegend.l - this.marginLegend.r;
    this.h = 60 - this.marginLegend.t - this.marginLegend.b,
    this.xLegend = d3.scale.linear().range([0, this.w]);
    this.yLegend = d3.scale.linear().range([this.h - 60, 0]);
    this.options = {};
    this.options.coloredParties = options.coloredParties.slice();
    this.options.colorsVector = options.colorsVector.slice();
        //colors that will reflect parties
    this.color = d3.scale.ordinal()
                  .domain(this.options.coloredParties)
                  .range(this.options.colorsVector);

    this.legenda = d3.select("body").append("svg")
        .attr("id", "legenda")
        .attr("width", this.w + this.marginLegend.l + this.marginLegend.r)
        .attr("height", this.h + this.marginLegend.t + this.marginLegend.b)
        .append("g");

        // group that will contain all of the plots
        // var groups = legenda.append("g")
        //                     .attr("transform", "translate(" + marginLegend.l + "," + marginLegend.t + ")");

    var that = this;
    this.circles = this.legenda.selectAll("circle");
    // add circles
    this.circles.data(this.options.coloredParties)
                .enter()
                .append("circle")
                .attr({
                    cx: function(d, i) { return (75 + i*80); },
                    cy: (that.h + that.marginLegend.t) / 2,
                    r: 10
                })
                .style("fill", function(d) { return that.color(d); });

    this.labels = this.legenda.selectAll("text");
    // legend labels
    this.labels.data(this.options.coloredParties)
               .enter()
               .append("text")
               .attr({
                   x: function(d, i) { return (65 + i*80); },
                   y: ((that.h + that.marginLegend.t) / 2) + 20
                })
               .text(function(d) { return d; });
}

legenda.prototype.update = function (options) {
    if (!options) return;
    if(options.hasOwnProperty("coloredParties")) {
        this.options.coloredParties = options.coloredParties.slice();
    }
    if(options.hasOwnProperty("colorsVector")) this.options.colorsVector = options.colorsVector.slice();
    // update color scale
    this.color = d3.scale.ordinal()
                   .domain(this.options.coloredParties)
                   .range(this.options.colorsVector);

    var that = this;
    this.legenda.selectAll("circle").remove();
    var circlesSelection = this.legenda
        .selectAll("circle")
        .data(this.options.coloredParties);

    // TODO update instead of removing all elements
    // circlesSelection.exit().remove();
    // circlesSelection.attr({
    //         cx: function(d, i) { return (75 + i*80); },
    //         cy: (that.h + that.marginLegend.t) / 2,
    //         r: 10
    //     })
    //     .style("fill", function(d) { return that.color(d); });;

    circlesSelection.enter()
           .append("circle")
           .transition()
           .duration(500)
           .attr({
               cx: function(d, i) { return (75 + i*80); },
               cy: (that.h + that.marginLegend.t) / 2,
               r: 10
            })
            .style("fill", function(d) { return that.color(d); });

    this.legenda.selectAll("text").remove();
    var labelsSelection = this.legenda
        .selectAll("text")
        .data(this.options.coloredParties);

    // TODO update instead of removing all elements
    // labelsSelection.exit().remove();
    // labelsSelection.attr({
    //     x: function(d, i) { console.log(i);return (65 + i*80); },
    //     y: ((that.h + that.marginLegend.t) / 2) + 20
    // })
    // .text(function(d) { return d; });

    labelsSelection.enter()
          .append("text")
          .transition()
          .duration(500)
          .attr({
              x: function(d, i) { return (65 + i*80); },
              y: ((that.h + that.marginLegend.t) / 2) + 20
          })
          .text(function(d) { return d; });
};
