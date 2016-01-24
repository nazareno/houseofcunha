/**
 * @author Rodolfo Viana
 * @author Pedro Scaff
 */

"use strict";

// setup and append svg before loading data
// to avoid elements moving after loading
var margin = 75,
    widthPlot = 800 - margin,
    widthTop5 = 350,
    height = 650 - margin,
    x = d3.scale.linear().range([0, widthPlot - margin]),
    y = d3.scale.linear().range([height - margin, 0]),
    //colors that will reflect parties
    color = d3.scale.ordinal()
              .domain(["outros","pmdb","psdb","psol","pt"])
              .range(["rgba(189,189,189, 1)", "rgba(139, 0, 0, 1)", "rgba(0,102,204,1)", "rgba(230,159,0,1)", "rgba(255,51,0,1)"]);

// get visualization div
var svgWrapper = d3.select("#grafico");

// set up main graphic svg
var svg = svgWrapper.append("svg")
            .attr("width", widthPlot + margin)
            .attr("height", height + margin/2)
            .append("g")
            .attr("transform", "translate(" + margin + "," + margin/2 + ")")
            .attr("class", "chart");

// line to show active circle
var line = svg.append("line")
              .attr("opacity", 0.5)
              .attr("stroke-width", 2);

// all setup for politian's information layout
var divInfo = svgWrapper.append("div").attr("id", "divInfo");

var infoDep = divInfo.append("div").attr("id", "infoDep");

var imgDep = infoDep.append("img")
               .attr("width", 150)
               .attr("height", 200)
               .attr("id", "fotoDeputado");

var infoGroup = infoDep.append("div").attr("id", "infoGroup");

// variables to be updated on click event
var infoName = infoGroup.append("span");
var infoPartido = infoGroup.append("span");
var infoClust = infoGroup.append("span");
var infoBancada = infoGroup.append("span");

var divAfinidades = divInfo.append("div").attr("id", "divAfinidades");
var divTop5 = divAfinidades.append("div");
var divNotTop5 = divAfinidades.append("div");

// add titles
divTop5.append("h2").text("Top 5");
divNotTop5.append("h2").text("Not Top 5");

// create array for top5 and not top5 names
var top5Spans = [],
    notTop5Spans = [];
for (var i=0; i<5; i++) {
    top5Spans.push(divTop5.append("span"));
    notTop5Spans.push(divNotTop5.append("span"));
}

// draw legend
legenda();

// set axes
var xAxis = d3.svg.axis()
              .scale(x)
              .ticks(0);
var yAxis = d3.svg.axis()
              .scale(y)
              .ticks(0)
              .orient("left");

// array with featured parties that will be colored
var coloredParties = ["pmdb", "psdb", "psol", "pt"];

/**
  * callback function after data is loaded
  * draws visualization
  */
function draw(data) {
  // get data domain using d3.extent() function
  x.domain( d3.extent(data, function (d) {
    return d["Dim.1"];
  }) );
  y.domain( d3.extent(data, function (d) {
    return d["Dim.2"];
  }) );

  // draw axes and axis labels
  // x axis
  svg.append("g")
     .attr("class", "x axis")
     .attr("transform", "translate(0," + (height - margin)/2 + ")")
     .call(xAxis);
  // y axis
  svg.append("g")
     .attr("class", "y axis")
     .attr("transform", "translate(" + (widthPlot - margin)/2 + ",0)")
     .call(yAxis);

  // style the circles, set their locations based on data
  var circles = svg.selectAll("circle")
      .data(data)
      .enter()
      .append("circle")
      .attr("class", "circles")
      .attr({
        cx: function(d) { return x(d["Dim.1"]); },
        cy: function(d) { return y(d["Dim.2"]); },
        r: 4,
        id: function(d) { return d["nome"]; }
      })
      .style("fill", function(d) {
        if(coloredParties.includes(d["partido"])) {
          return color(d["partido"]);
        }
        else {
          return color("outros");
        }
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
      imgDep.attr("src", d["urlFoto"]);
      infoName.text(d["nome"]);
      infoPartido.text(d["partido"].toUpperCase());
      infoClust.text(d["clust"]);
      if (d["destaque_bbb"] === "TRUE") {
          infoBancada.text("Bancada BBB");
      }
      else if (d["destaque_bancada_direitos_humanos"] === "TRUE") {
          infoBancada.text("Bancada DH");
      }
      else if (d["destaque_bancada_sindical"] === "TRUE") {
          infoBancada.text("Bancada sindical");
      }

      var topIds = d["afinidade"].split(",");
      var notTopIds = d["not_afinidade"].split(",");
      updateTop5(topIds, notTopIds);
      line.transition()
          .duration(800)
          .attr("x1", this.getAttribute("cx"))
          .attr("y1", this.getAttribute("cy"))
          .attr("x2", widthPlot)
          .attr("y2", 20)
          .attr("style", "stroke:" + color(d["partido"]));

     // get color and change opacity
     var rgba = color(d["partido"]).split(",");
     rgba[rgba.length-1] = "0.5)";
     rgba = rgba.join();
     infoDep.transition()
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
                  top5Spans[i].text(d.values[0]["nome"]);
              }
              if (+notTopIds[i] === +d["key"]) {
                  notTop5Spans[i].text(d.values[0]["nome"]);
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

}

/**
  * initial function to load data and preprocess it
  * call draw function after loading is finished
  */
d3.csv("MCA_new.csv", function(d) {
  // convert both dimensions to numbers
  d["Dim.1"] = +d["Dim.1"];
  d["Dim.2"] = +d["Dim.2"];
  return d;
}, draw);
