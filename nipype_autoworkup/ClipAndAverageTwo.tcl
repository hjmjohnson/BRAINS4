
##############################################################################
# ClipAndAverage for two lists
##############################################################################
proc ClipAndAverageTwo {ActiveImagesToDefineClipMask PassiveImagesToClip OutputAverageOfActiveImages OutputAverageOfPassiveImages} {

  if {[Brains::Utils::CheckOutputsNewer [list $OutputAverageOfActiveImages $OutputAverageOfPassiveImages] \
                          [concat $ActiveImagesToDefineClipMask $PassiveImagesToClip]] == false } {

      foreach inputFileName [concat $ActiveImagesToDefineClipMask] {
          set maskFileName [file dirname ${inputFileName}]/roiAuto_[file tail ${inputFileName}]
          set closingSize 12
          set otsuPercentileThreshold 0.01
          Brains::External::runMaskROIAUTO ${inputFileName} ${maskFileName} ${closingSize} ${otsuPercentileThreshold}
          lappend MaskFileNames ${maskFileName}
      }

      set clippingFileName [file dirname [lindex ${MaskFileNames} 0]]/clip_for_[file tail ${OutputAverageOfActiveImages}]

      Brains::itk::ImageFileListAccumulate $MaskFileNames $clippingFileName Minimum Signed-16bit 32767
      foreach inputFileName $ActiveImagesToDefineClipMask {
          set clippedFileName [file dirname ${inputFileName}]/clipped_[file tail ${inputFileName}]
          Brains::itk::ImageFileListAccumulate [list ${inputFileName} ${clippingFileName}] ${clippedFileName} Multiply Float-Single 32767
          lappend ClippedActiveImagesToDefineClipMask ${clippedFileName}
      }
      Brains::itk::ImageFileListAccumulate $ClippedActiveImagesToDefineClipMask $OutputAverageOfActiveImages Add Float-Single 32767
      foreach inputFileName $PassiveImagesToClip {
          set clippedFileName [file dirname ${inputFileName}]/clipped_[file tail ${inputFileName}]
          Brains::itk::ImageFileListAccumulate [list ${inputFileName} ${clippingFileName}] ${clippedFileName} Multiply Float-Single 32767
          lappend ClippedPassiveImagesToClip ${clippedFileName}
      }
      Brains::itk::ImageFileListAccumulate $ClippedPassiveImagesToClip $OutputAverageOfPassiveImages Add Float-Single 32767
  }
  return 0
}

package require BrainsGlue

ClipAndAverageTwo [lindex $argv 0] [lindex $argv 1] [lindex $argv 2] [lindex $argv 3]
