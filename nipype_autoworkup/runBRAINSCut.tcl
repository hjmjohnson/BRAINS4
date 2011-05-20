  proc runBRAINSCut {Subject ImageMap AtlasMap Regions ProbabilityMap XmlFile OutputDir OutputList} {

    global BrainsConfig

    # Break down our arguments
    set NewImageMap [ split $ImageMap ":" ]
    set ImageMap [list]
    foreach entry $NewImageMap {
      lappend $ImageMap [ split $entry "," ]
    }

    set NewAtlasMap [ split $AtlasMap ":" ]
    set AtlasMap [list]
    foreach entry $NewAtlasMap {
      lappend $AtlasMap [ split $entry "," ]
    }

    set NewProbabilityMap [ split $ProbabilityMap ":" ]
    set ProbabilityMap [list]
    foreach entry $NewProbabilityMap {
      lappend $ProbabilityMap [ split $entry "," ]
    }

    set OutputList [ split $OutputList "," ]

    set Regions [ split $Regions "," ]



    # Process as usual
    foreach i $ImageMap {
      lappend inputImageList [lindex $i 1]
    }

    if {[Brains::Utils::CheckOutputsNewer $OutputList $inputImageList ] == false } {

      if { [catch {open $XmlFile w} fid] } {
        puts "Error: Could not open $XmlFile for writing"
        return 1
      }

      # Create the XML Configuration file
      puts $fid "<AutoSegProcessDescription> "
      puts $fid "  <DataSet Name=\"${Subject}\" Type=\"Apply\""
      puts $fid "           OutputDir=\"${OutputDir}\" >"
      foreach i $ImageMap {
        set imageType [lindex $i 0]
        set imageFile [lindex $i 1]
        puts $fid "      <Image Type=\"$imageType\" Filename=\"$imageFile\" />"
      }

      #
      # Add Regisration parameters
      puts $fid "      <Registration SubjToAtlasRegistrationFilename=\"$OutputDir/${Subject}_To_Atlas_T1_BSpline.mat\" "
      puts $fid "                    AtlasToSubjRegistrationFilename=\"$OutputDir/Atlas_To_${Subject}_T1_BSpline.mat\" "
      puts $fid "                   ID=\"T1_BSpline\" /> "
      puts $fid "  </DataSet>"
      puts $fid ""


      # Atlas Image
      set AtlasDir $BrainsConfig(BRAINSABCAtlasDir)
      puts $fid "  <DataSet Name=\"template\" Type=\"Atlas\" >"
      foreach i $AtlasMap {
        set atlasType [lindex $i 0]
        set atlasFile [lindex $i 1]
        puts $fid "      <Image Type=\"$atlasType\" Filename=\"$atlasFile\" />"
      }
      puts $fid "  </DataSet>"
      puts $fid ""

      #
      # Registration
      set commandPath [file dirname [info nameofexecutable]]
      puts $fid "  <RegistrationParams "
      puts $fid "      Type      = \"T1_BSpline\" "
      puts $fid "      Command   = \"$commandPath/GenerateBSplineTransform_ROI.sh\" "
      puts $fid "      ImageType = \"T1\" "
      puts $fid "      ID        = \"T1_BSpline\" "
      puts $fid "   />"

      #
      # Define Probability Maps
      set AnnDir $BrainsConfig(BRAINSANNDir)
      foreach i $ProbabilityMap {
        set regionName [lindex $i 0]
        set mapFile [lindex $i 1]
        puts $fid "  <ProbabilityMap StructureID    = \"$regionName\" "
        puts $fid "                  Gaussian       = \"1.0\""
        puts $fid "                  GenerateVector = \"true\""
        puts $fid "                  Filename       = \"$mapFile\""
        puts $fid "                  rho            =\"$AnnDir/rho.nii.gz\""
        puts $fid "                  phi            =\"$AnnDir/phi.nii.gz\""
        puts $fid "                  theta          =\"$AnnDir/theta.nii.gz\""
        puts $fid "   />"
        puts $fid ""
      }

      #
      # Add ANNParams
      puts $fid "  <ANNParams        Iterations             = \"1\""
      puts $fid "                    MaximumVectorsPerEpoch = \"700000\""
      puts $fid "                    EpochIterations        = \"100\""
      puts $fid "                    ErrorInterval          = \"1\""
      puts $fid "                    DesiredError           = \"0.000001\""
      puts $fid "                    NumberOfHiddenNodes    = \"1\""
      puts $fid "                    ActivationSlope        = \"1.0\""
      puts $fid "                    ActivationMinMax       = \"1.0\""
      puts $fid "   />"
      puts $fid ""

      #
      # Add Neural Params
      foreach i $Regions {
        puts $fid "   <NeuralNetParams MaskSmoothingValue     = \"0.0\""
        puts $fid "                    GradientProfileSize    = \"1\""
        puts $fid "                    TrainingVectorFilename = \"na\""
        puts $fid "                    TrainingModelFilename  = \"$AnnDir/${i}_model.txt\""
        puts $fid "                    TestVectorFilename     = \"na\""
        puts $fid "   />"
        puts $fid ""
      }

      puts $fid "  <ApplyModel       CutOutThresh           = \"0.05\""
      puts $fid "                    CutOutGaussian         = \"0\""
      puts $fid "                    MaskThresh             = \"0.3\""
      puts $fid "   />"
      puts $fid ""
      puts $fid "</AutoSegProcessDescription> "
      close $fid

      set command "exec [file dirname [info nameofexecutable]]/BRAINSCut"
      append command " --applyModel"
      append command " --netConfiguration $XmlFile"
      append command " >&@stdout"

      puts "BRAINSCut command: ${command}"
      if { [catch {eval ${command}} PrintTypeScript] } {
        puts "Error: $PrintTypeScript"
        return 1
      }

      # Rename the output as specified
      for {set i 0} {$i < [llength $ProbabilityMap]} {incr i} {
        set regionName [lindex [lindex $ProbabilityMap $i] 0]
        set annCutFile $OutputDir/ANNCutOut_median${regionName}${Subject}_OneLabeled.nii.gz
        set outputFile [lindex $OutputList $i]
        if {[file exists $annCutFile]} {
          file rename $annCutFile $outputFile
        } else {
          puts "ERROR: Failed to generate the output file $annCutFile"
          return 1
        }
      }
    }
    return 0
  }
}

package require BrainsGlue

runBRAINSCut [lindex $argv 0] [lindex $argv 1] [lindex $argv 2] [lindex $argv 3] [lindex $argv 4] [lindex $argv 5] [lindex $argv 6] [lindex $argv 7]
