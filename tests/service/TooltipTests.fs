#if INTERACTIVE
#I __SOURCE_DIRECTORY__
#r "../../Debug/fcs/net45/FSharp.Compiler.Service.dll" // note, run 'build fcs debug' to generate this, this DLL has a public API so can be used from F# Interactive
#r "../../packages/NUnit.3.5.0/lib/net45/nunit.framework.dll"
#load "FsUnit.fs"
#load "Common.fs"
#else
module FSharp.Compiler.Service.Tests.TooltipTests
#endif

open Microsoft.FSharp.Compiler
open Microsoft.FSharp.Compiler.SourceCodeServices
open Microsoft.FSharp.Compiler.QuickParse

open NUnit.Framework
open FsUnit
open System
open System.IO

let source = """
open System

let p = "foo".LastIndexOf 'o'
"""

let sourceLines = source.Split '\n'

let checker = FSharpChecker.Create()

let parseWithTypeInfo (file, input) = 
    let checkOptions, _errors = checker.GetProjectOptionsFromScript(file, input) |> Async.RunSynchronously
    let parsingOptions, _errors = checker.GetParsingOptionsFromProjectOptions(checkOptions)
    let untypedRes = checker.ParseFile(file, input, parsingOptions) |> Async.RunSynchronously
    
    match checker.CheckFileInProject(untypedRes, file, 0, input, checkOptions) |> Async.RunSynchronously with 
    | FSharpCheckFileAnswer.Succeeded(res) -> untypedRes, res
    | res -> failwithf "Parsing did not finish... (%A)" res

let untyped, parsed = parseWithTypeInfo ("/home/user/Test.fsx", source)

[<Test>]
let ``Can get XML doc return values`` () =
    let tip = 
        parsed.GetToolTipText(4, 25, sourceLines.[3], ["LastIndexOf"], FSharpTokenTag.Identifier)
        |> Async.RunSynchronously

    printfn "%A" tip