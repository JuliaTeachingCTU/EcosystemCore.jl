module EcosystemCore

using StatsBase

export World
export Species, PlantSpecies, AnimalSpecies, Grass, Sheep, Wolf
export Sex, Female, Male
export Agent, Plant, Animal
export agent_step!, eat!, eats, find_food, reproduce!, world_step!
export energy, energy!, incr_energy!, Δenergy, reprprob, foodprob

abstract type Species end
abstract type Agent{S<:Species} end

abstract type PlantSpecies <: Species end
abstract type AnimalSpecies <: Species end

abstract type Sex end
abstract type Male <: Sex end
abstract type Female <: Sex end

id(a::Agent) = a.id

include("world.jl")
include("plant.jl")
include("animal.jl")

end # module
