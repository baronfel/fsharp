#! /usr/bin/env sh

dotnet tool restore
dotnet fsdocs build --input docs  --projects ../../src/fsharp/FSharp.Compiler.Service/FSharp.Compiler.Service.fsproj --linenumbers true --eval true --saveimages all