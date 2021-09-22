module EcosystemCore

using StatsBase

export Grass, Sheep, Wolf, World, AbstractAgent, AbstractPlant, AbstractAnimal
export fully_grown, fully_grown!, countdown, countdown!, incr_countdown!, reset!
export energy, energy!, incr_energy!, Δenergy, reproduction_prob, food_prob
export agent_step!, eat!, eats, find_food, reproduce!

abstract type AbstractAgent end
abstract type AbstractPlant <: AbstractAgent end
abstract type AbstractAnimal <: AbstractAgent end

fully_grown(a::AbstractPlant) = a.fully_grown
fully_grown!(a::AbstractPlant, b::Bool) = a.fully_grown = b
countdown(a::AbstractPlant) = a.countdown
countdown!(a::AbstractPlant, c::Int) = a.countdown = c
incr_countdown!(a::AbstractPlant, Δc::Int) = countdown!(a, countdown(a)+Δc)
reset!(a::AbstractPlant) = a.countdown = a.regrowth_time

energy(a::AbstractAnimal) = a.energy
energy!(a::AbstractAnimal, e) = a.energy = e
incr_energy!(a::AbstractAnimal, Δe) = energy!(a, energy(a)+Δe)
Δenergy(a::AbstractAnimal) = a.Δenergy
reproduction_prob(a::AbstractAnimal) = a.reproduction_prob
food_prob(a::AbstractAnimal) = a.food_prob

mutable struct Grass <: AbstractPlant
    fully_grown::Bool
    regrowth_time::Int
    countdown::Int
end
Grass(t) = Grass(false, t, rand(1:t))
Grass() = Grass(2)
function Base.show(io::IO,g::Grass)
    p = if g.fully_grown
        100
    else
        min(100-(g.countdown/g.regrowth_time*100),99)
    end
    print(io,"🌿 $(round(Int,p))% grown")
end

mutable struct Sheep{T<:Real} <: AbstractAnimal
    energy::T
    Δenergy::T
    reproduction_prob::T
    food_prob::T
end
Base.show(io::IO,s::Sheep) = print(io,"🐑 E=$(energy(s)) ΔE=$(Δenergy(s)) pr=$(reproduction_prob(s)) pf=$(food_prob(s))")

mutable struct Wolf{T<:Real} <: AbstractAnimal
    energy::T
    Δenergy::T
    reproduction_prob::T
    food_prob::T
end
Base.show(io::IO,w::Wolf) = print(io,"🐺 E=$(energy(w)) ΔE=$(Δenergy(w)) pr=$(reproduction_prob(w)) pf=$(food_prob(w))")

struct World{T<:AbstractAgent}
    agents::Vector{T}
end
function Base.show(io::IO, w::World)
    println(io, typeof(w))
    map(a->println(io,"  $a"),w.agents)
end

function agent_step!(a::AbstractPlant, w::World)
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

function agent_step!(a::AbstractAnimal, w::World)
    incr_energy!(a,-1)
    dinner = find_food(a,w)
    eat!(a, dinner, w)
    if energy(a) < 0
        kill_agent!(a,w)
        return
    end
    if rand() <= reproduction_prob(a)
        reproduce!(a,w)
    end
    return a
end

function find_food(a::AbstractAnimal, w::World)
    if rand() <= food_prob(a)
        as = filter(x->eats(a,x), w.agents)
        isempty(as) ? nothing : sample(as)
    end
end

eats(::Sheep,::Grass) = true
eats(::Wolf,::Sheep) = true
eats(::AbstractAgent,::AbstractAgent) = false

function eat!(wolf::Wolf, sheep::Sheep, w::World)
    kill_agent!(sheep,w)
    incr_energy!(wolf, Δenergy(wolf))
end
function eat!(sheep::Sheep, grass::Grass, w::World)
    if fully_grown(grass)
        fully_grown!(grass, false)
        incr_energy!(sheep, Δenergy(sheep))
    end
end
eat!(::AbstractAnimal,::Nothing,::World) = nothing

function reproduce!(a::AbstractAnimal, w::World)
    energy!(a, energy(a)/2)
    push!(w.agents, deepcopy(a))
end

kill_agent!(a::AbstractAnimal, w::World) = deleteat!(w.agents, findall(x->x==a, w.agents))

end # module
