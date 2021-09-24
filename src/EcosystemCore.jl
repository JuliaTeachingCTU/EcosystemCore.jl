module EcosystemCore

using StatsBase

export World
export Species, PlantSpecies, AnimalSpecies, Grass, Sheep, Wolf
export Sex, Female, Male
export Agent, Plant, Animal
export agent_step!, eat!, eats, find_food, reproduce!, simulate!, world_step!
export energy, energy!, incr_energy!, Δenergy, reproduction_prob, food_prob

abstract type Species end
abstract type Agent{S<:Species} end

abstract type PlantSpecies <: Species end
abstract type Grass <: PlantSpecies end

abstract type AnimalSpecies <: Species end
abstract type Sheep <: AnimalSpecies end
abstract type Wolf <: AnimalSpecies end

abstract type Sex end
abstract type Male <: Sex end
abstract type Female <: Sex end


mutable struct World{A<:Agent}
    agents::Dict{Int,A}
    max_id::Int
end
function World(agents::Vector{<:Agent})
    World(Dict(id(a)=>a for a in agents), maximum(id.(agents)))
end

include("plant.jl")
include("animal.jl")

# accessors for plants and animals

id(a::Agent) = a.id

Base.size(a::Plant) = a.size
max_size(a::Plant) = a.max_size
grow!(a::Plant) = a.size += 1

energy(a::Animal) = a.energy
Δenergy(a::Animal) = a.Δenergy
reproduction_prob(a::Animal) = a.reproduction_prob
food_prob(a::Animal) = a.food_prob
energy!(a::Animal, e) = a.energy = e
incr_energy!(a::Animal, Δe) = energy!(a, energy(a)+Δe)

function world_step!(world)
    for id in deepcopy(keys(world.agents))
        !haskey(world.agents,id) && continue
        a = world.agents[id]
        agent_step!(a,world)
    end
end

function simulate!(world::World, iters::Int; callbacks=[])
    for i in 1:iters
        world_step!(world)
        for cb in callbacks
            cb(world)
        end
    end
end

function Base.show(io::IO, w::World)
    println(io, typeof(w))
    for (_,a) in w.agents
        println(io,"  $a")
    end
end

end # module
