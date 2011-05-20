  # Brains::Gtract::DtiSkullStripB0 --
  #
  #  Procedure to perform skull stripping for EPI scans. Simple algorithm
  #  that will threshold-> Erode -> Dilate -> And with original estimate
  #
  proc DtiSkullStripB0 {B0File ClippedB0File {Threshold 100} {ErodeSize 1} {DilateSize 3}} {
    if {[Brains::Utils::CheckOutputsNewer \
            [list $ClippedB0File] \
            [list $B0File]
        ] == false } {
      set b0 [Brains::itk::LoadImage $B0File "Signed-16bit"]
      set thresholdMask [Brains::itk::BinaryThresholdImage $b0 $Threshold 4095]
      set erodeMask [Brains::itk::ObjectMorphology $thresholdMask Erode Box [list $ErodeSize $ErodeSize 0] 1]
      set dilateMask [Brains::itk::ObjectMorphology $erodeMask Dilate Box [list $DilateSize $DilateSize 0] 1]
      $erodeMask Delete
      set componentMask [Brains::itk::ConnectedComponentImage $dilateMask 0 "Signed-16bit"]
      $dilateMask Delete
      set brainRegionMask [Brains::itk::RelabelComponentImage $componentMask 1000]
      $componentMask Delete
      set brainMask [Brains::itk::AndImage $brainRegionMask $thresholdMask]
      $brainRegionMask Delete
      $thresholdMask Delete
      set clippedB0 [Brains::itk::MaskImage $b0 $brainMask]
      $b0 Delete
      $brainMask Delete
      Brains::itk::SaveImage $clippedB0 $ClippedB0File
      $clippedB0 Delete
    }
  }

package require BrainsGlue

DtiSkullStripB0 [lindex $argv 0] [lindex $argv 1] [lindex $argv 2] [lindex $argv 3]
