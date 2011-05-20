  # Brains::Gtract::GetScalarResultList --
  #
  #  Convience function to create a list for printing results
  #  given an array generated from the LabelStatisticsImageFilter
  #
  # Arguments:
  #  RegionName(s)    List of labels for the region(s) memasured
  #  ScalarName       Type of scalar measured
  #  FileName         Filename for the image being measured
  #  MeasurementList  Results from the LabelStatisticsImageFilter
  #
  # Results:
  #  Returns a standard list for printing results.
  proc GetScalarResultList {RegionName ScalarName FileName MeasurementList} {

    for {set i 0} {$i < [llength $MeasurementList]} {incr i} {
      lappend currentResult [lindex $RegionName $i]
      lappend currentResult $ScalarName
      lappend currentResult $FileName
      lappend currentResult [lindex [lindex [lindex $MeasurementList $i] 1] 2]
      lappend currentResult [lindex [lindex [lindex $MeasurementList $i] 2] 2]
      lappend currentResult [lindex [lindex [lindex $MeasurementList $i] 3] 2]
      lappend currentResult [lindex [lindex [lindex $MeasurementList $i] 4] 2]
      lappend currentResult [lindex [lindex [lindex $MeasurementList $i] 0] 2]
      lappend resultList $currentResult
      unset currentResult
    }

    return $resultList
  }


  # Brains::Gtract::WriteCsvDtiFile --
  #
  #  Write the results to a CSV file
  #
  # Arguments:
  #  CsvFile         CSV File to write results
  #  PatientId       Patient-Id used for labeling results
  #  ScanId          Scan-Id used for labeling results
  #  ScalarMeasures  Result list to write
  #
  # Results:
  #  Returns a standard list for printing results.
  proc WriteCsvDtiFile {CsvFile PatientId ScanId ScalarMeasures} {

    global tcl_platform
    global BrainsConfig

    # Catch this command
    set  outfile [open $CsvFile "w"]

    # Write the CSV header
    puts $outfile "Patient-Id,Scan-Id,Program,Version,Image,Date,User,Region,Image-Type,Mean,Minimum,Maximum,Standard-Deviation,Volume"

    set date [clock format [clock seconds] -format "%Y-%m-%d_%H:%M"]
    set user $tcl_platform(user)
    set platform $tcl_platform(os)
    set version $BrainsConfig(AutoWorkupVersion)

    # Write DTI Measurement Data
    for {set i 0} {$i < [llength $ScalarMeasures]} {incr i} {
      set currentResult [lindex $ScalarMeasures $i]
      for {set j 0} {$j < [llength $currentResult]} {incr j} {
        set region [lindex [lindex $currentResult $j] 0]
        set type   [lindex [lindex $currentResult $j] 1]
        set iName  [lindex [lindex $currentResult $j] 2]
        set mean   [lindex [lindex $currentResult $j] 3]
        set min    [lindex [lindex $currentResult $j] 4]
        set max    [lindex [lindex $currentResult $j] 5]
        set stdev  [lindex [lindex $currentResult $j] 6]
        set volume [lindex [lindex $currentResult $j] 7]
        puts $outfile "$PatientId,$ScanId,BRAINS,$version,$iName,$date,$user,$region,$type,$mean,$min,$max,$stdev,$volume"
      }
    }

    close $outfile

    return 1
  }


  proc ScalarTalairachMeasures {ScalarFileList BrainMaskFile ClassImageFile TalairachBounds TalairachDir PatientId ScanId ResultDir} {

    set ScalarFileList [ split $ScalarFileList "," ]

    # Set the Measurement Files
    set standardCsvFile $ResultDir/${ScanId}_BrainsDtiMeasurements.csv
    set standardOnlineCsvFile $ResultDir/${ScanId}_BrainsDtiMeasurementsOneLines.csv
    set standardXmlFile $ResultDir/${ScanId}_BrainsDtiMeasurements.xml
    set standardHtmlFile $ResultDir/${ScanId}_BrainsDtiMeasurements.html

    # Backup previous results
    #set result [backupMeasurementFile $standardVolsFile $defaultMeasureFile]
    #if {$result != 1} {
    #    return -1
    #}


    set TalairachMaskDir $ResultDir/Talairach_DTI
    if { ![file isdirectory $TalairachMaskDir] } {
      file mkdir $TalairachMaskDir
    }

    # Talairach Boxes that are to be measured
    set talairachBoxes {cran_box brainstem_box cerebel_box nfrontal_box temporal_box parietal_box occipital_box subcort_box}

    #AP - Measurement Regions
    set talairachBoxAP [list [list A A.5] [list A.5 A] [list B B.5] \
                        [list B.5 B] [list C C.5] [list C.5 C] \
                        [list D D.5] [list D.5 D] [list E1 E1] \
                        [list E2 E2] [list E3 E3] [list F F.5] \
                        [list F.5 F] [list G G.5] [list G.5 G] \
                        [list H H.5] [list H.5 H] [list I I.5] \
                        [list I.5 I]]

    # Verify that all of the desired boxes are in the Talairach Directory
    set boxFiles [glob $TalairachDir/*_box]

    foreach measureBox $talairachBoxes {
      set foundBox [lsearch -exact $boxFiles $TalairachDir/$measureBox]
      if {$foundBox == -1} {
          return 1
      }
    }

    # Load the Images to be measured
    if {[llength $ScalarFileList] != 4} {
      error "Expected 4 items in the ScalarFileList (FA, ADC, RD, AD)"
    }
    foreach i $ScalarFileList {
      lappend scalarImageList [Brains::itk::LoadImage $i "Float-Single"]
    }
    set BrainMask [Brains::itk::LoadImage $BrainMaskFile "Unsigned-8bit"]
    set ClassImage [Brains::itk::LoadImage $ClassImageFile "Unsigned-8bit"]

    set tissueWhiteMask [Brains::itk::BinaryThresholdImage $ClassImage 190 255 0 "Unsigned-8bit"]
    set faWhiteMask [Brains::itk::BinaryThresholdImage [lindex $scalarImageList 0] 0.1 1.0 0 "Unsigned-8bit"]

    # Compute masks for white matter based on Classified and FA image
    set tmpWhiteMask [Brains::itk::AndImage $tissueWhiteMask $faWhiteMask]
    set whiteMatterMask [Brains::itk::AndImage $BrainMask $tmpWhiteMask]

    # Define a region split along the x axis yielding a left and right sided piece
    set xSize [lindex [Brains::itkUtils::GetItkImageSize $ClassImage] 0]
    set ySize [lindex [Brains::itkUtils::GetItkImageSize $ClassImage] 1]
    set zSize [lindex [Brains::itkUtils::GetItkImageSize $ClassImage] 2]
    set xMiddle [expr $xSize / 2 ]

    set splitRegion [itkImageRegion3]
    set splitSize [$splitRegion GetSize]
    set splitIndex [$splitRegion GetIndex]
    $splitSize SetElement 0 $xMiddle
    $splitSize SetElement 1 $ySize
    $splitSize SetElement 2 $zSize

    $splitIndex SetElement 0 $xMiddle
    $splitIndex SetElement 1 0
    $splitIndex SetElement 2 0

    $splitRegion SetSize $splitSize
    $splitRegion SetIndex $splitIndex


    # Define the left and right hemisphere for the mask
    set lWmMask [Brains::itk::ClipImage $whiteMatterMask $splitRegion]
    $splitIndex SetElement 0 0
    $splitRegion SetIndex $splitIndex
    set rWmMask [Brains::itk::ClipImage $whiteMatterMask $splitRegion ]


    # Clean-up Memory
    $tissueWhiteMask Delete
    $faWhiteMask Delete
    $tmpWhiteMask Delete

    #########################################################
    # Measure the Talairach Box Volumes
    #########################################################

    foreach fileName $talairachBoxes {
      # Create Talairach Boxes
      set talairachMaskFile $TalairachMaskDir/${ScanId}_ACPC_${fileName}_DTI.nii.gz
      set segmentationMode 1
      set hemisphere "both"
      Brains::External::runCreateTalairachMask $ClassImageFile $TalairachBounds \
           $TalairachDir/$fileName $talairachMaskFile $hemisphere $segmentationMode

      set talairachMask [Brains::itk::LoadImage $talairachMaskFile "Unsigned-8bit"]

      set boxMask [Brains::itk::AndImage $talairachMask $whiteMatterMask]
      set lBoxMask [Brains::itk::AndImage $talairachMask $lWmMask]
      set rBoxMask [Brains::itk::AndImage $talairachMask $rWmMask]
      if {$fileName == "cran_box"} {
        # cran_box - Measure Scalar Images
        set i 0
        foreach scalarImage $scalarImageList {
          switch $i {
            0 {set scalarName FA}
            1 {set scalarName ADC}
            2 {set scalarName RD}
            3 {set scalarName AD}
            default {set scalarName UNKNOWN}
          }
          set result [Brains::itk::measureLabelImageStatistics $boxMask $scalarImage]
          lappend scalarMeasures [GetScalarResultList ${fileName} $scalarName [lindex $ScalarFileList $i] $result]

          set result [Brains::itk::measureLabelImageStatistics $lBoxMask $scalarImage]
          lappend scalarMeasures [GetScalarResultList l_${fileName} $scalarName [lindex $ScalarFileList $i] $result]

          set result [Brains::itk::measureLabelImageStatistics $rBoxMask $scalarImage]
          lappend scalarMeasures [GetScalarResultList r_${fileName} $scalarName [lindex $ScalarFileList $i] $result]

          incr i
        }
      } else {
        set talairachRegionMaskFile $TalairachMaskDir/${ScanId}_ACPC_${fileName}_white_DTI.nii.gz
        set talairachRegionLeftMaskFile $TalairachMaskDir/${ScanId}_ACPC_${fileName}_l_white_DTI.nii.gz
        set talairachRegionRightMaskFile $TalairachMaskDir/${ScanId}_ACPC_${fileName}_r_white_DTI.nii.gz
        Brains::itk::SaveImage $boxMask $talairachRegionMaskFile
        Brains::itk::SaveImage $lBoxMask $talairachRegionLeftMaskFile
        Brains::itk::SaveImage $rBoxMask $talairachRegionRightMaskFile
        lappend wholeBrainList $talairachRegionMaskFile
        lappend leftBrainList $talairachRegionLeftMaskFile
        lappend rightBrainList $talairachRegionRightMaskFile
        lappend brainRegionList ${fileName}
        lappend leftRegionList l_${fileName}
        lappend rightRegionList r_${fileName}
      }

      # Clean-up Memory
      $boxMask Delete
      $lBoxMask Delete
      $rBoxMask Delete
    }

    # Create label maps for the non-overlapping labels
    set brainWhiteLabelMap $TalairachMaskDir/${ScanId}_ACPC_LabelMap_white_DTI.nii.gz
    set brainLeftWhiteLabelMap $TalairachMaskDir/${ScanId}_ACPC_LabelMap_l_white_DTI.nii.gz
    set brainRightWhiteLabelMap $TalairachMaskDir/${ScanId}_ACPC_LabelMap_r_white_DTI.nii.gz
    Brains::WorkupUtils::CreateLabelMapFromBinaryImages $wholeBrainList $brainWhiteLabelMap
    Brains::WorkupUtils::CreateLabelMapFromBinaryImages $leftBrainList $brainLeftWhiteLabelMap
    Brains::WorkupUtils::CreateLabelMapFromBinaryImages $rightBrainList $brainRightWhiteLabelMap
    set talairachLabelMap [Brains::itk::LoadImage $brainWhiteLabelMap "Signed-16bit"]
    set talairachLeftMap [Brains::itk::LoadImage $brainLeftWhiteLabelMap "Signed-16bit"]
    set talairachRightMap [Brains::itk::LoadImage $brainRightWhiteLabelMap "Signed-16bit"]

    # Measure the label maps (combined, left, right)
    set i 0
    foreach scalarImage $scalarImageList {
      switch $i {
        0 {set scalarName FA}
        1 {set scalarName ADC}
        2 {set scalarName RD}
        3 {set scalarName AD}
        default {set scalarName UNKNOWN}
      }
      set result [Brains::itk::measureLabelImageStatistics $talairachLabelMap $scalarImage]
      lappend scalarMeasures [GetScalarResultList $brainRegionList $scalarName [lindex $ScalarFileList $i] $result]

      set result [Brains::itk::measureLabelImageStatistics $talairachLeftMap $scalarImage]
      lappend scalarMeasures [GetScalarResultList $leftRegionList $scalarName [lindex $ScalarFileList $i] $result]

      set result [Brains::itk::measureLabelImageStatistics $talairachRightMap $scalarImage]
      lappend scalarMeasures [GetScalarResultList $rightRegionList $scalarName [lindex $ScalarFileList $i] $result]

      incr i
    }
    # Write out the box measurements
    set standardDtiFile $ResultDir/${ScanId}_DTI_Scalars.csv
    WriteCsvDtiFile $standardDtiFile $PatientId $ScanId $scalarMeasures

    # Clean-up Memory
    $BrainMask Delete
    $ClassImage Delete
    $talairachLabelMap Delete
    $talairachLeftMap Delete
    $talairachRightMap Delete

    #########################################################
    # Measure the Talairach Anterior/Posterior Sections
    #########################################################
    set talairachBoxMid a
    set talairachBoxRL d
    set talairachBoxS 1
    set talairachBoxI 14
    foreach region $talairachBoxAP {
      set talairachFile $TalairachMaskDir/tmpTal_box
      set anterior [lindex $region 0]
      set posterior [lindex $region 1]
      set  outfile [open $talairachFile "w"]
      puts $outfile "$anterior $posterior $talairachBoxMid $talairachBoxRL $talairachBoxS $talairachBoxI"
      close $outfile

      set talairachMaskFile $TalairachMaskDir/${ScanId}_ACPC_${anterior}-${posterior}_DTI.nii.gz
      set segmentationMode 1
      set hemisphere "both"
      Brains::External::runCreateTalairachMask $ClassImageFile $TalairachBounds \
         $TalairachMaskDir/tmpTal_box $talairachMaskFile $hemisphere $segmentationMode

      lappend talairachAPList $talairachMaskFile
      lappend regionAPList ${anterior}-${posterior}
      lappend regionRightAPList r_${anterior}-${posterior}
      lappend regionLeftAPList l_${anterior}-${posterior}
    }

    set apLabelMap $TalairachMaskDir/${ScanId}_ACPC_AP_LabelMap_DTI.nii.gz
    Brains::WorkupUtils::CreateLabelMapFromBinaryImages $talairachAPList $apLabelMap
    set talairachLabelMap [Brains::itk::LoadImage $apLabelMap "Unsigned-8bit"]

    set apWhiteLabelMap [Brains::itk::ImageMath $talairachLabelMap $whiteMatterMask Multiply]
    set lapWhiteLabelMap [Brains::itk::ImageMath $talairachLabelMap $lWmMask Multiply]
    set rapWhiteLabelMap [Brains::itk::ImageMath $talairachLabelMap $rWmMask Multiply]

    set i 0
    foreach scalarImage $scalarImageList {
      switch $i {
        0 {set scalarName FA}
        1 {set scalarName ADC}
        2 {set scalarName RD}
        3 {set scalarName AD}
        default {set scalarName UNKNOWN}
      }
      set result [Brains::itk::measureLabelImageStatistics $apWhiteLabelMap $scalarImage]
      lappend scalarAPMeasures [GetScalarResultList $regionAPList $scalarName [lindex $ScalarFileList $i]  $result]

      set result [Brains::itk::measureLabelImageStatistics $lapWhiteLabelMap $scalarImage]
      lappend scalarAPMeasures [GetScalarResultList $regionLeftAPList $scalarName [lindex $ScalarFileList $i]  $result]

      set result [Brains::itk::measureLabelImageStatistics $rapWhiteLabelMap $scalarImage]
      lappend scalarAPMeasures [GetScalarResultList $regionRightAPList $scalarName [lindex $ScalarFileList $i] $result]

      incr i
    }

    # Clean-up memory
    $talairachLabelMap Delete
    $apWhiteLabelMap Delete
    $lapWhiteLabelMap Delete
    $rapWhiteLabelMap Delete
    $lWmMask Delete
    $rWmMask Delete
    $whiteMatterMask Delete
    foreach scalarImage $scalarImageList { $scalarImage Delete}

    # Write Out the Results
    set standardDtiAPFile $ResultDir/${ScanId}_DTI_Scalars_AP.csv
    WriteCsvDtiFile $standardDtiAPFile $PatientId $ScanId $scalarAPMeasures
    #SetMeasurementFilePermissions $standardVolsFile $defaultMeasureFile

    return [list  $standardDtiFile $standardDtiAPFile]
  }

package require BrainsGlue

ScalarTalairachMeasures [lindex $argv 0] [lindex $argv 1] [lindex $argv 2] [lindex $argv 3] [lindex $argv 4] [lindex $argv 5] [lindex $argv 6] [lindex $argv 7]



