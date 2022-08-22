mutable struct Animal{A<:AnimalSpecies,S<:Sex} <: Agent{A}
    id::Int
    energy::Float64
    Δenergy::Float64
    reprprob::Float64
    foodprob::Float64
end

tosym(::Type{<:Animal{A,S}}) where {A,S} = Symbol("animal_$A$S")
tosym(::Type{<:Plant{P}}) where P = Symbol("plant_$P")
#tosym(::Type{<:Animal{Sheep,Male}}) where {A,S} = Symbol("sheep_male")
#tosym(::Type{<:Animal{Sheep,Female}}) where {A,S} = Symbol("sheep_female")
#tosym(::Type{<:Plant{Grass}}) where {A,S} = Symbol("grass")
tosym(::T) where T<:Animal = tosym(T)

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

#function find_rand(f, w::World)
#    xs = map(w.agents) do dict
#        x = filter(f, dict |> values |> collect)
#        isempty(x) ? nothing : sample(x)
#    end
#    ys = [x for x in xs if !isnothing(x)]
#    isempty(ys) ? nothing : sample(ys)
#end

#find_food(a::Animal, w::World) = find_rand(x->eats(a,x),w)

#function find_rand(f)
#    
#end

function find_food(::Animal{<:Wolf}, w::World)
    as = if rand() < 0.5
        w.agents.animal_🐑♀
    else
        w.agents.animal_🐑♂
    end |> values |> collect
    isempty(as) ? nothing : sample(as)
end

function find_food(::Animal{<:Sheep}, w::World)
    as = filter(p -> size(p)>0, w.agents.plant_🌿 |> values |> collect)
    isempty(as) ? nothing : sample(as)
end

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
        setid(w, id(â), â)
        #w.agents[id(â)] = â
        w.max_id = new_id
    end
end

#find_mate(a::Animal, w::World) = find_rand(x->mates(a,x),w)
function find_mate(::Animal{<:Sheep,<:Female}, w::World)
    as = w.agents.animal_🐑♂ |> values |> collect
    isempty(as) ? nothing : sample(as)
end
function find_mate(::Animal{<:Sheep,<:Male}, w::World)
    as = w.agents.animal_🐑♀ |> values |> collect
    isempty(as) ? nothing : sample(as)
end
function find_mate(::Animal{<:Wolf,<:Male}, w::World)
    as = w.agents.animal_🐺♀ |> values |> collect
    isempty(as) ? nothing : sample(as)
end
function find_mate(::Animal{<:Wolf,<:Female}, w::World)
    as = w.agents.animal_🐺♂ |> values |> collect
    isempty(as) ? nothing : sample(as)
end


#function find_mate(::Animal{A,S}, w::World) where {A,S}
#    T = oppositesex(S)
#    as = getfield(w.agents, Symbol("animal_$A$T")) |> values |> collect
#    isempty(as) ? nothing : sample(as)
#end

function mates(a,b)
    error("""You have to specify the mating behaviour of your agents by overloading `EcosystemCore.mates` e.g. like this:

        EcosystemCore.mates(a::Animal{S,Female}, b::Animal{S,Male}) where S<:Species = true
        EcosystemCore.mates(a::Animal{S,Male}, b::Animal{S,Female}) where S<:Species = true
        EcosystemCore.mates(a::Agent, b::Agent) = false
    """)
end

function kill_agent!(a::Animal, w::World)
    _, dict = getid(w, id(a))
    delete!(dict, id(a))
end

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
