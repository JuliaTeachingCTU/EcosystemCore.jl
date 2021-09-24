mutable struct Animal{A<:AnimalSpecies,S<:Sex,T<:Real} <: Agent{A}
    id::Int
    energy::T
    Δenergy::T
    reproduction_prob::T
    food_prob::T
end

# constructor for all Animal{<:AnimalSpecies} callable as AnimalSpecies(...)
function (A::Type{<:AnimalSpecies})(id::Int,E::T,ΔE::T,pr::T,pf::T,S::Type{<:Sex}) where T<:Real
    Animal{A,S,T}(id,E,ΔE,pr,pf)
end
function (A::Type{<:AnimalSpecies})(id::Int,E::T,ΔE::T,pr::T,pf::T) where T<:Real
    A(id,E,ΔE,pr,pf,rand(Bool) ? Female : Male)
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

Base.show(io::IO, ::Type{Sheep}) = print(io,"🐑")
Base.show(io::IO, ::Type{Wolf}) = print(io,"🐺")
Base.show(io::IO, ::Type{Male}) = print(io,"♂")
Base.show(io::IO, ::Type{Female}) = print(io,"♀")
function Base.show(io::IO, a::Animal{A,S}) where {A,S}
    e = a.energy
    d = a.Δenergy
    pr = a.reproduction_prob
    pf = a.food_prob
    print(io,"$A$S #$(id(a)) E=$e ΔE=$d pr=$pr pf=$pf")
end
