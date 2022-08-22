using EcosystemCore
using Random
Random.seed!(0)

function create_world()
    n_grass       = 500
    regrowth_time = 17.0

    n_sheep         = 100
    Δenergy_sheep   = 5.0
    sheep_reproduce = 0.5
    sheep_foodprob  = 0.4

    n_wolves       = 8
    Δenergy_wolf   = 17.0
    wolf_reproduce = 0.03
    wolf_foodprob  = 0.02

    gs = [Grass(id, regrowth_time) for id in 1:n_grass];
    ss = [Sheep(id, 2*Δenergy_sheep, Δenergy_sheep, sheep_reproduce, sheep_foodprob) for id in n_grass+1:n_grass+n_sheep];
    ws = [Wolf(id, 2*Δenergy_wolf, Δenergy_wolf, wolf_reproduce, wolf_foodprob) for id in n_grass+n_sheep+1:n_grass+n_sheep+n_wolves];
    World(vcat(gs, ss, ws))
end
world = create_world();

function simulate!(world::World, iters::Int; cb=()->())
    for i in 1:iters
        world_step!(world)
        cb()
    end
end

EcosystemCore.mates(a::Animal{S,Female}, b::Animal{S,Male}) where S<:Species = true
EcosystemCore.mates(a::Animal{S,Male}, b::Animal{S,Female}) where S<:Species = true
EcosystemCore.mates(a::Agent, b::Agent) = false

a = world.agents.animal_🐑♀ |> values |> first
#@info find_food(a, world)
#@btime find_food($a, $world)
#
#@info reproduce!(a, world)
#@btime reproduce!($a, $world)

@info agent_step!(a, world)
@btime agent_step!($a, $world)
# @code_warntype find_food(a, world)
#error()
#
#
##using BenchmarkTools
##@btime find_food($a,$world)
##N = 10
##@btime simulate!($world, $N)
#
#using Profile, ProfileSVG
#@profview simulate!(world,100)
#ProfileSVG.save("test.svg")
#
