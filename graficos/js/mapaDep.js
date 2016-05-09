/**
 * @author Rodolfo Viana
 * @author Pedro Scaff
 */

"use strict";

/**
 * @param options - styling options
 * @param divID - specify div where viz should be draw
 */
var graficoVotacoesAfinidades =  function (options, divID) {
    // setup and append svg before loading data
    // to avoid elements moving after loading
    this.margin = 75;
    this.widthPlot = 800 - this.margin;
    this.widthTop5 = 350;
    this.height = 650 - this.margin;
    this.options = {};
    // array with featured parties that will be colored
    this.options.coloredParties = options ? options.coloredParties.slice() :
        ["pmdb", "psdb", "psol", "pt"];
    this.options.coloredParties.push("outros");

    this.options.colorsVector = options ? options.colorsVector.slice() :
        ["rgba(139, 0, 0, 1)", "rgba(0,102,204,1)", "rgba(230,159,0,1)", "rgba(255,51,0,1)", "rgba(189,189,189, 1)"];

    //colors that will reflect parties
    this.color = d3.scale.ordinal()
        .domain(this.options.coloredParties)
        .range(this.options.colorsVector);

    this.x = d3.scale.linear().range([0, this.widthPlot - this.margin]);
    this.y = d3.scale.linear().range([this.height - this.margin, 0]);

    // get or create visualization div
    this.svgWrapper = divID ? d3.select("#" + divID) :
        d3.select("body").append("div").attr("id", "grafico");

    // set up main graphic svg
    this.svg = this.svgWrapper.append("svg")
        .attr("width", this.widthPlot + this.margin)
        .attr("height", this.height + this.margin/2)
        .append("g")
        .attr("transform", "translate(" + this.margin + "," + this.margin/2 + ")")
        .attr("class", "chart");

    // line to show active circle
    this.line = this.svg.append("line")
        .attr("opacity", 0.5)
        .attr("stroke-width", 2);

    // all setup for politian's information layout
    this.divInfo = this.svgWrapper.append("div").attr("id", "divInfo");

    this.infoDep = this.divInfo.append("div").attr("id", "infoDep");

    this.imgDep = this.infoDep.append("img")
        .attr("width", 150)
        .attr("height", 200)
        .attr("id", "fotoDeputado");

    this.infoGroup = this.infoDep.append("div").attr("id", "infoGroup");

    // variables to be updated on click event
    this.infoName = this.infoGroup.append("span");
    this.infoPartido = this.infoGroup.append("span");
    this.infoClust = this.infoGroup.append("span");
    this.infoBancada = this.infoGroup.append("span");

    this.divAfinidades = this.divInfo.append("div").attr("id", "divAfinidades");
    this.divTop5 = this.divAfinidades.append("div");
    this.divNotTop5 = this.divAfinidades.append("div");

    // add titles
    this.divTop5.append("h2").text("Top 5");
    this.divNotTop5.append("h2").text("Not Top 5");

    // create array for top5 and not top5 names
    this.top5Spans = [];
    this.notTop5Spans = [];
    for (var i=0; i<5; i++) {
        this.top5Spans.push(this.divTop5.append("span"));
        this.notTop5Spans.push(this.divNotTop5.append("span"));
    }

    // draw legend
    this.legend = new legenda(this.options);

    // set axes
    this.xAxis = d3.svg.axis()
        .scale(this.x)
        .ticks(0);
    this.yAxis = d3.svg.axis()
        .scale(this.y)
        .ticks(0)
        .orient("left");
}

graficoVotacoesAfinidades.prototype.getPartyColor = function (name) {
    if(this.options.coloredParties.includes(name)) {
        return this.color(name);
    }
    else {
        return this.color("outros");
    }
};

/**
  * @param data - datasource (MCA)
  * draws visualization
  */
