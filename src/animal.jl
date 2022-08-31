mutable struct Animal{A<:AnimalSpecies,S<:Sex} <: Agent{A}
    id::Int
    energy::Float64
    Δenergy::Float64
    reprprob::Float64
    foodprob::Float64
end

# AnimalSpecies constructors
function (A::Type{<:AnimalSpecies})(id::Int,E::T,ΔE::T,pr::T,pf::T,S::Type{<:Sex}) where T
    Animal{A,S}(id,E,ΔE,pr,pf)
end

# get the per species defaults back
randsex() = rand(Bool) ? Female : Male
Sheep(id; E=4.0, ΔE=0.2, pr=0.6, pf=0.6, S=randsex()) = Sheep(id, E, ΔE, pr, pf, S)
Wolf(id; E=10.0, ΔE=8.0, pr=0.1, pf=0.2, S=randsex()) = Wolf(id, E, ΔE, pr, pf, S)

function Base.show(io::IO, a::Animal{A,S}) where {A<:AnimalSpecies,S<:Sex}
    e = a.energy
    d = a.Δenergy
    pr = a.reprprob
    pf = a.foodprob
    print(io, "$A$S #$(a.id) E=$e ΔE=$d pr=$pr pf=$pf")
end

# note that for new species/sexes we will only have to overload `show` on the
# abstract species/sex types like below!
Base.show(io::IO, ::Type{Sheep}) = print(io,"🐑")
Base.show(io::IO, ::Type{Wolf}) = print(io,"🐺")
Base.show(io::IO, ::Type{Male}) = print(io,"♂")
Base.show(io::IO, ::Type{Female}) = print(io,"♀")


function eat!(wolf::Animal{Wolf}, sheep::Animal{Sheep}, w::World)
    wolf.energy += sheep.energy * wolf.Δenergy
    kill_agent!(sheep,w)
end
function eat!(sheep::Animal{Sheep}, grass::Plant{Grass}, w::World)
    sheep.energy += grass.size * sheep.Δenergy
    grass.size = 0
end
eat!(::Animal, ::Nothing, ::World) = nothing


function find_agent(::Type{A}, w::World) where A<:AnimalSpecies
    df = getfield(w.agents, tosym(Animal{A,Female}))
    af = df |> values |> collect

    dm = getfield(w.agents, tosym(Animal{A,Male}))
    am = dm |> values |> collect

    nf = length(af)
    nm = length(am)
    if nf == 0
        # no females -> sample males
        isempty(am) ? nothing : sample(am)
    elseif nm == 0
        # no males -> sample females
        isempty(af) ? nothing : sample(af)
    else
        # both -> sample uniformly from one or the other
        rand() < nf/(nf+nm) ? sample(am) : sample(af)
    end
end

find_food(::Animal{<:Wolf}, w::World) = find_agent(Sheep, w)
find_food(::Animal{<:Sheep}, w::World) = find_agent(Grass, w)

find_mate(::Animal{A,Female}, w::World) where A<:AnimalSpecies = find_agent(Animal{A,Male}, w)
find_mate(::Animal{A,Male}, w::World) where A<:AnimalSpecies = find_agent(Animal{A,Female}, w)

function reproduce!(a::Animal{A,S}, w::World) where {A,S}
    m = find_mate(a,w)
    if !isnothing(m)
        a.energy = a.energy / 2
        vals = [getproperty(a,n) for n in fieldnames(Animal) if n!=:id]
        new_id = w.max_id + 1
        T = typeof(a)
        ŝ = T(new_id, vals...)
        getfield(w.agents, tosym(T))[ŝ.id] = ŝ
        w.max_id = new_id
    end
end


function agent_step!(a::Animal, w::World)
    a.energy -= 1
    if rand() <= a.foodprob
        dinner = find_food(a,w)
        eat!(a, dinner, w)
    end
    if a.energy <= 0
        kill_agent!(a,w)
        return
    end
    if rand() <= a.reprprob
        reproduce!(a,w)
    end
    return a
end
