var viz = new graficoVotacoesAfinidades();

function dataLoaded(data) {
    viz.draw(data);
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
}, dataLoaded);
