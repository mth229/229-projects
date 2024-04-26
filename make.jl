# run with julia make.jl

fs = filter(endswith(".qmd"), readdir("."))
for f ∈ fs
    @info "processing $f"
    run(`quarto render $f --to ipynb`)
end
