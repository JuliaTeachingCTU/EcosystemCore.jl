mutable struct Plant{P<:PlantSpecies} <: Agent{P}
    id::Int
    size::Int
    max_size::Int
end

# constructor for all Plant{<:PlantSpecies} callable as PlantSpecies(...)
(A::Type{<:PlantSpecies})(id, s, m) = Plant{A}(id,s,m)
(A::Type{<:PlantSpecies})(id, m) = (A::Type{<:PlantSpecies})(id,rand(1:m),m)

# default specific for Grass
Grass(id; max_size=10) = Grass(id, rand(1:max_size), max_size)

find_agent(::Type{P}, w::World) where P<:PlantSpecies = find_agent(Plant{P}, w)

function Base.show(io::IO, p::Plant{P}) where P
    x = p.size/p.max_size * 100
    print(io,"$P  #$(p.id) $(round(Int,x))% grown")
end

Base.show(io::IO, ::Type{Grass}) = print(io,"🌿")

function agent_step!(p::Plant, ::World)
    if p.size < p.max_size
        p.size += 1
    end
end
