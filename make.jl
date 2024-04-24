# for `lite` we use BinderPlots
using JSON

fs = filter(endswith("ipynb"), readdir("."))

for f ∈ fs
    nb = open(JSON.parse, f, "r")

    for cell in nb["cells"]
        if cell["cell_type"] == "code" && !isempty(cell["source"])
            !isempty(cell["outputs"]) && continue
            cmds = cell["source"]
            cmds = replace.(cmds, "using Plots\n" => "using BinderPlots\n")
            cmds = replace.(cmds, "plotly()" => "")
            cell["source"] = cmds
        end
    end


    open(f, "w") do io
        JSON.print(io, nb)
    end
end
