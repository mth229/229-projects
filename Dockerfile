FROM julia:1.6.1

RUN apt-get update && \
    apt-get install -y \
    build-essential \
    cmake \
    python3 \
    python3-dev \
    python3-distutils \
    curl \
    ca-certificates \
    git \
    libgconf-2-4 \
    xvfb \
    zip \
    r-base \
    libxt6 libxrender1 libxext6 libgl1-mesa-glx libqt5widgets5 # GR \
    && \
    apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* # clean up

# Install packages for Jupyter Notebook/JupyterLab
RUN curl -kL https://bootstrap.pypa.io/get-pip.py | python3 && \
    pip3 install \
    jupyter \
    jupyterlab==3.* \
    jupytext \
    ipywidgets \
    jupyter-contrib-nbextensions \
    jupyter-nbextensions-configurator \
    jupyter-server-proxy \
    git+https://github.com/IllumiDesk/jupyter-pluto-proxy.git \
    jupyterlab_code_formatter autopep8 black

# Install/enable extension for Jupyter Notebook users
RUN pip3 install jupyter-resource-usage && \
    jupyter contrib nbextension install --user && \
    jupyter nbextensions_configurator enable --user && \
    # enable extensions what you want
    jupyter nbextension enable select_keymap/main && \
    jupyter nbextension enable highlight_selected_word/main && \
    jupyter nbextension enable toggle_all_line_numbers/main && \
    jupyter nbextension enable equation-numbering/main && \
    jupyter nbextension enable execute_time/ExecuteTime && \
    echo Done

# Install/enable extension for JupyterLab users
RUN jupyter labextension install jupyterlab-topbar-extension && \
    jupyter labextension install jupyterlab-system-monitor && \
    jupyter labextension install @hokyjack/jupyterlab-monokai-plus --no-build && \
    jupyter labextension install @jupyterlab/server-proxy --no-build && \
    jupyter lab build -y && \
    jupyter lab clean -y && \
    npm cache clean --force && \
    rm -rf ~/.cache/yarn && \
    rm -rf ~/.node-gyp && \
    echo Done


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
'
# suppress warning for related to GR backend
ENV GKSwstype=100



# Install kernel so that `JULIA_PROJECT` should be $JULIA_PROJECT
RUN jupyter nbextension uninstall --user webio/main && \
    jupyter nbextension uninstall --user webio-jupyter-notebook && \
    julia -e '\
              using Pkg; \
              Pkg.add(PackageSpec(name="IJulia",version="1.23.2")); \
	      Pkg.add(PackageSpec(name="WebIO", version="0.8.15")); \
              Pkg.pin(["IJulia","WebIO"]); \
              using IJulia, WebIO; \
              WebIO.install_jupyter_nbextension(); \
              envhome="/work"; \
              installkernel("Julia", "--project=$envhome", "--trace-compile=/tmp/traced_nb.jl");\
              ' && \
    echo "Done"

COPY ./.statements /tmp
# generate traced_nb.jl
RUN jupytext --to ipynb --execute /tmp/nb.jl
RUN julia -e '\
    using IJulia; installkernel("Julia", "--project=/work"); \
'  

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