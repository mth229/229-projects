FROM "julia:alpine"

USER root

RUN apk add git

# copy files


# Add packages and precompile -- FAILS on Conda, PyCall, IJulia, SymPy....
RUN julia -e 'import Pkg; Pkg.update()'
RUN julia -e 'import Pkg; Pkg.add("Pluto"); using Pluto'
EXPOSE 1234

COPY alpine-pluto-notebook.jl /root/.julia/pluto_notebooks/pluto-notebook.jl

#RUN julia -e 'import Pkg; Pkg.add("ForwardDiff"); using ForwardDiff'
#RUN julia -e 'import Pkg; Pkg.add("SpecialFunctions"); using SpecialFunctions'
#RUN julia -e 'import Pkg; Pkg.add("QuadGK"); using QuadGK'
#RUN julia -e 'import Pkg; Pkg.add("PlotlyLight"); using PlotlyLight'



CMD [ "julia", "-e", "import Pluto; Pluto.run(host=\"0.0.0.0\",port=1234,launch_browser=false, require_secret_for_open_links=false, require_secret_for_access=false, notebook=\"/root/.julia/pluto_notebooks/pluto-notebook.jl\")" ]
