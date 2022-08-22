mutable struct World{T<:NamedTuple}
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

function getid(world, id)
    for dict in world.agents
        if haskey(dict, id)
            return dict[id], dict
        end
    end
end

function setid(world, id, a)
    getfield(world.agents, tosym(a))[id] = a
end

allids(w::World) = vcat([collect(keys(as)) for as in w.agents]...)
hasid(w::World, id::Int) = any(haskey(as,id) for as in w.agents)

function world_step!(world::World)
    for id in deepcopy(allids(world))
        !hasid(world,id) && continue
        #a = world.agents[id]
        a, _ = getid(world, id)
        agent_step!(a,world)
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
