Configuration ?= Release
DotNetVersion = `cat DotnetCLIToolsVersion.txt`
DotNetToolPath = $(CURDIR)/artifacts/toolset/dotnet
DotNetExe = "$(DotNetToolPath)/dotnet"
Verbosity ?= normal
RestoreCommand = $(DotNetExe) restore -v $(Verbosity)
BuildCommand = $(DotNetExe) build -v $(Verbosity)
TestCommand = $(DotNetExe) test -v $(Verbosity)
all: proto restore build test

tools:
	$(CURDIR)/scripts/dotnet-install.sh --version $(DotNetVersion) --install-dir "$(DotNetToolPath)"

proto: tools
	$(DotNetExe) build-server shutdown
	$(RestoreCommand) src/buildtools/buildtools.proj
	$(RestoreCommand) src/fsharp/FSharp.Build/FSharp.Build.fsproj
	$(RestoreCommand) src/fsharp/fsc/fsc.fsproj
	$(BuildCommand) src/buildtools/buildtools.proj -c Proto
	$(BuildCommand) src/fsharp/FSharp.Build/FSharp.Build.fsproj -c Proto
	$(BuildCommand) src/fsharp/fsc/fsc.fsproj -c Proto 

restore:
	$(RestoreCommand) src/fsharp/FSharp.Core/FSharp.Core.fsproj
	$(RestoreCommand) src/fsharp/FSharp.Build/FSharp.Build.fsproj
	$(RestoreCommand) src/fsharp/FSharp.Compiler.Private/FSharp.Compiler.Private.fsproj
	$(RestoreCommand) src/fsharp/fsc/fsc.fsproj
	$(RestoreCommand) src/fsharp/FSharp.Compiler.Interactive.Settings/FSharp.Compiler.Interactive.Settings.fsproj
	$(RestoreCommand) src/fsharp/fsi/fsi.fsproj
	$(RestoreCommand) tests/FSharp.Core.UnitTests/FSharp.Core.UnitTests.fsproj
	$(RestoreCommand) tests/FSharp.Build.UnitTests/FSharp.Build.UnitTests.fsproj

build: proto restore
	$(DotNetExe) build-server shutdown
	$(BuildCommand) -c $(Configuration) src/fsharp/FSharp.Core/FSharp.Core.fsproj
	$(BuildCommand) -c $(Configuration) src/fsharp/FSharp.Build/FSharp.Build.fsproj
	$(BuildCommand) -c $(Configuration) src/fsharp/FSharp.Compiler.Private/FSharp.Compiler.Private.fsproj
	$(BuildCommand) -c $(Configuration) src/fsharp/fsc/fsc.fsproj
	$(BuildCommand) -c $(Configuration) src/fsharp/FSharp.Compiler.Interactive.Settings/FSharp.Compiler.Interactive.Settings.fsproj
	$(BuildCommand) -c $(Configuration) src/fsharp/fsi/fsi.fsproj
	$(BuildCommand) -c $(Configuration) tests/FSharp.Core.UnitTests/FSharp.Core.UnitTests.fsproj
	$(BuildCommand) -c $(Configuration) tests/FSharp.Build.UnitTests/FSharp.Build.UnitTests.fsproj

test: build
	$(TestCommand) -c $(Configuration) --no-restore --no-build tests/FSharp.Core.UnitTests/FSharp.Core.UnitTests.fsproj -l "trx;LogFileName=$(CURDIR)/tests/TestResults/FSharp.Core.UnitTests.coreclr.trx"
	$(TestCommand) -c $(Configuration) --no-restore --no-build tests/FSharp.Build.UnitTests/FSharp.Build.UnitTests.fsproj -l "trx;LogFileName=$(CURDIR)/tests/TestResults/FSharp.Build.UnitTests.coreclr.trx"

clean:
	rm -rf $(CURDIR)/artifacts
