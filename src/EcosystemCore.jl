module EcosystemCore

using StatsBase

export World
export Species, PlantSpecies, AnimalSpecies, Grass, Sheep, Wolf
export Sex, Female, Male
export Agent, Plant, Animal
export agent_step!, eat!, eats, find_food, reproduce!, world_step!

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

include("world.jl")
include("plant.jl")
include("animal.jl")

kill_agent!(a::Agent, w::World) = delete!(getfield(w.agents, tosym(typeof(a))), a.id)

function find_agent(::Type{A}, w::World) where A<:Agent
    dict = getfield(w.agents, tosym(A))
    as = dict |> values |> collect
    isempty(as) ? nothing : sample(as)
end

# for accessing NamedTuple in World
tosym(::Type{<:Animal{Sheep,Male}}) = Symbol("sheep_male")
tosym(::Type{<:Animal{Sheep,Female}}) = Symbol("sheep_female")
tosym(::Type{<:Plant{Grass}}) = Symbol("grass")
tosym(::Type{<:Animal{Wolf,Female}}) = Symbol("wolf_female")
tosym(::Type{<:Animal{Wolf,Male}}) = Symbol("wolf_male")
tosym(::T) where T<:Animal = tosym(T)

end # module