graficoVotacoesAfinidades.prototype.draw = function (data) {
    // get data domain using d3.extent() function
    this.x.domain( d3.extent(data, function (d) {
        return d["Dim.1"];
    }) );
    this.y.domain( d3.extent(data, function (d) {
        return d["Dim.2"];
    }) );

    // draw axes and axis labels
    // x axis
    this.svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + (this.height - this.margin)/2 + ")")
        .call(this.xAxis);
    // y axis
    this.svg.append("g")
        .attr("class", "y axis")
        .attr("transform", "translate(" + (this.widthPlot - this.margin)/2 + ",0)")
        .call(this.yAxis);

    // save this because of different contexts
    var that = this;
    // style the circles, set their locations based on data
    var circles = this.svg.selectAll("circle")
        .data(data)
        .enter()
        .append("circle")
        .attr("class", "circles")
        .attr({
            cx: function(d) { return that.x(d["Dim.1"]); },
            cy: function(d) { return that.y(d["Dim.2"]); },
            r: 4,
            id: function(d) { return d["nome"]; }
        })
        .style("fill", function(d) {
            return that.getPartyColor(d["partido"]);
        });

    var nested = d3.nest()
        .key(function (d) {
            return d["id_dep"];
        })
        .entries(data);

    // what to do when we mouse over a bubble
    var mouseOnEvent = function() {
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
        // skip this functionality for IE9, which doesn"t like it
        if (!$.browser.msie) {
            circle.moveToFront();
        }
    };

    // what happens when we leave a bubble?
    var mouseOffEvent = function() {
    var circle = d3.select(this);
    // go back to original size and opacity
    circle.transition()
        .duration(800).style("opacity", .5)
        .attr("r", 4).ease("elastic");
    // fade out guide lines, then remove them
    d3.selectAll(".guide")
        .transition()
        .duration(100)
        .styleTween("opacity", function() {
            return d3.interpolate(.5, 0);
        })
        .remove()
    };

    var onClick = function(d) {
        var circle = d3.select(this);
        circle.transition()
            .duration(200)
            .style("opacity", .8)
            .attr("r", 20);
        // display politian's information
        that.imgDep.attr("src", d["urlFoto"]);
        that.infoName.text(d["nome"]);
        that.infoPartido.text(d["partido"].toUpperCase());
        that.infoClust.text(d["clust"]);
        if (d["destaque_bbb"] === "TRUE") {
            that.infoBancada.text("Bancada BBB");
        }
        else if (d["destaque_bancada_direitos_humanos"] === "TRUE") {
            that.infoBancada.text("Bancada DH");
        }
        else if (d["destaque_bancada_sindical"] === "TRUE") {
            that.infoBancada.text("Bancada sindical");
        }

        var topIds = d["afinidade"].split(",");
        var notTopIds = d["not_afinidade"].split(",");
        updateTop5(topIds, notTopIds);
        that.line.transition()
            .duration(800)
            .attr("x1", this.getAttribute("cx"))
            .attr("y1", this.getAttribute("cy"))
            .attr("x2", that.widthPlot)
            .attr("y2", 20)
            .attr("style", "stroke:" + that.getPartyColor(d["partido"]));
     // get color and change opacity
     var rgba = that.getPartyColor(d["partido"]).split(",");
     rgba[rgba.length-1] = "0.5)";
     rgba = rgba.join();
     that.infoDep.transition()
        .duration(800)
        .attr("style", "background-color:" + rgba);
    };


    /**
    * Update top5
    */
    function updateTop5(topIds, notTopIds) {
      for (var i=0; i < 5; i++) {
          nested.forEach(function (d) {
              // converted to int because of white spaces on id_dep field
              if (+topIds[i] === +d["key"]) {
                  that.top5Spans[i].text(d.values[0]["nome"]);
              }
              if (+notTopIds[i] === +d["key"]) {
                  that.notTop5Spans[i].text(d.values[0]["nome"]);
              }
          });
      }
    };

    // run the mouseon/out events
    circles.on("mouseover", mouseOnEvent);
    circles.on("mouseout", mouseOffEvent);
    // click event
    circles.on("click", onClick);
    // tooltips (using jQuery plugin tipsy)
    circles.append("title")
        .text(function(d) { return d["nome"]; })
    $(".circles").tipsy({ gravity: "s", });

};

graficoVotacoesAfinidades.prototype.updateOptions = function (options) {
    if (!options) return;
    if (options.hasOwnProperty("coloredParties")) {
        this.options.coloredParties = options.coloredParties.slice();
        this.options.coloredParties.push("outros");
    }
    if (options.hasOwnProperty("colorsVector")) this.options.colorsVector = options.colorsVector;
    // update color scale
    this.color = d3.scale.ordinal()
        .domain(this.options.coloredParties)
        .range(this.options.colorsVector);

    // update circle colors
    var that = this;
    this.svg.selectAll("circle")
        .style("fill", function(d) {
        if(that.options.coloredParties.includes(d["partido"])) {
            return that.color(d["partido"]);
        }
        else {
            return that.color("outros");
        }
      });

     this.legend.update(this.options);
};
