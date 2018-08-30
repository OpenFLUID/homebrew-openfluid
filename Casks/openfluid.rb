cask 'openfluid' do

  version '2.1.5'
  sha256 '52bf0bd4abce9633a757ca655005b34b3243668a6faa0cbf376f1218c03dd950'

  url 'https://www.openfluid-project.org/dloadsproxy/final/v2.1.5/openfluid_2.1.5_osx64.tar.bz2'
  name 'OpenFLUID'
  homepage 'https://wwww.openfluid-project.org'


  # external dependencies
  depends_on formula: 'boost'
  depends_on formula: 'rapidjson'
  depends_on formula: 'gdal'
  depends_on formula: 'geos'
  depends_on formula: 'qt'
  depends_on formula: 'p7zip'
  depends_on formula: 'gnuplot'
  depends_on formula: 'cmake'


  # system dependencies
  depends_on macos: '>= :el_capitan'


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
