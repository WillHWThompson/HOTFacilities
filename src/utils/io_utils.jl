using DrWatson




"""
--------------
IO Methods
--------------
"""

"""
load_pop_data: imports a csv file with simulated population into a file
"""
function load_pop_data(pop_path)
    df = DataFrame(CSV.File(pop_path))
    df_transformed = transform(df,[:lat,:lon] => ByRow((x,y)->Point2(y,x)))
    pop_vec = df_transformed.lat_lon_function
    static_pop_vec = SVector{length(pop_vec)}(pop_vec)

end

function csv_to_genome(csv_genome_file)
    df = DataFrame(CSV.File(csv_genome_file))
    fac_points = [] #Vector{Tuple{Float64,Float64}
    # make another column of Point2()
    transform!(df, :, [:lat,:lon] => ByRow(Point2) => :Points)

    genome = df[:, :Points] 
    #print(genome)
    return genome
end


"""
genome_to_csv(): translates a genome (vector of lat lon pairs) to a csv file
"""
function genome_to_csv(genome, output_path)
    genome_tuples = map((x)->x.data,genome)
    genome_tuples_lat = map((x)->x[1],genome_tuples)
    genome_tuples_lon = map((x)->x[2],genome_tuples)
    df = DataFrame(lon = genome_tuples_lon,lat = genome_tuples_lat)
    CSV.write(output_path, df)
   
    CSV.write(output_path, df)
end


"""
fitness_mat_to_tidy_df: 
given a fitness matrix of <num_runs> by <num_generations> containing tuples of the fitness and fitness drop, turn this into a tidy dataframe
"""
function fitness_mat_to_tidy_df(my_fitness_mat)
    df = DataFrame(run_num = Int[], gen_num = Int[], fitness = Float64[], fitness_diff = Float64[])
    # Iterate over each run in fitness_mat
    for (run_num, run_fitness) in enumerate(my_fitness_mat)
    # Iterate over each generation in run_fitness
        for (gen_num, (fitness, fitness_diff)) in enumerate(run_fitness)
        # Append a new row to the dataframe with the run number, generation number, fitness, and drop in fitness
            push!(df, [run_num, gen_num, fitness, fitness_diff])
       end
    end
    return df
end



function population_stats_to_tidy_df(my_population_stats)
    df = DataFrame(run_num = Int[], gen_num = Int[],ind_num = Int[], fitness = Float64[], fitness_diff = Float64[])
    # Iterate over each run in fitness_mat
    for (run_num, run_fitness) in enumerate(my_population_stats)
    # Iterate over each generation in run_fitness
        for (gen_num, gen_inds) in enumerate(run_fitness)
            for (ind_num,(fitness,fitness_diff)) in enumerate(gen_inds)
                # Append a new row to the dataframe with the run number, generation number, fitness, and drop in fitness
                push!(df, [run_num, gen_num,ind_num,fitness, fitness_diff])
            end
       end
    end
    return df
end

"""
write_results_to_files(): take the results, write the fitness values and the best individual from a run to a file
"""
function write_results_to_files(file_directory,fitness_mat,best_ind_list,population_stats,param_dict)

    #create metadata string for file name
    # file_meta_data = "$num_runs-$num_elements_to_mutate-$total_generations-$num_parents-$num_children-$crossover_points-$tournament_size-$num_tournament_winners-$(Int(elitisim)).csv"
    sorted_param_dict = sort(collect(param_dict),by =x->x[1])
    file_meta_data = join([i[2] for i in sorted_param_dict],"_")
    println(sorted_param_dict)
    #genearate fitness file name
    fitness_file_name = "fitness_$(file_meta_data).csv"
    fitness_file_path = "$(file_directory)/$(fitness_file_name)"
    #write fitness data to file
    

    fitness_df = fitness_mat_to_tidy_df(fitness_mat)
    #CSV.write(fitness_file_path,Tables.table(fitness_mat),bufsize = 70000000)
    CSV.write(fitness_file_path,fitness_df)
    println("Saved fitness data to: $(fitness_file_path)")
    
    #genearate fitness file name
    best_ind_file_name = "best_ind_$(file_meta_data).csv"
    best_ind_file_path = "$(file_directory)/$(best_ind_file_name)"

    for (run_i,best_ind_i) in enumerate(best_ind_list)
        println("run:$(run_i)")
        #generate the file_name
        best_ind_file_name_i = "best_ind_$(run_i)_$(file_meta_data).csv"
        best_ind_file_path_i = "$(file_directory)/$(best_ind_file_name_i)"
        #get the correct genome
        #save the genome to file
        best_ind_genome = last(best_ind_i)
        genome_to_csv(best_ind_genome,best_ind_file_path_i)
        println("Saved best_ind_genome data to: $(best_ind_file_path_i)")
    end

    #save the population_stats to a file
    population_stats_df = population_stats_to_tidy_df(population_stats)
    population_stats_file_name = "population_stats_$(file_meta_data).csv"
    population_stats_file_path = "$(file_directory)/$(population_stats_file_name)"
    #write fitness data to file
    CSV.write(population_stats_file_path,population_stats_df)
    println("Saved population_stats data to: $(population_stats_file_path)")



end


"""
get_geo_info(): returns a GeoGraphicInfo struct with all the points in the population as well as the shape of the us

"""
function init_geoinfo(pop_path = nothing)
    """
    LOAD POPULATION DATA
    """
    println("loading population data")

    if (pop_path == nothing)
        #pop_path = get_pop_path500()
       pop_path = get_pop_path3k()
       #pop_path = get_pop_path()#UNCOMMENT FOR FULL RUN
    end
    pop_points = load_pop_data(pop_path)

    """
    GET BOUNDARY SHAPE FILE
    """
     BOUNDARY_LOC = get_boundary_loc_path()
     us_shp = Shapefile.Handle(BOUNDARY_LOC)
     us_border = Shapefile.shapes(us_shp)[1]
     geo_info = GeographicInfo(us_border,pop_points)
    
     return geo_info
end
