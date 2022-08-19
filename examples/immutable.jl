using Statistics
using Zygote

push(v::Vector, x) = cat([x], v, dims=1)

remove(v::Vector, i::Int) = cat(v[1:i-1], v[i+1:end], dims=1)

#function run(agents, add_p, rem_p, iters)
#    for i in 1:iters
#        if rand() < add_p
#            a = make_agent()
#            agents = push(agents, a)
#        end
#
#        if rand() < rem_p
#            agents = remove(agents, 1)
#        end
#    end
#    agents
#end

#make_agent() = 1
#
#function loss(agents,a,r)
#    map(1:10) do i
#        length(run(agents, a, r, 10))
#    end |> xs -> mean(xs)
#end
#
#
#add_p = 0.5
#rem_p = 0.5
#agents = ones(Int, 100)
#
#Zygote.gradient((a,r) -> loss(agents, a, r), add_p, rem_p)


function run(agents::Real, spawn_prob::Real, death_prob::Real, iters::Int)
    for i in 1:iters
        if rand() < spawn_prob
            agents += 1.0
        end

        if rand() < death_prob
            agents -= 1.0
        end
    end
    agents
end

spawn_prob = 0.5
death_prob = 0.5
agents = 10.0

Zygote.gradient((a,r) -> run(agents, a, r, 10), spawn_prob, death_prob)
