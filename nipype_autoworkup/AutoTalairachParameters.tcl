    proc AutoTalairachParameters {ACPCLandmarkFile BrainMask TalairachBoxFile TalairachGridFile} {

      if {[Brains::Utils::CheckOutputsNewer [list $TalairachBoxFile $TalairachGridFile] \
                              [list $ACPCLandmarkFile $BrainMask]] == false } {


        if { [catch {open $ACPCLandmarkFile} landFile] } {
          puts "Error: Failed to read file $ACPCLandmarkFile"
          return 1
        }

        for {set i 0} {$i < 10} {incr i} {
           gets $landFile line
        }

        if { [eof $landFile] } {
          puts "Error: Invalid Slicer AC-PC landmark file"
          return 1
        }

        gets $landFile RPline
        gets $landFile ACline
        gets $landFile PCline

        close $landFile

        set tmpLine [split $RPline ","]
        set RPx [lindex $tmpLine 1]
        set RPy [lindex $tmpLine 2]
        set RPz [lindex $tmpLine 3]

        set tmpLine [split $ACline ","]
        set ACx [lindex $tmpLine 1]
        set ACy [lindex $tmpLine 2]
        set ACz [lindex $tmpLine 3]

        set tmpLine [split $PCline ","]
        set PCx [lindex $tmpLine 1]
        set PCy [lindex $tmpLine 2]
        set PCz [lindex $tmpLine 3]

        puts "RP: $RPx $RPy $RPz"
        puts "AC: $ACx $ACy $ACz"
        puts "PC: $PCx $PCy $PCz"

        # Possibly move this to BRAINSABC section of code
        set MaskImage [Brains::itk::LoadImage ${BrainMask} Unsigned-8bit]
        #set radius [list 2 2 2]
        #set errodeImage [Brains::itk::BinaryImageMorphology $MaskImage Erode Ball $radius]
        #set largestRegion [Brains::itk::RelabelComponentImage $errodeImage 30000]
        #set radius [list 4 4 4]
        #set dilateImage [Brains::itk::BinaryImageMorphology $MaskImage Dilate Ball $radius]
        #set searchMask [Brains::itk::AndImage $MaskImage $dilateImage]

        set imageRegion [$MaskImage GetLargestPossibleRegion]
        set imageSize [$imageRegion GetSize]
        set imageIndex [$imageRegion GetIndex]
        set zIndex [$imageIndex GetElement 1]
        set zSize [$imageSize GetElement 1]
        set anteriorIndex 0
        #Need to update to account for voxel size
        #  Previous value was 19 changed to 25
        set anteriorSize [expr $zSize/2 + 25 ]
        $imageSize SetElement 1 $anteriorSize
        $imageIndex SetElement 1 $anteriorIndex
        $imageRegion SetSize $imageSize
        $imageRegion SetIndex $imageIndex

        set clipImage [Brains::itk::RegionOfInterestImage $MaskImage $imageRegion]

        set statsImageFilter [itkBrainsLabelStatisticsImageFilterIUC3IUC3_New]
        $statsImageFilter SetInput $clipImage
        $statsImageFilter SetLabelInput $clipImage
        $statsImageFilter Update
        set clipXupper [$statsImageFilter GetBoundingBoxUpperBound 1 0]
        set clipYupper [$statsImageFilter GetBoundingBoxUpperBound 1 1]
        set clipZupper [$statsImageFilter GetBoundingBoxUpperBound 1 2]
        set clipXlower [$statsImageFilter GetBoundingBoxLowerBound 1 0]
        set clipYlower [$statsImageFilter GetBoundingBoxLowerBound 1 1]
        set clipZlower [$statsImageFilter GetBoundingBoxLowerBound 1 2]
        puts "***************************************************"
        puts "Clip Box"
        puts "Max $clipXupper $clipYupper $clipZupper"
        puts "Min $clipXlower $clipYlower $clipZlower"
        puts "***************************************************"
        $statsImageFilter SetInput $MaskImage
        $statsImageFilter SetLabelInput $MaskImage
        $statsImageFilter Update
        set fullXupper [$statsImageFilter GetBoundingBoxUpperBound 1 0]
        set fullYupper [$statsImageFilter GetBoundingBoxUpperBound 1 1]
        set fullZupper [$statsImageFilter GetBoundingBoxUpperBound 1 2]
        set fullXlower [$statsImageFilter GetBoundingBoxLowerBound 1 0]
        set fullYlower [$statsImageFilter GetBoundingBoxLowerBound 1 1]
        set fullZlower [$statsImageFilter GetBoundingBoxLowerBound 1 2]
        puts "***************************************************"
        puts "Full Box"
        puts "Max $fullXupper $fullYupper $fullZupper"
        puts "Min $fullXlower $fullYlower $fullZlower"
        puts "***************************************************"

        set irp [list $clipXlower $clipYlower $clipZlower]
        set sla [list $fullXupper $fullYupper $fullZupper]
        # Force AC-PC X and Z to be the same value
        set ac  [list [expr -1 * $ACx] [expr -1 * $ACy] $ACz]
        set pc  [list [expr -1 * $ACx] [expr -1 * $PCy] $ACz]

        #
        # Create Talairach Parameters
        #
        Brains::External::runCreateTalairachParameters $BrainMask $ac $pc $sla $irp $TalairachBoxFile $TalairachGridFile

        #
        # Clean up memory
        #
        $MaskImage Delete
        #$errodeImage Delete
        #$largestRegion Delete
        #$dilateImage Delete
        #$searchMask Delete
        $clipImage Delete
        $statsImageFilter Delete

      }
    }


package require BrainsGlue

AutoTalairachParameters [lindex $argv 0] [lindex $argv 1] [lindex $argv 2] [lindex $argv 3]

