using EcosystemCore
using Test

EcosystemCore.mates(a::Animal{S},b::Animal{S}) where S<:Species = true
EcosystemCore.mates(a::Agent, b::Agent) = false

@testset "EcosystemCore" begin
    g = Grass(1,10)
    @test_throws ErrorException World([g,g])

    g = Grass(1,1,1)
    s = Animal{Sheep,Male}(2,1,1,1,1)
    w = Animal{Wolf,Female}(3,1,1,1,1)
    @test repr(g) == "🌿  #1 100% grown"
    @test repr(s) == "🐑♂ #2 E=1.0 ΔE=1.0 pr=1.0 pf=1.0"
    @test repr(w) == "🐺♀ #3 E=1.0 ΔE=1.0 pr=1.0 pf=1.0"
    @test_nowarn repr(World([g,s,w]))

    grass1 = Grass(1,1,2)
    grass2 = Grass(2,2,2)
    sheep  = Sheep(3,2.0,1.0,0.0,0.0)
    wolf   = Wolf(4,10.0,5.0,0.0,0.0)
    world  = World([grass1,grass2,sheep,wolf])

    # check growth
    @test size(grass1) == 1
    agent_step!(grass1,world)
    @test size(grass1) == 2
    agent_step!(grass1,world)
    @test size(grass1) == 2

    # check energy reduction
    agent_step!(sheep,world)
    @test energy(sheep) == 1.0
    agent_step!(wolf,world)
    @test energy(wolf) == 9.0

    # set repr prop to 1.0 and let the sheep reproduce
    sheep1 = Sheep(1,2.0,1.0,1.0,1.0,Male)
    sheep2 = Sheep(2,2.0,1.0,1.0,1.0,Female)
    world = World([sheep1,sheep2])
    agent_step!(sheep1,world)
    @test length(world.agents) == 3
    @test energy(sheep1) == 0.5

    # check wolf eating sheep
    sheep = Sheep(1,2.0,1.0,0.0,1.0)
    wolf  = Wolf(2,10.0,5.0,0.0,1.0)
    world = World([sheep,wolf])
    agent_step!(wolf, world)
    @test energy(wolf) == 19.0
    @test length(world.agents) == 1

    ss = [Sheep(1,5.0,2.0,1.0,1.0),Sheep(2,5.0,2.0,1.0,1.0)]
    world = World(ss)
    world_step!(world)
    @test length(world.agents) == 4
    world_step!(world)
    @test length(world.agents) == 8
    world_step!(world)
    @test length(world.agents) == 0

end
