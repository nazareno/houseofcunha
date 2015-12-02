/**
 * Created by tarciso on 25/11/15.
 */

function getPoliticianImgURL(p) {
    return p["urlFoto"] === "NA"? "../images/deputado_sem_foto.PNG" : p["urlFoto"];
}

function buildMap(highlight_column_name) {
    var margin = {top: 20, right: 20, bottom: 30, left: 40},
        width = 1200 - margin.left - margin.right,
        height = 800 - margin.top - margin.bottom;

    var x = d3.scale.linear()
        .range([0, width-50]);

    var y = d3.scale.linear()
        .range([height, 0]);

    var xAxis = d3.svg.axis()
        .scale(x)
        .orient("bottom").ticks(0);

    var yAxis = d3.svg.axis()
        .scale(y)
        .orient("left").ticks(0);

    //     setup fill color
    var cValue = function(d) { return d["destaque_partido"];},
        color = d3.scale.ordinal()
        .range(["#BDBDBD", "#FF3300", "darkred", "#0066CC", "#E69F00"]);;

    var svg = d3.select("body").append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    // add the tooltip area to the webpage
    var tooltip = d3.select("body").append("div")
        .attr("class", "tooltip")
        .style("opacity", 0);

    d3.csv("../data/destaques.csv", function(error, data) {
        if (error) throw error;

        data.forEach(function(d) {
            d["Dim.1"] = +d["Dim.1"];
            d["Dim.2"] = +d["Dim.2"];
        });


        x.domain(d3.extent(data, function(d) { return d["Dim.1"]; })).nice();
        y.domain(d3.extent(data, function(d) { return d["Dim.2"]; })).nice();

        svg.append("g")
            .attr("class", "x axis")
            .attr("transform", "translate(0," + (height+250)/2 + ")")
            .call(xAxis)
            .append("text")
//                .style("text-anchor", "end")
//                .text("Direita");

        svg.append("g")
            .attr("class", "y axis")
            .attr("transform", "translate(" + (width-50)/2 + ",0)")
            .call(yAxis)
            .append("text")
//                .style("text-anchor", "end")
//                .text("Liberal")


        svg.selectAll(".dot")
            .data(data)
            .enter().append("circle")
            .attr("class", "dot")
            .attr("id", "pt")
            .attr("r", 4)
            .attr("cx", function(d) { return x(d["Dim.1"]); })
            .attr("cy", function(d) { return y(d["Dim.2"]); })
            .style("fill", function(d) { return color(cValue(d));})
            .style("opacity", function(d) { return d[highlight_column_name] === "TRUE"? 0.9 : 0.1 })
            //Show Tooltip with candidate name and party

            .on("mouseover", function(d) {
                if (d[highlight_column_name] === "TRUE") {
                    tooltip.transition()
                        .duration(800)
                        .style("opacity", .8);
                    tooltip.html("<div style=background-color:white;> <img src='" + getPoliticianImgURL(d) + "' height=60 width=auto> <br/>" +
                            d["nome.x"] + "<br/>" + d["partido.x"].toUpperCase() + " - (" + d["uf.x"].toUpperCase() + ") </div>")
                        .style("left", (d3.event.pageX - 50) + "px")
                        .style("top", (d3.event.pageY - 110) + "px");

                    d3.select(this).attr("r", 12).ease("elastic");
                }

                // function to move mouseover item to front of SVG stage, in case
                // another bubble overlaps it
                d3.selection.prototype.moveToFront = function () {
                    return this.each(function () {
                        this.parentNode.appendChild(this);
                    });
                };

                // skip this functionality for IE9, which doesn't like it
                if (!$.browser.msie) {
                    circle.moveToFront();
                }

            })


            .on("mouseout", function(d) {
                if (d[highlight_column_name] === "TRUE") {

                    tooltip.transition()
                        .duration(800).style("opacity", .5)
                        .style("opacity", 0);
                    d3.select(this).attr("r", 4).ease("elastic");
                    // fade out guide lines, then remove them
                    d3.selectAll(".guide").transition().duration(100).styleTween("opacity",
                        function () {
                            return d3.interpolate(.5, 0);
                        })
                        .remove()
                }
            });


        var legend = svg.selectAll(".legend")
            .data(color.domain())
            .enter().append("g")
            .attr("class", "legend")
            .attr("transform", function(d, i) { return "translate(0," + i * 20 + ")"; });


        legend.append("rect")
            .attr("x", width + 10)
            .attr("width", 18)
            .attr("height", 18)
            .style("fill", color);

        legend.append("text")
            .attr("x", width)
            .attr("y", 9)
            .attr("dy", ".35em")
            .style("text-anchor", "end")
            .text(function(d) { return d; });




    });
}

