module EcosystemCore

using StatsBase

export World
export Species, PlantSpecies, AnimalSpecies, Grass, Sheep, Wolf
export Sex, Female, Male
export Agent, Plant, Animal
export agent_step!, eat!, eats, find_food, reproduce!

export fully_grown, energy

abstract type Species end
abstract type Agent{S<:Species} end

struct World{T<:Agent}
    agents::Vector{T}
end
function Base.show(io::IO, w::World)
    println(io, typeof(w))
    map(a->println(io,"  $a"),w.agents)
end


abstract type PlantSpecies <: Species end
abstract type Grass <: PlantSpecies end

mutable struct Plant{P<:PlantSpecies} <: Agent{P}
    fully_grown::Bool
    regrowth_time::Int
    countdown::Int
end

function (A::Type{<:PlantSpecies})(fully_grown, regrowth_time, countdown)
    Plant{A}(fully_grown, regrowth_time, countdown)
end
(A::Type{<:PlantSpecies})(r) = (A::Type{<:PlantSpecies})(false,r,rand(1:r))


function Base.show(io::IO, p::Plant{P}) where P
    x = if p.fully_grown
        100
    else
        min(100-(p.countdown/p.regrowth_time*100),99)
    end
    print(io,"$P  $(round(Int,x))% grown")
end

Base.show(io::IO, ::Type{Grass}) = print(io,"🌿")

function agent_step!(p::Plant, w::World)
    if !p.fully_grown
        if p.countdown <= 0
            p.fully_grown = true
            p.countdown = p.regrowth_time
        else
            p.countdown -= 1
        end
    end
    return p
end




abstract type AnimalSpecies <: Species end
abstract type Sheep <: AnimalSpecies end
abstract type Wolf <: AnimalSpecies end

abstract type Sex end
abstract type Male <: Sex end
abstract type Female <: Sex end

mutable struct Animal{A<:AnimalSpecies,S<:Sex,T<:Real} <: Agent{A}
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

# function (A::Type{<:AnimalSpecies})(E::T,ΔE::T,pr::T,pf::T,S::Type{<:Sex}) where T<:Real
#     Animal{A,S,T}(E,ΔE,pr,pf)
# end
# function (A::Type{<:AnimalSpecies})(E::T,ΔE::T,pr::T,pf::T) where T<:Real
#     A(E,ΔE,pr,pf,rand(Bool) ? Female : Male)
# end

function agent_step!(a::Animal, w::World)
    a.energy -= 1
    dinner = find_food(a,w)
    eat!(a, dinner, w)
    if a.energy < 0
        kill_agent!(a,w)
        return
    end
    if rand() <= a.reproduction_prob
        reproduce!(a,w)
    end
    return a
end

function find_food(a::Animal, w::World)
    if rand() <= a.food_prob
        as = filter(x->eats(a,x), w.agents)
        isempty(as) ? nothing : sample(as)
    end
end

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

kill_agent!(a::Animal, w::World) = deleteat!(w.agents, findall(x->x==a, w.agents))

function reproduce!(a::Animal, w::World)
    b = find_mate(a,w)
    if !isnothing(b)
        a.energy /= 2
        # TODO: should probably mix a/b
        push!(w.agents, deepcopy(a))
    end
end

function find_mate(a::Animal, w::World)
    # TODO: equality check should be done with id
    bs = filter(x -> mates(a,x), w.agents)
    isempty(bs) ? nothing : sample(bs)
end

mates(::Animal{A,Male}, ::Animal{A,Female}) where A<:AnimalSpecies = true
mates(::Animal{A,Female}, ::Animal{A,Male}) where A<:AnimalSpecies = true
mates(::Agent, ::Agent) = false




fully_grown(a::Plant) = a.fully_grown
fully_grown!(a::Plant, b::Bool) = a.fully_grown = b
countdown(a::Plant) = a.countdown
countdown!(a::Plant, c::Int) = a.countdown = c
incr_countdown!(a::Plant, Δc::Int) = countdown!(a, countdown(a)+Δc)
reset!(a::Plant) = a.countdown = a.regrowth_time

energy(a::Animal) = a.energy
energy!(a::Animal, e) = a.energy = e
incr_energy!(a::Animal, Δe) = energy!(a, energy(a)+Δe)
Δenergy(a::Animal) = a.Δenergy
reproduction_prob(a::Animal) = a.reproduction_prob
food_prob(a::Animal) = a.food_prob



