FROM julia:1.6.1


RUN mkdir -p ${HOME}/.julia/config && \
    echo '\
# set environment variables\n\
ENV["PYTHON"]=Sys.which("python3")\n\
ENV["JUPYTER"]=Sys.which("jupyter")\n\
\n\
import Pkg\n\
let\n\
    pkgs = ["Revise","OhMyREPL"]\n\
    for pkg in pkgs\n\
        if Base.find_package(pkg) === nothing\n\
            Pkg.add(pkg)\n\
        end\n\
    end\n\
end\n\
using OhMyREPL \n\
enable_autocomplete_brackets(false) \n\
using Revise \n\
\n\
' >> ${HOME}/.julia/config/startup.jl && cat ${HOME}/.julia/config/startup.jl

# Install Julia Packages
RUN julia -e 'using Pkg; \
Pkg.add([\
    PackageSpec(name="PackageCompiler", version="1.2.5"), \
    PackageSpec(name="OhMyREPL", version="0.5.10"), \
    PackageSpec(name="Plots", version="1.11.0"), \
]); \
Pkg.pin(["PackageCompiler", "OhMyREPL",  "Plots"]); \
Pkg.add(["Plotly", "PlotlyJS"]); \
'
# suppress warning for related to GR backend
ENV GKSwstype=100



# generate precompile_statements_file
RUN xvfb-run julia \
             --trace-compile=traced_runtests.jl \
             -e '\
                ENV["CI"]="true"; \
                using Plots; \
                try include(joinpath(pkgdir(Plots), "test", "runtests.jl")) catch end \
                '

# update sysimage
RUN julia -e 'using PackageCompiler; \
              create_sysimage(\
                  [:Plots, :Revise, :OhMyREPL], \
                  precompile_statements_file=["traced_runtests.jl", "/tmp/traced_nb.jl"], \
                  cpu_target = PackageCompiler.default_app_cpu_target(), \
                  replace_default=true, \
              )'


WORKDIR /work
ENV JULIA_PROJECT=/work
COPY ./requirements.txt /work/requirements.txt
RUN pip install -r requirements.txt
COPY ./Project.toml /work/Project.toml

# Initialize Julia package using /work/Project.toml
RUN rm -f Manifest.toml && julia -e 'using Pkg; \
Pkg.instantiate(); \
Pkg.precompile(); \
' && \
# Check Julia version \
# For Jupyter Notebook
EXPOSE 8888

CMD ["julia"]