  ####################################################################################
  # Procedure:  ClassTalairachVolumes
  # Developer:  Vincent A. Magnotta
  #
  # Synopsis:  Measures segmentation volumes. This data is measured similar to
  #    BRAINS where both total volumes and internal CSF volumes are
  #    generated to measure both ventricular and surface CSF. This
  #    procedure measures both continuous and discrete volumes and
  #    lobe volumes. A standard file called "Standard_Class_Volumes"
  #    is created along with the b2_saved_class_volumes file.
  #
  # Prototype:   ClassTalairachVolumes {brain_mask class_image talairach_bounds tal_box_dir}
  #
  #     brain_mask    - mask used to define the brain
  #    class_image    - Tissue classified image for the subject
  #    talairach_bounds  - Talairach parameters for the subject
  #    tal_box_dir    - Directory containing Talairach boxes
  #
  # Globals Used: B2_IPL_FLAG
  ####################################################################################

proc ClassTalairachVolumes {BrainMaskFile ClassImageFile DiscreteImageFile TalairachBounds TalairachDir PatientId ScanId ResultDir} {

  set TalairachMaskDir $ResultDir/Talairach
  if { ![file isdirectory $TalairachMaskDir] } {
    file mkdir $TalairachMaskDir
  }

  # Talairach Boxes that are to be measured
  set talairachBoxes {cran_box brainstem_box cerebel_box nfrontal_box temporal_box parietal_box occipital_box subcort_box vent2_box}

  # Verify that all of the desired boxes are in the Talairach Directory
  set boxFiles [glob $TalairachDir/*_box]

  foreach measureBox $talairachBoxes {
    set foundBox [lsearch -exact $boxFiles $TalairachDir/$measureBox]
    if {$foundBox == -1} {
        return 1
    }
  }

  # Load the Images to be measured
  set BrainMask [Brains::itk::LoadImage $BrainMaskFile "Unsigned-8bit"]
  set ClassImage [Brains::itk::LoadImage $ClassImageFile "Unsigned-8bit"]
  set DiscreteImage [Brains::itk::LoadImage $DiscreteImageFile "Unsigned-8bit"]

  # Set the Measurement Files
  set standardCsvFile $ResultDir/${ScanId}_BrainsClassMeasurements.csv
  set standardOnlineCsvFile $ResultDir/${ScanId}_BrainsClassMeasurementsOneLines.csv
  set standardXmlFile $ResultDir/${ScanId}_BrainsClassMeasurements.xml
  set standardHtmlFile $ResultDir/${ScanId}_BrainsClassMeasurements.html

  # Backup previous results
  #set result [backupMeasurementFile $standardVolsFile $defaultMeasureFile]
  #if {$result != 1} {
  #    return -1
  #}
  set Vent2Mask $TalairachMaskDir/${ScanId}_ACPC_vent2_box.nii.gz
  Brains::External::runCreateTalairachMask $ClassImageFile $TalairachBounds $TalairachDir/vent2_box $Vent2Mask

  set csfMask [Brains::itk::LoadImage $Vent2Mask "Unsigned-8bit"]


  # Compute masks for tissue and internal CSF masks for continuous data
  set tmpTissueMask [Brains::itk::BinaryThresholdImage $ClassImage 70 255]
  set tissueVentMask [Brains::itk::OrImage $csfMask $tmpTissueMask]
  set tissueMask [Brains::itk::AndImage $tissueVentMask $BrainMask ]
  set tissueFillMask [Brains::itk::GrayscaleFillhole $tissueMask]
  set intCsfMask [Brains::itk::AndImage $BrainMask $tissueFillMask]

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


  # Define the left hemispheres for the masks
  set lMask [Brains::itk::ClipImage $BrainMask $splitRegion]
  set lIntCsfMask [Brains::itk::ClipImage $intCsfMask $splitRegion]


  # Define the right hemispheres for the masks
  $splitIndex SetElement 0 0
  $splitRegion SetIndex $splitIndex
  set rMask [Brains::itk::ClipImage $BrainMask $splitRegion ]
  set rIntCsfMask [Brains::itk::ClipImage $intCsfMask $splitRegion]

  # Clean-up Memory
  $csfMask Delete
  $tissueMask Delete
  $tissueFillMask Delete
  $intCsfMask Delete
  $tmpTissueMask Delete
  $tissueVentMask Delete


  ################################################################
  # As per BRAINS, measure whole brain as well as Talairach boxes
  ################################################################

  # Measure CONTINUOUS Data
  set measureClassFilter [itkMeasureClassImageFilterIUC3IUC3_New]
  $measureClassFilter SetMaskInput $lMask
  $measureClassFilter SetInput $ClassImage
  $measureClassFilter Update
  lappend ClassVolume [GetClassVolumeList l_brain $measureClassFilter]

  $measureClassFilter SetMaskInput $rMask
  $measureClassFilter Update
  lappend ClassVolume [GetClassVolumeList r_brain $measureClassFilter]

  $measureClassFilter SetMaskInput $lIntCsfMask
  $measureClassFilter Update
  lappend ClassIntCsfVolume [GetClassVolumeList l_Int_brain $measureClassFilter]

  $measureClassFilter SetMaskInput $rIntCsfMask
  $measureClassFilter Update
  lappend ClassIntCsfVolume [GetClassVolumeList r_Int_brain $measureClassFilter]


  # Measure DISCRETE Data
  $measureClassFilter SetMaskInput $lMask
  $measureClassFilter SetInput $DiscreteImage
  $measureClassFilter Update
  lappend DiscreteVolume [GetClassVolumeList l_brain_Discrete $measureClassFilter]

  $measureClassFilter SetMaskInput $rMask
  $measureClassFilter Update
  lappend DiscreteVolume [GetClassVolumeList r_brain_Discrete $measureClassFilter]

  $measureClassFilter SetMaskInput $lIntCsfMask
  $measureClassFilter Update
  lappend DiscreteIntCsfVolume [GetClassVolumeList l_Int_brain_Discrete $measureClassFilter]

  $measureClassFilter SetMaskInput $rIntCsfMask
  $measureClassFilter Update
  lappend DiscreteIntCsfVolume [GetClassVolumeList r_Int_brain_Discrete $measureClassFilter]


  #########################################################
  # Measure the Talairach Box Volumes
  #########################################################
  foreach fileName $talairachBoxes {

    # Create Talairach Boxes
    set talairachMaskFile $TalairachMaskDir/${ScanId}_ACPC_${fileName}_seg.nii.gz
    set segmentationMode 1
    set hemisphere "both"
    Brains::External::runCreateTalairachMask $ClassImageFile $TalairachBounds $TalairachDir/$fileName \
       $talairachMaskFile $hemisphere $segmentationMode

    set talairachMask [Brains::itk::LoadImage $talairachMaskFile "Unsigned-8bit"]


    set lBoxMask [Brains::itk::AndImage $talairachMask $lMask ]
    set rBoxMask [Brains::itk::AndImage $talairachMask $rMask ]
    set lIntCSFBoxMask [Brains::itk::AndImage $talairachMask $lIntCsfMask ]
    set rIntCSFBoxMask [Brains::itk::AndImage $talairachMask $rIntCsfMask ]


    # Measure CONTINUOUS Data
    $measureClassFilter SetInput $ClassImage
    $measureClassFilter SetMaskInput $lBoxMask
    $measureClassFilter Update
    lappend ClassVolume [GetClassVolumeList l_${fileName} $measureClassFilter]

    $measureClassFilter SetMaskInput $rBoxMask
    $measureClassFilter Update
    lappend ClassVolume [GetClassVolumeList r_${fileName} $measureClassFilter]

    $measureClassFilter SetMaskInput $lIntCSFBoxMask
    $measureClassFilter Update
    lappend ClassIntCsfVolume [GetClassVolumeList l_Int_${fileName} $measureClassFilter]

    $measureClassFilter SetMaskInput $rIntCSFBoxMask
    $measureClassFilter Update
    lappend ClassIntCsfVolume [GetClassVolumeList r_Int_${fileName} $measureClassFilter]


    # Measure DISCRETE Data
    $measureClassFilter SetInput $DiscreteImage
    $measureClassFilter SetMaskInput $lBoxMask
    $measureClassFilter Update
    lappend DiscreteVolume [GetClassVolumeList l_${fileName}_Discrete $measureClassFilter]

    $measureClassFilter SetMaskInput $rBoxMask
    $measureClassFilter Update
    lappend DiscreteVolume [GetClassVolumeList r_${fileName}_Discrete $measureClassFilter]

    $measureClassFilter SetMaskInput $lIntCSFBoxMask
    $measureClassFilter Update
    lappend DiscreteIntCsfVolume [GetClassVolumeList l_Int_${fileName}_Discrete $measureClassFilter]

    $measureClassFilter SetMaskInput $rIntCSFBoxMask
    $measureClassFilter Update
    lappend DiscreteIntCsfVolume [GetClassVolumeList r_Int_${fileName}_Discrete $measureClassFilter]

    # Clean-up Memory
    $talairachMask Delete
    $lBoxMask Delete
    $rBoxMask Delete
    $lIntCSFBoxMask Delete
    $rIntCSFBoxMask Delete
  }

  # Get rid of the Objects that were created
  # VAM - Seg Fault - look into clip image and why the delete generates a SegFault
  #$lMask Delete
  #$rMask Delete
  #$lIntCSFBoxMask Delete
  #$rIntCSFBoxMask Delete

  # Write Out the Results
  WriteCsvMeasurementFile $standardCsvFile $PatientId $ScanId $ClassVolume $ClassIntCsfVolume \
                          $DiscreteVolume $DiscreteIntCsfVolume $ClassImageFile $DiscreteImageFile
  #SetMeasurementFilePermissions $standardVolsFile $defaultMeasureFile

  return 1

}

proc GetClassVolumeList {regionName measurementFilter} {
  lappend resultList $regionName
  lappend resultList [$measurementFilter GetCsfVolume]
  lappend resultList [$measurementFilter GetGreyMatterVolume]
  lappend resultList [$measurementFilter GetWhiteMatterVolume]
  lappend resultList [$measurementFilter GetVenousBloodVolume]
  lappend resultList [$measurementFilter GetOtherVolume]
  return $resultList
}

proc WriteXmlMeasurementFile {XmlFile PatientId ScanId Version ClassVolumes IntCsfClassVolumes
                              DiscreteVolumes IntCsfDiscreteVolume ClassImage DiscreteImage} {

  global tcl_platform
  global BrainsConfig

  # Catch this command
  set  outfile [open $XmlFile "w"]
  set date [clock format [clock seconds] -format "%Y-%m-%d_%H:%M"]
  set version $BrainsConfig(AutoWorkupVersion)

  # Write the XML header
  puts $outfile "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
  puts $outfile "<XCEDE xmlns=\"http://www.xcede.org/xcede-2\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" >"
  puts $outfile "<analysis subjectID=\"$PatientId $ScanId\">"
  puts $outfile "  <provenance>"
  puts $outfile "    <processStep>"
  puts $outfile "     <program>BRAINS</program>"
  puts $outfile "       <programArguments>UNKNOWN</programArguments>"
  puts $outfile "         <user>$tcl_platform(user)</user>"
  puts $outfile "         <hostName>[info hostname]</hostName>"
  puts $outfile "         <platform>$tcl_platform(os)</platform>"
  puts $outfile "         <cvs>$version</cvs>"
  puts $outfile "         <package>AutoWorkup</package>"
  puts $outfile "   </processStep>"
  puts $outfile "  </provenance>"

  # Write Continuous Measurement Data
  for {set i 0} {$i < [llength $ClassVolumes]} {incr i} {
    set region [lindex [lindex $ClassVolumes $i] 0]
    set csfVolume [lindex [lindex $ClassVolumes $i] 1]
    set gmVolume [lindex [lindex $ClassVolumes $i] 2]
    set wmVolume [lindex [lindex $ClassVolumes $i] 3]
    set vbVolume [lindex [lindex $ClassVolumes $i] 4]
    set otherVolume [lindex [lindex $ClassVolumes $i] 5]
    puts $outfile "  <measurementGroup>"
    puts $outfile "    <entity xsi:type=\"anatomicalEntity_t\">"
    puts $outfile "      <label nomenclature=\"Brains3\" termID=\"1\">$region</label>"
    puts $outfile "    </entity>"
    puts $outfile "    <observation name=\"IMAGE\" type=\"string\">$ClassImage</observation>"
    puts $outfile "    <observation name=\"DATE\" type=\"string\">$date</observation>"
    puts $outfile "    <observation name=\"USER\" type=\"string\">$tcl_platform(user)</observation>"
    puts $outfile "    <observation name=\"GM-VOLUME\" type=\"float\">$gmVolume</observation>"
    puts $outfile "    <observation name=\"WM-VOLUME\" type=\"float\">$wmVolume</observation>"
    puts $outfile "    <observation name=\"CSF-VOLUME\" type=\"float\">$csfVolume</observation>"
    puts $outfile "    <observation name=\"VB-VOLUME\" type=\"float\">$vbVolume</observation>"
    puts $outfile "    <observation name=\"OTHER-VOLUME\" type=\"float\">$otherVolume</observation>"
    puts $outfile "  </measurementGroup>"
  }

  # Write Continuous Measurement Data - Internal CSF
  for {set i 0} {$i < [llength $IntCsfClassVolumes]} {incr i} {
    set region [lindex [lindex $IntCsfClassVolumes $i] 0]
    set csfVolume [lindex [lindex $IntCsfClassVolumes $i] 1]
    set gmVolume [lindex [lindex $IntCsfClassVolumes $i] 2]
    set wmVolume [lindex [lindex $IntCsfClassVolumes $i] 3]
    set vbVolume [lindex [lindex $IntCsfClassVolumes $i] 4]
    set otherVolume [lindex [lindex $IntCsfClassVolumes $i] 5]
    puts $outfile "  <measurementGroup>"
    puts $outfile "    <entity xsi:type=\"anatomicalEntity_t\">"
    puts $outfile "      <label nomenclature=\"Brains3\" termID=\"1\">$region</label>"
    puts $outfile "    </entity>"
    puts $outfile "    <observation name=\"IMAGE\" type=\"string\">$ClassImage</observation>"
    puts $outfile "    <observation name=\"DATE\" type=\"string\">$date</observation>"
    puts $outfile "    <observation name=\"USER\" type=\"string\">$tcl_platform(user)</observation>"
    puts $outfile "    <observation name=\"GM-VOLUME\" type=\"float\">$gmVolume</observation>"
    puts $outfile "    <observation name=\"WM-VOLUME\" type=\"float\">$wmVolume</observation>"
    puts $outfile "    <observation name=\"CSF-VOLUME\" type=\"float\">$csfVolume</observation>"
    puts $outfile "    <observation name=\"VB-VOLUME\" type=\"float\">$vbVolume</observation>"
    puts $outfile "    <observation name=\"OTHER-VOLUME\" type=\"float\">$otherVolume</observation>"
    puts $outfile "  </measurementGroup>"
  }

  # Write Discrete Measurement Data
  for {set i 0} {$i < [llength $DiscreteVolumes]} {incr i} {
    set region [lindex [lindex $DiscreteVolumes $i] 0]
    set csfVolume [lindex [lindex $DiscreteVolumes $i] 1]
    set gmVolume [lindex [lindex $DiscreteVolumes $i] 2]
    set wmVolume [lindex [lindex $DiscreteVolumes $i] 3]
    set vbVolume [lindex [lindex $DiscreteVolumes $i] 4]
    set otherVolume [lindex [lindex $DiscreteVolumes $i] 5]
    puts $outfile "  <measurementGroup>"
    puts $outfile "    <entity xsi:type=\"anatomicalEntity_t\">"
    puts $outfile "      <label nomenclature=\"Brains3\" termID=\"1\">$region</label>"
    puts $outfile "    </entity>"
    puts $outfile "    <observation name=\"IMAGE\" type=\"string\">$DiscreteImage</observation>"
    puts $outfile "    <observation name=\"DATE\" type=\"string\">$date</observation>"
    puts $outfile "    <observation name=\"USER\" type=\"string\">$tcl_platform(user)</observation>"
    puts $outfile "    <observation name=\"GM-VOLUME\" type=\"float\">$gmVolume</observation>"
    puts $outfile "    <observation name=\"WM-VOLUME\" type=\"float\">$wmVolume</observation>"
    puts $outfile "    <observation name=\"CSF-VOLUME\" type=\"float\">$csfVolume</observation>"
    puts $outfile "    <observation name=\"VB-VOLUME\" type=\"float\">$vbVolume</observation>"
    puts $outfile "    <observation name=\"OTHER-VOLUME\" type=\"float\">$otherVolume</observation>"
    puts $outfile "  </measurementGroup>"
  }

  # Write Discrete Measurement Data - Internal CSF
  for {set i 0} {$i < [llength $IntCsfDiscreteVolume]} {incr i} {
    set region [lindex [lindex $IntCsfDiscreteVolume $i] 0]
    set csfVolume [lindex [lindex $IntCsfDiscreteVolume $i] 1]
    set gmVolume [lindex [lindex $IntCsfDiscreteVolume $i] 2]
    set wmVolume [lindex [lindex $IntCsfDiscreteVolume $i] 3]
    set vbVolume [lindex [lindex $IntCsfDiscreteVolume $i] 4]
    set otherVolume [lindex [lindex $IntCsfDiscreteVolume $i] 5]
    puts $outfile "  <measurementGroup>"
    puts $outfile "    <entity xsi:type=\"anatomicalEntity_t\">"
    puts $outfile "      <label nomenclature=\"Brains3\" termID=\"1\">$region</label>"
    puts $outfile "    </entity>"
    puts $outfile "    <observation name=\"IMAGE\" type=\"string\">$DiscreteImage</observation>"
    puts $outfile "    <observation name=\"DATE\" type=\"string\">$date</observation>"
    puts $outfile "    <observation name=\"USER\" type=\"string\">$tcl_platform(user)</observation>"
    puts $outfile "    <observation name=\"GM-VOLUME\" type=\"float\">$gmVolume</observation>"
    puts $outfile "    <observation name=\"WM-VOLUME\" type=\"float\">$wmVolume</observation>"
    puts $outfile "    <observation name=\"CSF-VOLUME\" type=\"float\">$csfVolume</observation>"
    puts $outfile "    <observation name=\"VB-VOLUME\" type=\"float\">$vbVolume</observation>"
    puts $outfile "    <observation name=\"OTHER-VOLUME\" type=\"float\">$otherVolume</observation>"
    puts $outfile "  </measurementGroup>"
  }

  puts $outfile "  </analysis>"
  puts $outfile "</XCEDE>"
  close $outfile

  return 1
}

proc WriteCsvMeasurementFile {CsvFile PatientId ScanId ClassVolumes IntCsfClassVolumes
                             DiscreteVolumes IntCsfDiscreteVolume ClassImage DiscreteImage} {

  global tcl_platform
  global BrainsConfig

  # Catch this command
  set  outfile [open $CsvFile "w"]

  # Write the CSV header
  puts $outfile "Patient-Id,Scan-Id,Program,Version,Image,Date,User,Region,GM-Volume,WM-Volume,CSF-Volume,VB-Volume,Other-Volume"

  set date [clock format [clock seconds] -format "%Y-%m-%d_%H:%M"]
  set user $tcl_platform(user)
  set platform $tcl_platform(os)
  set version $BrainsConfig(AutoWorkupVersion)

  # Write Continuous Measurement Data
  for {set i 0} {$i < [llength $ClassVolumes]} {incr i} {
    set region [lindex [lindex $ClassVolumes $i] 0]
    set csfVolume [lindex [lindex $ClassVolumes $i] 1]
    set gmVolume [lindex [lindex $ClassVolumes $i] 2]
    set wmVolume [lindex [lindex $ClassVolumes $i] 3]
    set vbVolume [lindex [lindex $ClassVolumes $i] 4]
    set otherVolume [lindex [lindex $ClassVolumes $i] 5]
    puts $outfile "$PatientId,$ScanId,BRAINS,$version,$ClassImage,$date,$user,$region,$gmVolume,$wmVolume,$csfVolume,$vbVolume,$otherVolume"
  }

  # Write Continuous Measurement Data - Internal CSF
  for {set i 0} {$i < [llength $IntCsfClassVolumes]} {incr i} {
    set region [lindex [lindex $IntCsfClassVolumes $i] 0]
    set csfVolume [lindex [lindex $IntCsfClassVolumes $i] 1]
    set gmVolume [lindex [lindex $IntCsfClassVolumes $i] 2]
    set wmVolume [lindex [lindex $IntCsfClassVolumes $i] 3]
    set vbVolume [lindex [lindex $IntCsfClassVolumes $i] 4]
    set otherVolume [lindex [lindex $IntCsfClassVolumes $i] 5]
    puts $outfile "$PatientId,$ScanId,BRAINS,$version,$ClassImage,$date,$user,$region,$gmVolume,$wmVolume,$csfVolume,$vbVolume,$otherVolume"
  }

  # Write Discrete Measurement Data
  for {set i 0} {$i < [llength $DiscreteVolumes]} {incr i} {
    set region [lindex [lindex $DiscreteVolumes $i] 0]
    set csfVolume [lindex [lindex $DiscreteVolumes $i] 1]
    set gmVolume [lindex [lindex $DiscreteVolumes $i] 2]
    set wmVolume [lindex [lindex $DiscreteVolumes $i] 3]
    set vbVolume [lindex [lindex $DiscreteVolumes $i] 4]
    set otherVolume [lindex [lindex $DiscreteVolumes $i] 5]
    puts $outfile "$PatientId,$ScanId,BRAINS,$version,$DiscreteImage,$date,$user,$region,$gmVolume,$wmVolume,$csfVolume,$vbVolume,$otherVolume"
  }

  # Write Discrete Measurement Data - Internal CSF
  for {set i 0} {$i < [llength $IntCsfDiscreteVolume]} {incr i} {
    set region [lindex [lindex $IntCsfDiscreteVolume $i] 0]
    set csfVolume [lindex [lindex $IntCsfDiscreteVolume $i] 1]
    set gmVolume [lindex [lindex $IntCsfDiscreteVolume $i] 2]
    set wmVolume [lindex [lindex $IntCsfDiscreteVolume $i] 3]
    set vbVolume [lindex [lindex $IntCsfDiscreteVolume $i] 4]
    set otherVolume [lindex [lindex $IntCsfDiscreteVolume $i] 5]
    puts $outfile "$PatientId,$ScanId,BRAINS,$version,$DiscreteImage,$date,$user,$region,$gmVolume,$wmVolume,$csfVolume,$vbVolume,$otherVolume"
  }

  close $outfile

  return 1
}


proc WriteCsvOneLineMeasurementFile {CsvFile PatientId ScanId ClassVolumes IntCsfClassVolumes
                             DiscreteVolumes IntCsfDiscreteVolume ClassImage DiscreteImage} {

  global tcl_platform
  global BrainsConfig

  # Catch this command
  set  outfile [open $CsvFile "w"]


  set date [clock format [clock seconds] -format "%Y-%m-%d_%H:%M"]
  set user $tcl_platform(user)
  set platform $tcl_platform(os)
  set version $BrainsConfig(AutoWorkupVersion)

  puts -nonewline $outfile "$PatientId,$ScanId,BRAINS,$version,$ClassImage,$date,$user,"

  # Write Continuous Measurement Data
  for {set i 0} {$i < [llength $ClassVolumes]} {incr i} {
    set region [lindex [lindex $ClassVolumes $i] 0]
    set csfVolume [lindex [lindex $ClassVolumes $i] 1]
    set gmVolume [lindex [lindex $ClassVolumes $i] 2]
    set wmVolume [lindex [lindex $ClassVolumes $i] 3]
    set vbVolume [lindex [lindex $ClassVolumes $i] 4]
    set otherVolume [lindex [lindex $ClassVolumes $i] 5]
    puts -nonewline $outfile ",$region,$gmVolume,$wmVolume,$csfVolume,$vbVolume,$otherVolume"
  }

  # Write Continuous Measurement Data - Internal CSF
  for {set i 0} {$i < [llength $IntCsfClassVolumes]} {incr i} {
    set region [lindex [lindex $IntCsfClassVolumes $i] 0]
    set csfVolume [lindex [lindex $IntCsfClassVolumes $i] 1]
    set gmVolume [lindex [lindex $IntCsfClassVolumes $i] 2]
    set wmVolume [lindex [lindex $IntCsfClassVolumes $i] 3]
    set vbVolume [lindex [lindex $IntCsfClassVolumes $i] 4]
    set otherVolume [lindex [lindex $IntCsfClassVolumes $i] 5]
    puts -nonewline $outfile ",$region,$gmVolume,$wmVolume,$csfVolume,$vbVolume,$otherVolume"
  }

  # Write Discrete Measurement Data
  for {set i 0} {$i < [llength $DiscreteVolumes]} {incr i} {
    set region [lindex [lindex $DiscreteVolumes $i] 0]
    set csfVolume [lindex [lindex $DiscreteVolumes $i] 1]
    set gmVolume [lindex [lindex $DiscreteVolumes $i] 2]
    set wmVolume [lindex [lindex $DiscreteVolumes $i] 3]
    set vbVolume [lindex [lindex $DiscreteVolumes $i] 4]
    set otherVolume [lindex [lindex $DiscreteVolumes $i] 5]
    puts -nonewline $outfile ",$region,$gmVolume,$wmVolume,$csfVolume,$vbVolume,$otherVolume"
  }

  # Write Discrete Measurement Data - Internal CSF
  for {set i 0} {$i < [llength $IntCsfDiscreteVolume]} {incr i} {
    set region [lindex [lindex $IntCsfDiscreteVolume $i] 0]
    set csfVolume [lindex [lindex $IntCsfDiscreteVolume $i] 1]
    set gmVolume [lindex [lindex $IntCsfDiscreteVolume $i] 2]
    set wmVolume [lindex [lindex $IntCsfDiscreteVolume $i] 3]
    set vbVolume [lindex [lindex $IntCsfDiscreteVolume $i] 4]
    set otherVolume [lindex [lindex $IntCsfDiscreteVolume $i] 5]
    puts -nonewline $outfile ",$region,$gmVolume,$wmVolume,$csfVolume,$vbVolume,$otherVolume"
  }

  puts $outfile
  close $outfile

  return 1
}

proc WriteHTMLMeasurementFile {HtmlFile PatientId ScanId ClassVolumes IntCsfClassVolumes
                             DiscreteVolumes IntCsfDiscreteVolume ClassImage DiscreteImage} {

  global tcl_platform
  global BrainsConfig

  # Catch this command
  set  outfile [open $HtmlFile "w"]


  set date [clock format [clock seconds] -format "%Y-%m-%d_%H:%M"]
  set user $tcl_platform(user)
  set platform $tcl_platform(os)
  set version $BrainsConfig(AutoWorkupVersion)

  close $outfile

  return 1
}


# VAM - Need to replace BRAINS2 code Here
proc fillInternalMask {binaryImage} {

  set brainsImage [Brains::itkUtils::convertItkImageToBrainsImage $binaryImage]
  set brainsMask [b2 threshold image $brainsImage 1]

  set Xroi [b2 convert mask to roi x $brainsMask name= doSagittal]
  set XId [b2 convert roi to mask $Xroi name= doSagittal]
  set Yroi [b2 convert mask to roi y $brainsMask name= doAxial]
  set YId [b2 convert roi to mask $Yroi name= doAxial]
  set Zroi [b2 convert mask to roi z $brainsMask name= doCoronal]
  set ZId [b2 convert roi to mask $Zroi name= doCoronal]

  # Shouldn't this substitute for fill internal be an AND, not an OR?
  set filledId [b2 or masks ${XId} ${YId} ${ZId}]
  set filledBrainsImage [b2 sum masks $filledId]
  set filledMask [Brains::itkUtils::convertBrainsImageToItkImage $filledBrainsImage]

  b2 destroy roi $Xroi
  b2 destroy mask $XId
  b2 destroy roi $Yroi
  b2 destroy mask $YId
  b2 destroy roi $Zroi
  b2 destroy mask $ZId
  b2 destroy mask $filledId
  b2 destroy mask $brainsMask
  b2 destroy image $brainsImage
  b2 destroy image $filledBrainsImage

  $filledMask SetDirection [$binaryImage GetDirection]

  return $filledMask
}


package require BrainsGlue

ClassTalairachVolumes [lindex $argv 0] [lindex $argv 1] [lindex $argv 2] [lindex $argv 3] [lindex $argv 4] [lindex $argv 5] [lindex $argv6] [lindex $argv 7]
