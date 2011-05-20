    ##############################################################################
    # Pick examples of blood given an initial estimate of the class labels
    # and the brain mask.
    ##############################################################################
    proc PickBloodPlugsFromMargin { BrainMaskFile T1File T2File PDFile EmsLabelImage VbPlugFile} {
      if {[Brains::Utils::CheckOutputsNewer [list $VbPlugFile] \
                              [list $BrainMaskFile $T1File $T2File $PDFile $EmsLabelImage]] == false } {
        set wmLabel 1
        set gmLabel 2
        set csfLabel 4

        # Load Masks
        set BrainMask [Brains::itk::LoadImage $BrainMaskFile Unsigned-8bit]
        set ClassLabels [Brains::itk::LoadImage $EmsLabelImage Unsigned-8bit]

        # Load Images
        set T1 [Brains::itk::LoadImage $T1File Unsigned-8bit]

        if { ${T2File} != "." } {
          set T2 [Brains::itk::LoadImage $T2File Unsigned-8bit]
        }

        if { ${PDFile} != "." } {
          set PD [Brains::itk::LoadImage $PDFile Unsigned-8bit]
        }

        # Select Initial VB estimate as search space
        #set marginMask [Brains::itk::BinaryThresholdImage $ClassLabels 5 5]
        set greyMask [Brains::itk::BinaryThresholdImage $ClassLabels $gmLabel $gmLabel]
        set dilateSize [list 3 3 3]
        set dilateMask [Brains::itk::BinaryImageMorphology $greyMask Dilate Ball $dilateSize]
        set marginMask [Brains::itk::XorImage $greyMask $dilateMask]

        # Debug File - Used to check blood search region
        # Brains::itk::SaveImage $marginMask [file dirname $BrainMaskFile]/marginRegion.nii.gz

        if { $T2File != "." } {
          set classT1Measures [Brains::itk::measureLabelImageStatistics $ClassLabels $T1]
          set csfT1Mean [lindex [lindex [lindex $classT1Measures [expr $csfLabel - 1]] 1] 2]
          set gmT1Mean [lindex [lindex [lindex $classT1Measures [expr $gmLabel - 1]] 1] 2]
          set bloodT1LowerBound [expr round(0.65 * $gmT1Mean )]
          #set bloodT1LowerBound [expr round(0.3 * $csfT1Mean )]
          set bloodT1UpperBound [expr round(0.8 * $gmT1Mean )]
          set t1ThreshMask [Brains::itk::BinaryThresholdImage $T1 $bloodT1LowerBound $bloodT1UpperBound]
          set partialVbMask [Brains::itk::AndImage $t1ThreshMask $marginMask]
          $t1ThreshMask Delete

          set classT2Measures [Brains::itk::measureLabelImageStatistics $ClassLabels $T2]
          set gmT2Mean [lindex [lindex [lindex $classT2Measures [expr $gmLabel - 1]] 1] 2]
          set bloodT2LowerBound [expr round(0.0 * $gmT2Mean )]
          set bloodT2UpperBound [expr round(0.2 * $gmT2Mean )]
          set t2ThreshMask [Brains::itk::BinaryThresholdImage $T2 $bloodT2LowerBound $bloodT2UpperBound]
          set multiVbMask [Brains::itk::AndImage $partialVbMask $t2ThreshMask]
          $t2ThreshMask Delete
          $partialVbMask Delete


          if { $PDFile == "." } {
            set vbMask $multiVbMask
          } else {
            set classPDMeasures [Brains::itk::measureLabelImageStatistics $ClassLabels ${PD}]
            set gmPDMean [lindex [lindex [lindex $classPDMeasures [expr $gmLabel - 1]] 1] 2]
            set bloodPDLowerBound [expr round(0.0 * $gmPDMean )]
            set bloodPDUpperBound [expr round(0.2 * $gmPDMean )]
            set pdThreshMask [Brains::itk::BinaryThresholdImage $PD $bloodPDLowerBound $bloodPDUpperBound]
            set vbMask [Brains::itk::AndImage $pdThreshMask $multiVbMask]
            $pdThreshMask Delete
            $multiVbMask Delete
          }

        } else {
          set classT1Measures [Brains::itk::measureLabelImageStatistics $ClassLabels $T1]
          set gmT1Mean [lindex [lindex [lindex $classT1Measures [expr $gmLabel - 1]] 1] 2]
          set bloodT1LowerBound [expr round(0.0 * $gmT1Mean )]
          set bloodT1UpperBound [expr round(0.2 * $gmT1Mean )]
          set t1ThreshMask [Brains::itk::BinaryThresholdImage $T1 $bloodT1LowerBound $bloodT1UpperBound]
          set vbMask [Brains::itk::AndImage $t1ThreshMask $marginMask]
        }

        Brains::itk::SaveImage $vbMask $VbPlugFile

        $marginMask Delete
        $vbMask Delete
      }

      return 0
    }


package require BrainsGlue

PickBloodPlugsFromMargin [lindex $argv 0] [lindex $argv 1] [lindex $argv 2] [lindex $argv 3] [lindex $argv 4] [lindex $argv 5]