# abstract type AbstractAgent end
# abstract type AbstractPlant <: AbstractAgent end
# abstract type AbstractAnimal <: AbstractAgent end
# 
# fully_grown(a::AbstractPlant) = a.fully_grown
# fully_grown!(a::AbstractPlant, b::Bool) = a.fully_grown = b
# countdown(a::AbstractPlant) = a.countdown
# countdown!(a::AbstractPlant, c::Int) = a.countdown = c
# incr_countdown!(a::AbstractPlant, Δc::Int) = countdown!(a, countdown(a)+Δc)
# reset!(a::AbstractPlant) = a.countdown = a.regrowth_time
# 
# energy(a::AbstractAnimal) = a.energy
# energy!(a::AbstractAnimal, e) = a.energy = e
# incr_energy!(a::AbstractAnimal, Δe) = energy!(a, energy(a)+Δe)
# Δenergy(a::AbstractAnimal) = a.Δenergy
# reproduction_prob(a::AbstractAnimal) = a.reproduction_prob
# food_prob(a::AbstractAnimal) = a.food_prob
# 
# mutable struct Grass <: AbstractPlant
#     fully_grown::Bool
#     regrowth_time::Int
#     countdown::Int
# end
# Grass(t) = Grass(false, t, rand(1:t))
# Grass() = Grass(2)
# function Base.show(io::IO,g::Grass)
#     p = if g.fully_grown
#         100
#     else
#         min(100-(g.countdown/g.regrowth_time*100),99)
#     end
#     print(io,"🌿 $(round(Int,p))% grown")
# end
# 
# mutable struct Sheep{T<:Real} <: AbstractAnimal
#     energy::T
#     Δenergy::T
#     reproduction_prob::T
#     food_prob::T
# end
# Base.show(io::IO,s::Sheep) = print(io,"🐑 E=$(energy(s)) ΔE=$(Δenergy(s)) pr=$(reproduction_prob(s)) pf=$(food_prob(s))")
# 
# mutable struct Wolf{T<:Real} <: AbstractAnimal
#     energy::T
#     Δenergy::T
#     reproduction_prob::T
#     food_prob::T
# end
# Base.show(io::IO,w::Wolf) = print(io,"🐺 E=$(energy(w)) ΔE=$(Δenergy(w)) pr=$(reproduction_prob(w)) pf=$(food_prob(w))")
# 
# struct World{T<:AbstractAgent}
#     agents::Vector{T}
# end
# function Base.show(io::IO, w::World)
#     println(io, typeof(w))
#     map(a->println(io,"  $a"),w.agents)
# end
# 
# function agent_step!(a::AbstractPlant, w::World)
#     if !fully_grown(a)
#         if countdown(a) <= 0
#             fully_grown!(a,true)
#             reset!(a)
#         else
#             incr_countdown!(a,-1)
#         end
#     end
#     return a
# end
# 
# function agent_step!(a::AbstractAnimal, w::World)
#     incr_energy!(a,-1)
#     dinner = find_food(a,w)
#     eat!(a, dinner, w)
#     if energy(a) < 0
#         kill_agent!(a,w)
#         return
#     end
#     if rand() <= reproduction_prob(a)
#         reproduce!(a,w)
#     end
#     return a
# end
# 
# function find_food(a::AbstractAnimal, w::World)
#     if rand() <= food_prob(a)
#         as = filter(x->eats(a,x), w.agents)
#         isempty(as) ? nothing : sample(as)
#     end
# end
# 
# eats(::Sheep,::Grass) = true
# eats(::Wolf,::Sheep) = true
# eats(::AbstractAgent,::AbstractAgent) = false
# 
# function eat!(wolf::Wolf, sheep::Sheep, w::World)
#     kill_agent!(sheep,w)
#     incr_energy!(wolf, Δenergy(wolf))
# end
# function eat!(sheep::Sheep, grass::Grass, w::World)
#     if fully_grown(grass)
#         fully_grown!(grass, false)
#         incr_energy!(sheep, Δenergy(sheep))
#     end
# end
# eat!(::AbstractAnimal,::Nothing,::World) = nothing
# 
 
# kill_agent!(a::AbstractAnimal, w::World) = deleteat!(w.agents, findall(x->x==a, w.agents))

end # module
