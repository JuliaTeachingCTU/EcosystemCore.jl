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
        Dict{Int,T}(a.id=>a for a in as)
    end
    nt = (; zip(tosym.(types), ags)...)
    
    ids = [a.id for a in agents]
    length(unique(ids)) == length(agents) || error("Not all agents have unique IDs!")
    World(nt, maximum(ids))
end

function world_step!(world::World)
    map(world.agents) do species
        ids = copy(keys(species))
        for id in ids
            !haskey(species,id) && continue
            a = species[id]
            agent_step!(a, world)
        end
    end
end

function Base.show(io::IO, w::World)
    ts = join([valtype(a) for a in w.agents], ", ")
    println(io, "World[$ts]")
    for dict in w.agents
        for (_,a) in dict
            println(io,"  $a")
        end
    end
end
