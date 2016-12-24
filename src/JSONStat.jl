module JSONStat

using DataStructures, DataFrames

export readjsondataset, readjsonbundle, writejsondataset, labelframe


optkeys = Dict(
		"dataset" => [
			"version"; "class"; "role"; "label"; "updated"; "source";
			"extension"; "href";"link"; "note"; "error"
			],
		"dimid" => [
			"label"
			],
		"category" => [
			"label"; "child"; "coordinates"; "unit"; "note"
			]
	)

function dimframe(id, dimjsonstat)
	dimid = dimjsonstat[id]
	dimcat = dimid["category"]
	dimdict = DataStructures.OrderedDict()
	dimdict["category"] = DataStructures.OrderedDict()
	if haskey(dimcat, "index")
		dimdata = dimcat["index"]
	else
		dimdata = dimcat["label"]
	end
	for key in keys(dimid)
		if key in optkeys["dimid"]
			dimdict[key] = dimid[key]
		end
	end
	for key in keys(dimcat)
		if key in optkeys["category"]
			dimdict["category"][key] = dimcat[key]
		end
	end
	dimframe = DataFrame()
	if typeof(dimdata)<:DataStructures.OrderedDict
		dimframe[Symbol(id)] = collect(keys(dimdata))
	else
		dimframe[Symbol(id)] = dimdata
	end
	dimdict["dimframe"] = dimframe
	id => dimdict
end

function readjsondataset(datasetjsonstat)
	if haskey(datasetjsonstat, "version")
		idarr = datasetjsonstat["id"]
	else
		idarr = datasetjsonstat["dimension"]["id"]
	end
	dimension = DataStructures.OrderedDict(map((x)->
		dimframe(x, datasetjsonstat["dimension"]), idarr))
	dimkeys = collect(keys(dimension))
	datasetframe = dimension[dimkeys[1]]["dimframe"]
	for i in 2:size(dimkeys)[1]
		datasetframe = join(datasetframe, dimension[dimkeys[i]]["dimframe"],
			kind = :cross)
	end
	datasetframe[:value] = datasetjsonstat["value"]
	datasetdict = DataStructures.OrderedDict()
	for key in keys(datasetjsonstat)
		if key in optkeys["dataset"]
			datasetdict[key] = datasetjsonstat[key]
		end
	end
	datasetdict["dimension"] = dimension
	datasetdict["datasetframe"] = datasetframe
	datasetdict
end

function labelframe(id, datasetdict)
	labeldict = datasetdict["dimension"][id]["category"]["label"]
	labelframe = DataFrame()
	labelframe[Symbol(id)] = collect(keys(labeldict))
	labelframe[Symbol("$(id)_label")] = collect(values(labeldict))
	labelframe
end

function readjsonbundle(bundlejsonstat)
	bundledict = DataStructures.OrderedDict()
	for key in keys(bundlejsonstat)
		if haskey(bundlejsonstat[key], "value")
			bundledict[key] = readjsondataset(bundlejsonstat[key])
		end
	end
	bundledict
end

function writedimid(id, datasetjsonstat)
	datasetjsonstat["id"] = vcat(datasetjsonstat["id"], id)
	dimid = datasetjsonstat["dimension"][id]
	dimcat = dimid["category"]
	dimframe = dimid["dimframe"]
	dimsize = size(dimframe)[1]
	datasetjsonstat["size"] = vcat(datasetjsonstat["size"], dimsize)
	dimzip = zip(dimframe[Symbol(id)], collect(0:dimsize-1))
	dimcat["index"] = DataStructures.OrderedDict(dimzip)
	delete!(dimid, "dimframe")
end

function writejsondataset(datasetdict)
	datasetjsonstat = deepcopy(datasetdict)
	if !(haskey(datasetjsonstat, "version"))
		datasetjsonstat["version"] = "2.0"
	end
	datasetjsonstat["id"] = []
	datasetjsonstat["size"] = []
	datasetjsonstat["value"] = datasetjsonstat["datasetframe"][:value]
	delete!(datasetjsonstat, "datasetframe")
	idarr = collect(keys(datasetjsonstat["dimension"]))
	foreach((x)->writedimid(x, datasetjsonstat), idarr)
	datasetjsonstat
end

end # module
