mutable struct Plant{P<:PlantSpecies} <: Agent{P}
    id::Int
    fully_grown::Bool
    regrowth_time::Int
    countdown::Int
end

# constructor for all Plant{<:PlantSpecies} callable as PlantSpecies(...)
function (A::Type{<:PlantSpecies})(id, fully_grown, regrowth_time, countdown)
    Plant{A}(id, fully_grown, regrowth_time, countdown)
end
(A::Type{<:PlantSpecies})(id,r) = (A::Type{<:PlantSpecies})(id,false,r,rand(1:r))

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

function Base.show(io::IO, p::Plant{P}) where P
    x = if p.fully_grown
        100
    else
        min(100-(p.countdown/p.regrowth_time*100),99)
    end
    print(io,"$P  #$(id(p)) $(round(Int,x))% grown")
end

Base.show(io::IO, ::Type{Grass}) = print(io,"🌿")
