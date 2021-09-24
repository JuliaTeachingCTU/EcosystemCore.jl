mutable struct Grass <: Plant
    id::Int
    size::Int
    max_size::Int
end

Base.size(a::Plant) = a.size
max_size(a::Plant) = a.max_size
grow!(a::Plant) = a.size += 1

function agent_step!(a::Plant, w::World)
    if size(a) != max_size(a)
        grow!(a)
    end
end

kill_agent!(a::Plant, w::World) = a.size = 0
