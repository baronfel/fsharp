#! /usr/bin/env sh


#fsdocs_binary='fsdocs'
#fsdocs_command='build'
fsdocs_binary='/Users/chethusk/oss/FSharp.Formatting/src/FSharp.Formatting.CommandTool/bin/Debug/netcoreapp3.1/fsdocs.dll'
fsdocs_command='watch'
fcs_proj='../../src/fsharp/FSharp.Compiler.Service/FSharp.Compiler.Service.fsproj'

dotnet tool restore
dotnet restore $fcs_proj

dotnet $fsdocs_binary $fsdocs_command --input docs --projects $fcs_proj --linenumbers true --eval true --saveimages all