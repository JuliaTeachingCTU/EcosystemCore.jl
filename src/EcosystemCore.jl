module EcosystemCore

export World, Agent, Animal, Plant, Grass, Sheep, Wolf
export agent_step!, eat!, eats, find_food, reproduce!, world_step!
export energy, energy!, incr_energy!, Δenergy, reproduction_prob, food_prob

using StatsBase

abstract type Agent end
abstract type Animal <: Agent end
abstract type Plant <: Agent end

id(a::Agent) = a.id  # every agent has an ID so we can just define id for Agent here

include("world.jl")
include("plant.jl")
include("animal.jl")

end
