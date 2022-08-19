 using Zygote

 f(n,μ,σ) = sum(rand(n)*σ .+ μ)

 Zygote.gradient((μ,σ) -> f(100,μ,σ), 1.0, 1.0)
