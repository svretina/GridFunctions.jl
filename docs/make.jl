using GridFunctions
using Documenter

DocMeta.setdocmeta!(GridFunctions, :DocTestSetup, :(using GridFunctions); recursive=true)

makedocs(;
    modules=[GridFunctions],
    authors="Stamatis Vretinaris",
    repo="https://github.com/svretina/GridFunctions.jl/blob/{commit}{path}#{line}",
    sitename="GridFunctions.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://svretina.github.io/GridFunctions.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/svretina/GridFunctions.jl",
    devbranch="master",
)
