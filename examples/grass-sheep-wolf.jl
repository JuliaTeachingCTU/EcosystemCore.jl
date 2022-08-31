using EcosystemCore
using Random
Random.seed!(8)

function create_world()
    n_grass  = 3000
    n_sheep  = 200
    n_wolves = 1

    gs = [Grass(id) for id in 1:n_grass];
    ss = [Sheep(id) for id in n_grass+1:n_grass+n_sheep];
    wm = [Wolf(id,S=Female) for id in n_grass+n_sheep+1:n_grass+n_sheep+n_wolves];
    wf = [Wolf(id,S=Male) for id in n_grass+n_sheep+n_wolves+1:n_grass+n_sheep+n_wolves*2];
    World(vcat(gs, ss, wm, wf))
end
world = create_world();

agent_count(p::Plant) = p.size / p.max_size
agent_count(::Animal) = 1
agent_count(as::Vector{<:Agent}) = sum(agent_count,as,init=0)
agent_count(d::Dict) = agent_count(d |> values |> collect)
agent_count(w::World) = Dict(eltype(as |> values)=>agent_count(as) for as in w.agents)

counts = Dict(n=>[c] for (n,c) in agent_count(world))
for _ in 1:200
    world_step!(world)
    for (n,c) in agent_count(world)
        push!(counts[n],c)
    end
end

using Plots
plt = plot()
for (n,c) in counts
    plot!(plt, c, label=EcosystemCore.tosym(n) |> String, lw=2)
end
display(plt)
#error()

function simulate!(world::World, iters::Int; cb=()->())
    for i in 1:iters
        world_step!(world)
        cb()
    end
end

using BenchmarkTools
#@btime find_food($a,$world)
N = 10
@btime simulate!($world, $N)

@profview simulate!(world,100)
