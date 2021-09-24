using EcosystemCore
using Test

@testset "EcosystemCore" begin
    grass1 = Grass(1,false,2,2)
    grass2 = Grass(2,false,2,2)
    sheep  = Sheep(3,2.0,1.0,0.0,0.0)
    wolf   = Wolf(4,10.0,5.0,0.0,0.0)
    world  = World([grass1,grass2,sheep,wolf])

    # check growth
    agent_step!(grass1,world)
    @test fully_grown(grass1) == false
    agent_step!(grass1,world)
    @test fully_grown(grass1) == false
    agent_step!(grass1,world)
    @test fully_grown(grass1) == true

    # check energy reduction
    agent_step!(sheep,world)
    @test energy(sheep) == 1.0
    agent_step!(wolf,world)
    @test energy(wolf) == 9.0

    # set repr prop to 1.0 and let the sheep reproduce
    sheep = Sheep(1,2.0,1.0,1.0,1.0)
    world = World([sheep])
    agent_step!(sheep,world)
    @test length(world.agents) == 2
    @test energy(sheep) == 0.5

    # check wolf eating sheep
    sheep = Sheep(1,2.0,1.0,0.0,1.0)
    wolf  = Wolf(2,10.0,5.0,0.0,1.0)
    world = World([sheep,wolf])
    agent_step!(wolf, world)
    @test energy(wolf) == 14.0
    @test length(world.agents) == 1


    ss = [Sheep(1,5.0,2.0,1.0,1.0),Sheep(2,5.0,2.0,1.0,1.0)]
    world = World(ss)
    simulate!(world, 1)
    @test length(world.agents) == 4
    simulate!(world, 1)
    @test length(world.agents) == 8
    simulate!(world, 1)
    @test length(world.agents) == 0

end
