using DrWatson

using Plots
using VoronoiCells
using GeometryBasics
using Random
using Shapefile
using GeoInterface
using NearestNeighbors
using StaticArrays
using DataFrames
using Statistics
using StatsBase
using Distributions
using Rasters   


const RAND_INTERVAL = 0.001

@quickactivate "HOTFacilities"

#include(srcdir("genome.jl"))
include(srcdir("data_structures","GeoInfo.jl"))
include(srcdir("data_structures","Individual.jl"))
include(srcdir("data_structures","VoronoiIndividual.jl"))

include(srcdir("evolutionary_operators","selection.jl"))
include(srcdir("evolutionary_operators","mutation.jl"))

include(srcdir("perturbations","catastrophe.jl"))

include(srcdir("utils/","io_utils.jl"))
include(srcdir("utils/","analysis_utils.jl"))
include(srcdir("utils/","run_evo_alg.jl"))


include(srcdir("algorithms/","evo_algorithm.jl"))
include(srcdir("algorithms/","sim_anneal.jl"))



