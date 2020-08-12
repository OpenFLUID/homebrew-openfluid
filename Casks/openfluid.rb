cask 'openfluid' do

  # description
  version '2.1.10'
  name 'OpenFLUID'
  homepage 'https://www.openfluid-project.org'

  
  # file to download
  if MacOS.version <= :mojave
    url 'https://www.openfluid-project.org/dloadsproxy/final/v2.1.10/openfluid_2.1.10_osx64-mojave.tar.bz2'
    sha256 'b4dafec29ca3ab8be5f51b4bc93504245eca5fbed60a6cf78285bebf9fcde03c'
  else # catalina and higher
    url 'https://www.openfluid-project.org/dloadsproxy/final/v2.1.10/openfluid_2.1.10_osx64-catalina.tar.bz2'
    sha256 '429b9ed6996e7ac1f3cb33f4d5009a21e20185125630a1ff1c4e262cab6863c6'
  end


  # external dependencies
  depends_on formula: 'boost'
  depends_on formula: 'rapidjson'
  depends_on formula: 'gdal'
  depends_on formula: 'geos'
  depends_on formula: 'qt5'
  depends_on formula: 'p7zip'
  depends_on formula: 'gnuplot'
  depends_on formula: 'cmake'


  # system dependencies
  depends_on macos: '>= :yosemite'


  # variables used during installation process
  OFapps = ['OpenFLUID-Builder','OpenFLUID-Devstudio']
  cliwrapper = "#{staged_path}/openfluid-wrapper.sh"


  # preinstall operations
  preflight do
  	
  	# creation of a wrapper for the command line program 
  	# to introduce the OPENFLUID_INSTALL_PREFIX env. var.
    IO.write cliwrapper, <<~EOS
      #!/bin/sh
      OPENFLUID_INSTALL_PREFIX="#{staged_path}" "#{staged_path}/bin/openfluid" "$@"
    EOS
  end


  # move of the .app bundles to the Applications directory
  for OFapp in OFapps
    app "bin/#{OFapp}.app"
  end
 

  # link of the command line wrapper into /usr/local/bin
  binary cliwrapper, target:'openfluid'


  # postinstall operations
  postflight do
  	
  	# on .app bundles
    for OFapp in OFapps
    	  # set of the lib path as an rpath
      system "install_name_tool","-add_rpath","#{staged_path}/lib/","#{appdir}/#{OFapp}.app/Contents/MacOS/#{OFapp}"
      # add of the OPENFLUID_INSTALL_PREFIX env. var.
      system "defaults","write","#{appdir}/#{OFapp}.app/Contents/Info","LSEnvironment","<dict><key>OPENFLUID_INSTALL_PREFIX</key><string>#{staged_path}</string></dict>"
    end

    # add of the OPENFLUID_INSTALL_PREFIX env. var. on the command line program
    system "install_name_tool","-add_rpath","#{staged_path}/lib/","#{staged_path}/bin/openfluid"

  end

end
