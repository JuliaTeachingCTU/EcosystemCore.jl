mutable struct World{T<:NamedTuple}
    # this is a NamedTuple of Dict{Int,<:Agent}
    # but I don't know how to express that as a parametric type
    agents::T
    max_id::Int
end

function World(agents::Vector{<:Agent})
    types = unique(typeof.(agents))
    ags = map(types) do T
        as = filter(x -> isa(x,T), agents)
        Dict{Int,T}(id(a)=>a for a in as)
    end
    nt = (; zip(tosym.(types), ags)...)
    
    ids = id.(agents)
    length(unique(ids)) == length(agents) || error("Not all agents have unique IDs!")
    World(nt, maximum(ids))
end

function world_step!(world::World)
    for species in world.agents
        ids = deepcopy(keys(species))
        for id in ids
            !haskey(species,id) && continue
            a = species[id]
            agent_step!(a, world)
        end
    end
end

function Base.show(io::IO, w::World)
    println(io, "World")
    for dict in w.agents
        for (_,a) in dict
            println(io,"  $a")
        end
    end
end
