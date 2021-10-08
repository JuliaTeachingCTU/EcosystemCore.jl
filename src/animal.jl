mutable struct Animal{A<:AnimalSpecies,S<:Sex} <: Agent{A}
    id::Int
    energy::Float64
    Δenergy::Float64
    reprprob::Float64
    foodprob::Float64
end

energy(a::Animal) = a.energy
Δenergy(a::Animal) = a.Δenergy
reprprob(a::Animal) = a.reprprob
foodprob(a::Animal) = a.foodprob
energy!(a::Animal, e) = a.energy = e
incr_energy!(a::Animal, Δe) = energy!(a, energy(a)+Δe)

function (A::Type{<:AnimalSpecies})(id::Int, E, ΔE, pr, pf, S=rand(Bool) ? Female : Male)
    Animal{A,S}(id,E,ΔE,pr,pf)
end

function agent_step!(a::Animal, w::World)
    incr_energy!(a,-1)
    if rand() <= foodprob(a)
        dinner = find_food(a,w)
        eat!(a, dinner, w)
    end
    if energy(a) <= 0
        kill_agent!(a,w)
        return
    end
    if rand() <= reprprob(a)
        reproduce!(a,w)
    end
    return a
end

function find_rand(f, w::World)
    xs = filter(f, w.agents |> values |> collect)
    isempty(xs) ? nothing : sample(xs)
end

find_food(a::Animal, w::World) = find_rand(x->eats(a,x),w)

eats(::Animal{Sheep},p::Plant{Grass}) = size(p)>0
eats(::Animal{Wolf},::Animal{Sheep}) = true
eats(::Agent,::Agent) = false

function eat!(a::Animal{Wolf}, b::Animal{Sheep}, w::World)
    incr_energy!(a, energy(b)*Δenergy(a))
    kill_agent!(b,w)
end
function eat!(a::Animal{Sheep}, b::Plant{Grass}, w::World)
    incr_energy!(a, size(b)*Δenergy(a))
    b.size = 0
end
eat!(::Animal,::Nothing,::World) = nothing

function reproduce!(a::A, w::World) where A<:Animal
    b = find_mate(a,w)
    if !isnothing(b)
        energy!(a, energy(a)/2)
        a_vals = [getproperty(a,n) for n in fieldnames(A) if n!=:id]
        new_id = w.max_id + 1
        â = A(new_id, a_vals...)
        w.agents[id(â)] = â
        w.max_id = new_id
    end
end

find_mate(a::Animal, w::World) = find_rand(x->mates(a,x),w)

function mates(a,b)
    error("""You have to specify the mating behaviour of your agents by overloading `EcosystemCore.mates` e.g. like this:

        EcosystemCore.mates(a::Animal{S,Female}, b::Animal{S,Male}) where S<:Species = true
        EcosystemCore.mates(a::Animal{S,Male}, b::Animal{S,Female}) where S<:Species = true
        EcosystemCore.mates(a::Agent, b::Agent) = false
    """)
end

kill_agent!(a::Animal, w::World) = delete!(w.agents, id(a))

Base.show(io::IO, ::Type{Sheep}) = print(io,"🐑")
Base.show(io::IO, ::Type{Wolf}) = print(io,"🐺")
Base.show(io::IO, ::Type{Male}) = print(io,"♂")
Base.show(io::IO, ::Type{Female}) = print(io,"♀")
function Base.show(io::IO, a::Animal{A,S}) where {A,S}
    e = energy(a)
    d = Δenergy(a)
    pr = reprprob(a)
    pf = foodprob(a)
    print(io,"$A$S #$(id(a)) E=$e ΔE=$d pr=$pr pf=$pf")
end
