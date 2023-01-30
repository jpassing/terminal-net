CONFIGURATION = Release

# The tag should be increased whenever one of the dependencies is changed
TAG = 1
TERMINAL_VERSION = 1.16.0
NUGET = $(MAKEDIR)\dep\nuget\nuget.exe
TERMINAL_VCXPROJ=$(MAKEDIR)\src\cascadia\PublicTerminalCore\PublicTerminalCore.vcxproj

default: package

restore:
	@echo "========================================================"
	@echo "=== Restoring terminal                               ==="
	@echo "========================================================"
	
	git submodule update --init --recursive

	$(NUGET) restore $(MAKEDIR)\OpenConsole.sln
	$(NUGET) restore $(MAKEDIR)\dep\nuget\packages.config

$(MAKEDIR)\bin\Win32\$(CONFIGURATION)\PublicTerminalCore.dll: restore
	@echo "========================================================"
	@echo "=== Building terminal (x86)                          ==="
	@echo "========================================================"
	
	
	msbuild \
		/t:Build \
		"/p:Configuration=$(CONFIGURATION);SolutionDir=$(MAKEDIR)\,Platform=Win32" \
		$(TERMINAL_VCXPROJ)


$(MAKEDIR)\bin\x64\$(CONFIGURATION)\PublicTerminalCore.dll: restore
	@echo "========================================================"
	@echo "=== Building terminal (x64)                          ==="
	@echo "========================================================"
	
	msbuild \
		/t:Build \
		"/p:Configuration=$(CONFIGURATION);SolutionDir=$(MAKEDIR)\,Platform=x64" \
		$(TERMINAL_VCXPROJ)


$(MAKEDIR)\terminal.$(TERMINAL_VERSION).nupkg: \
		$(MAKEDIR)\bin\Win32\$(CONFIGURATION)\PublicTerminalCore.dll \
		$(MAKEDIR)\bin\x64\$(CONFIGURATION)\PublicTerminalCore.dll
	@echo "========================================================"
	@echo "=== Building terminal nuget package                   ==="
	@echo "========================================================"
	$(NUGET) pack -OutputDirectory $(MAKEDIR)\ <<terminal.nuspec
<?xml version="1.0"?>
<package>
  <metadata>
    <id>terminal</id>
    <version>$(TERMINAL_VERSION)</version>
    <authors>https://github.com/microsoft/terminal</authors>
    <owners>https://github.com/microsoft/terminal</owners>
    <requireLicenseAcceptance>false</requireLicenseAcceptance>
    <description>Windows Terminal</description>
	<tags>Native, native</tags>
  </metadata>
  <files>
	<!-- pretend the library is platform-neutral -->
    <file src="$(MAKEDIR)\bin\Win32\$(CONFIGURATION)\PublicTerminalCore.dll" target="runtimes\win10-x86\native" />
    <file src="$(MAKEDIR)\bin\Win32\$(CONFIGURATION)\PublicTerminalCore.pdb" target="runtimes\win10-x86\native" />
    <file src="$(MAKEDIR)\bin\x64\$(CONFIGURATION)\PublicTerminalCore.dll" target="runtimes\win10-x86\native" />
    <file src="$(MAKEDIR)\bin\x64\$(CONFIGURATION)\PublicTerminalCore.pdb" target="runtimes\win10-x86\native" />
    <file src="terminal.targets" target="build" />
  </files>
</package>
<<NOKEEP

#------------------------------------------------------------------------------
# Main targets
#------------------------------------------------------------------------------

package: $(MAKEDIR)\terminal.$(TERMINAL_VERSION).nupkg
    copy /Y $(MAKEDIR)\terminal.$(TERMINAL_VERSION).nupkg $(MAKEDIR)\terminal.nupkg

clean:
    msbuild /t:Clean "$(TERMINAL_VCXPROJ)"
    -rd /S /Q $(MAKEDIR)\bin
    -del $(MAKEDIR)\terminal.nupkg
    
distclean: clean