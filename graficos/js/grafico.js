var options = {
    colorsVector: ["rgba(0,100,200,1)", "rgba(300,0,0,1)", "rgba(0,300,0,1)", "rgba(100,100,100,1)"],
    coloredParties: ["psdb", "rede", "ptb"]
};

var options2 = {
    colorsVector: ["rgba(0,400,200,1)", "rgba(100,0,0,1)", "rgba(0,300,0,1)", "rgba(100,100,100,1)"],
    coloredParties: ["pmdb", "pt", "rede"]
};

var viz = new graficoVotacoesAfinidades();
// var viz2 = new graficoVotacoesAfinidades();

// update example
viz.updateOptions(options);

function dataLoaded(data) {
    viz.draw(data);
};

function dataLoaded2(data) {
    // viz2.draw(data);
};

/**
  * initial function to load data and preprocess it
  * call draw function after loading is finished
  */
d3.csv("MCA_afinidades_notafinidades.csv", function(d) {
  // convert both dimensions to numbers
  d["Dim.1"] = +d["Dim.1"];
  d["Dim.2"] = +d["Dim.2"];
  return d;
}, dataLoaded);

d3.csv("evolucaoMCA/mca_antes_agosto.csv", function(d) {
  // convert both dimensions to numbers
  d["Dim.1"] = +d["Dim.1"];
  d["Dim.2"] = +d["Dim.2"];
  return d;
}, dataLoaded2);
