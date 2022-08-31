using EcosystemCore

s1 = Sheep(1,S=Male)
s2 = Sheep(2,S=Female)
w1 = Wolf(3)

w = World([s1,s2,w1])
display(w)

EcosystemCore.find_agent(Animal{Sheep,Female}, w)
@code_warntype EcosystemCore.find_agent(Animal{Sheep,Female}, w)

EcosystemCore.find_agent(Sheep, w)
@code_warntype EcosystemCore.find_agent(Sheep, w)

@code_warntype EcosystemCore.find_food(w1, w)
EcosystemCore.find_food(w1, w)
