module EcosystemCore

using StatsBase

export Grass, Sheep, Wolf, World, AbstractAgent, AbstractPlant, AbstractAnimal
export fully_grown, fully_grown!, countdown, countdown!, incr_countdown!, reset!
export energy, energy!, incr_energy!, Δenergy, reproduction_prob, food_prob
export agent_step!, eat!, eats, find_food, reproduce!, simulate!

abstract type Agent end
abstract type Animal <: Agent end
abstract type Plant <: Agent end

struct World{A<:Agent}
    agents::Dict{Int,A}
end
World(agents::Vector{<:Agent}) = World(Dict(a.id=>a for a in agents))

# optional code snippet: you can overload the `show` method to get custom
# printing of your World
function Base.show(io::IO, w::World)
    println(io, typeof(w))
    for (id,a) in w.agents
        println(io,"  $a id:$id")
    end
end

function simulate!(world::World, iters::Int; callbacks=[])
    for i in 1:iters
        for id in deepcopy(keys(world.agents))
            !haskey(world.agents,id) && continue
            a = world.agents[id]
            agent_step!(a,world)
        end
        for cb in callbacks
            cb(world)
        end
    end
end

function agent_step!(a::Plant, w::World)
    if !fully_grown(a)
        if countdown(a) <= 0
            fully_grown!(a,true)
            reset!(a)
        else
            incr_countdown!(a,-1)
        end
    end
    return a
end

function agent_step!(a::Animal, w::World)
    incr_energy!(a,-1)
    dinner = find_food(a,w)
    eat!(a, dinner, w)
    if energy(a) <= 0
        kill_agent!(a,w)
        return
    end
    if rand() <= reproduction_prob(a)
        reproduce!(a,w)
    end
    return a
end

mutable struct Grass <: Plant
    id::Int
    fully_grown::Bool
    regrowth_time::Int
    countdown::Int
end
Grass(id,t) = Grass(id,false, t, rand(1:t))

# get field values
id(a::Agent) = a.id
fully_grown(a::Plant) = a.fully_grown
countdown(a::Plant) = a.countdown

# set field values
# (exclamation marks `!` indicate that the function is mutating its arguments)
fully_grown!(a::Plant, b::Bool) = a.fully_grown = b
countdown!(a::Plant, c::Int) = a.countdown = c
incr_countdown!(a::Plant, Δc::Int) = countdown!(a, countdown(a)+Δc)

# reset plant couter once it's grown
reset!(a::Plant) = a.countdown = a.regrowth_time

mutable struct Sheep <: Animal
    id::Int
    energy::Float64
    Δenergy::Float64
    reproduction_prob::Float64
    food_prob::Float64
end

# get field values
energy(a::Animal) = a.energy
Δenergy(a::Animal) = a.Δenergy
reproduction_prob(a::Animal) = a.reproduction_prob
food_prob(a::Animal) = a.food_prob

# set field values
energy!(a::Animal, e) = a.energy = e
incr_energy!(a::Animal, Δe) = energy!(a, energy(a)+Δe)

function eat!(sheep::Sheep, grass::Grass, w::World)
    if fully_grown(grass)
        fully_grown!(grass, false)
        incr_energy!(sheep, Δenergy(sheep))
    end
end

mutable struct Wolf <: Animal
    id::Int
    energy::Float64
    Δenergy::Float64
    reproduction_prob::Float64
    food_prob::Float64
end

function eat!(wolf::Wolf, sheep::Sheep, w::World)
    kill_agent!(sheep,w)
    incr_energy!(wolf, Δenergy(wolf))
end
eat!(a::Animal,b::Nothing,w::World) = nothing

kill_agent!(a::Animal, w::World) = delete!(w.agents, id(a))

using StatsBase
function find_food(a::Animal, w::World)
    if rand() <= food_prob(a)
        as = filter(x->eats(a,x), w.agents |> values |> collect)
        isempty(as) ? nothing : sample(as)
    end
end

eats(::Sheep,::Grass) = true
eats(::Wolf,::Sheep) = true
eats(::Agent,::Agent) = false

function reproduce!(a::A, w::World) where A
    energy!(a, energy(a)/2)
    a_vals = [getproperty(a,n) for n in fieldnames(A) if n!=:id]
    â = A(newid(w), a_vals...)
    w.agents[id(â)] = â
end
newid(w::World) = maximum([a.id for a in values(w.agents)])+1

end # module
