using DataGraphs
using Dictionaries
using Graphs

vdata = dictionary([1 => "V1", 2 => "V2", 3 => "V3", 4 => "V4"])
edata = dictionary([Edge(1, 2) => "E12", Edge(2, 3) => "E23", Edge(3, 4) => "E34"])
dg = DataGraph(g, vdata, edata)

@show dg[1] == "V1"
@show dg[2] == "V2"
@show dg[3] == "V3"
@show dg[4] == "V4"

@show dg[1 => 2] == "E12"
@show dg[2 => 3] == "E23"
@show dg[3 => 4] == "E34"

@show DataGraph(g) isa DataGraph{Any,Any}
@show DataGraph{String}(g) isa DataGraph{String,Any}
@show DataGraph{<:Any,String}(g) isa DataGraph{Any,String}

vdata = [1 => "V1", 2 => "V2", 3 => "V3", 4 => "V4"]
edata = [(1, 2) => "E12", (2 => 3) => "E23", Edge(3, 4) => "E34"]
dg = DataGraph(g, vdata, edata)

@show dg[1] == "V1"
@show dg[2] == "V2"
@show dg[3] == "V3"
@show dg[4] == "V4"

@show dg[1 => 2] == "E12"
@show dg[2 => 3] == "E23"
@show dg[3 => 4] == "E34"

vdata = ["V1", "V2", "V3", "V4"]
edata = [(1, 2) => "E12", (2 => 3) => "E23", Edge(3, 4) => "E34"]
dg = DataGraph(g, vdata, edata)

@show dg[1] == "V1"
@show dg[2] == "V2"
@show dg[3] == "V3"
@show dg[4] == "V4"

@show dg[1 => 2] == "E12"
@show dg[2 => 3] == "E23"
@show dg[3 => 4] == "E34"

vdata = ["V1", "V2", "V3", "V4"]
edata = ["E12", "E23", "E34"]
dg = DataGraph(g, vdata, edata)

@show dg[1] == "V1"
@show dg[2] == "V2"
@show dg[3] == "V3"
@show dg[4] == "V4"

@show dg[1 => 2] == "E12"
@show dg[2 => 3] == "E23"
@show dg[3 => 4] == "E34"

vdata = ["V1", "V2", "V3", "V4"]
edata = [Edge(1, 2) => "E12", Edge(2, 3) => "E23"]
dg = DataGraph(g; vertex_data=vdata, edge_data=edata)

@show dg[1] == "V1"
@show dg[2] == "V2"
@show dg[3] == "V3"
@show dg[4] == "V4"

@show dg[1 => 2] == "E12"
@show dg[2 => 3] == "E23"
@show !isassigned(dg, 3 => 4)

vdata = ["V1", "V2", "V3", "V4"]
dg = DataGraph(g; vertex_data=vdata)

@show dg[1] == "V1"
@show dg[2] == "V2"
@show dg[3] == "V3"
@show dg[4] == "V4"

@show !isassigned(dg, 1 => 2)
@show !isassigned(dg, 2 => 3)
@show !isassigned(dg, 3 => 4)
