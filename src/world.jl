mutable struct World{A<:Agent}
    agents::Dict{Int,A}
    max_id::Int
end

function World(agents::Vector{<:Agent})
    ids = id.(agents)
    length(unique(ids)) == length(agents) || error("Not all agents have unique IDs!")
    World(Dict(id(a)=>a for a in agents), maximum(ids))
end

function world_step!(world::World)
    for id in deepcopy(keys(world.agents))
        !haskey(world.agents,id) && continue
        a = world.agents[id]
        agent_step!(a,world)
    end
end

function Base.show(io::IO, w::World)
    println(io, typeof(w))
    for (_,a) in w.agents
        println(io,"  $a")
    end
end
