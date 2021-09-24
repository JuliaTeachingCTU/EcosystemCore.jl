module EcosystemCore

using StatsBase

export World
export Species, PlantSpecies, AnimalSpecies, Grass, Sheep, Wolf
export Sex, Female, Male
export Agent, Plant, Animal
export agent_step!, eat!, eats, find_food, reproduce!, simulate!

export fully_grown, fully_grown!, countdown, countdown!, incr_countdown!, reset!
export energy, energy!, incr_energy!, Δenergy, reproduction_prob, food_prob



abstract type Species end
abstract type Agent{S<:Species} end

mutable struct World{A<:Agent}
    agents::Dict{Int,A}
    max_id::Int
end
function World(agents::Vector{<:Agent})
    World(Dict(id(a)=>a for a in agents), maximum(id.(agents)))
end

# optional code snippet: you can overload the `show` method to get custom
# printing of your World
function Base.show(io::IO, w::World)
    println(io, typeof(w))
    for (_,a) in w.agents
        println(io,"  $a")
    end
end



abstract type PlantSpecies <: Species end
abstract type Grass <: PlantSpecies end

mutable struct Plant{P<:PlantSpecies} <: Agent{P}
    id::Int
    fully_grown::Bool
    regrowth_time::Int
    countdown::Int
end

function (A::Type{<:PlantSpecies})(id, fully_grown, regrowth_time, countdown)
    Plant{A}(id, fully_grown, regrowth_time, countdown)
end
(A::Type{<:PlantSpecies})(id,r) = (A::Type{<:PlantSpecies})(id,false,r,rand(1:r))

function Base.show(io::IO, p::Plant{P}) where P
    x = if p.fully_grown
        100
    else
        min(100-(p.countdown/p.regrowth_time*100),99)
    end
    print(io,"$P  $(round(Int,x))% grown")
end

Base.show(io::IO, ::Type{Grass}) = print(io,"🌿")

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



abstract type AnimalSpecies <: Species end
abstract type Sheep <: AnimalSpecies end
abstract type Wolf <: AnimalSpecies end

abstract type Sex end
abstract type Male <: Sex end
abstract type Female <: Sex end

mutable struct Animal{A<:AnimalSpecies,S<:Sex,T<:Real} <: Agent{A}
    id::Int
    energy::T
    Δenergy::T
    reproduction_prob::T
    food_prob::T
end

Base.show(io::IO, ::Type{Sheep}) = print(io,"🐑")
Base.show(io::IO, ::Type{Wolf}) = print(io,"🐺")
Base.show(io::IO, ::Type{Male}) = print(io,"♂")
Base.show(io::IO, ::Type{Female}) = print(io,"♀")
function Base.show(io::IO, a::Animal{A,S}) where {A,S}
    e = a.energy
    d = a.Δenergy
    pr = a.reproduction_prob
    pf = a.food_prob
    print(io,"$A$S E=$e ΔE=$d pr=$pr pf=$pf")
end

function (A::Type{<:AnimalSpecies})(id::Int,E::T,ΔE::T,pr::T,pf::T,S::Type{<:Sex}) where T<:Real
    Animal{A,S,T}(id,E,ΔE,pr,pf)
end
function (A::Type{<:AnimalSpecies})(id::Int,E::T,ΔE::T,pr::T,pf::T) where T<:Real
    A(id,E,ΔE,pr,pf,rand(Bool) ? Female : Male)
end

# get field values
energy(a::Animal) = a.energy
Δenergy(a::Animal) = a.Δenergy
reproduction_prob(a::Animal) = a.reproduction_prob
food_prob(a::Animal) = a.food_prob

# set field values
energy!(a::Animal, e) = a.energy = e
incr_energy!(a::Animal, Δe) = energy!(a, energy(a)+Δe)

eats(::Animal{Sheep},::Plant{Grass}) = true
eats(::Animal{Wolf},::Animal{Sheep}) = true
eats(::Agent,::Agent) = false

function eat!(wolf::Animal{Wolf}, sheep::Animal{Sheep}, w::World)
    kill_agent!(sheep,w)
    wolf.energy += wolf.Δenergy
end
function eat!(sheep::Animal{Sheep}, grass::Plant{Grass}, w::World)
    if grass.fully_grown
        grass.fully_grown = false
        sheep.energy += sheep.Δenergy
    end
end
eat!(::Animal,::Nothing,::World) = nothing



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

function find_food(a::Animal, w::World)
    if rand() <= food_prob(a)
        as = filter(x->eats(a,x), w.agents |> values |> collect)
        isempty(as) ? nothing : sample(as)
    end
end

function reproduce!(a::A, w::World) where A
    energy!(a, energy(a)/2)
    a_vals = [getproperty(a,n) for n in fieldnames(A) if n!=:id]
    new_id = w.max_id + 1
    â = A(new_id, a_vals...)
    w.agents[id(â)] = â
    w.max_id = new_id
end

kill_agent!(a::Animal, w::World) = delete!(w.agents, id(a))

end # module
