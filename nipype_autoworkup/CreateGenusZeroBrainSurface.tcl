  ##############################################################################
  # Create Genus Zero Cortical Surface
  ##############################################################################
  proc CreateGenusZeroBrainSurface { BrainMaskFile WarpedCerebellumFile \
    HemisphereMaskFile TissueClassFile SurfaceImageFilename OutputSurfaceFilename } {

    set cerebellumMask [Brains::itk::LoadImage $WarpedCerebellumFile "Unsigned-8bit"]
    set binaryCerebellum [Brains::itk::BinaryThresholdImage $cerebellumMask 1 255]
    set notCerebellum [Brains::itk::NotImage $binaryCerebellum]
    $cerebellumMask Delete
    $binaryCerebellum Delete

    set brainMask [Brains::itk::LoadImage $BrainMaskFile "Unsigned-8bit"]
    set hemisphereMask [Brains::itk::LoadImage $HemisphereMaskFile "Unsigned-8bit"]
    set binaryBrain [Brains::itk::BinaryThresholdImage $brainMask 1 255]
    set binaryHemisphere [Brains::itk::BinaryThresholdImage $hemisphereMask 1 255]
    $brainMask Delete
    $hemisphereMask Delete

    set hemisphereRegion [Brains::itk::AndImage $binaryHemisphere $binaryBrain]
    $binaryBrain Delete
    $binaryHemisphere Delete

    set clippedRegion [Brains::itk::AndImage $hemisphereRegion $notCerebellum]
    $notCerebellum Delete
    $hemisphereRegion Delete

    set classImage [Brains::itk::LoadImage $TissueClassFile "Unsigned-8bit"]
    set hemisphereClassImage [Brains::itk::MaskImage  $classImage $clippedRegion]
    $classImage Delete
    $clippedRegion Delete

    # Filter Image - Median followed by Anisotropic Diffusion
    set medianSurfaceImage [Brains::itk::MedianImageFilter $hemisphereClassImage]
    $hemisphereClassImage Delete

    set floatSurfaceImage [Brains::itk::CastImage $medianSurfaceImage "Float-single"]
    $medianSurfaceImage Delete

    set filteredSurfaceImage [Brains::itk::GradientAnisotropicDiffusionImageFilter $floatSurfaceImage 0.1 1.0 50]
    $floatSurfaceImage Delete

    # Threshold and Keep the Largest connected region
    set binary190Image [Brains::itk::BinaryThresholdImage $filteredSurfaceImage 190 255 0 "Unsigned-8bit"]
    $filteredSurfaceImage Delete

    set componentImage [Brains::itk::ConnectedComponentImage $binary190Image 0 "Unsigned-8bit"]
    $binary190Image Delete

    set relabelImage [Brains::itk::RelabelComponentImage $componentImage 500]
    $componentImage Delete

    set binaryImage [Brains::itk::BinaryThresholdImage $relabelImage 1 1 0 "Unsigned-8bit"]

    # Save the 190 Binary Image for Surface generation
    Brains::itk::SaveImage $binaryImage $SurfaceImageFilename
    $binaryImage Delete

    if {[file extension $SurfaceImageFilename] == ".gz"} {
      set genus0ImageFilename [file rootname [file rootname $SurfaceImageFilename]]_genus0.nii.gz
    } else {
      set genus0ImageFilename [file rootname $SurfaceImageFilename]_genus0.nii.gz
    }

    Brains::External::runGenusZeroImageFilter $SurfaceImageFilename $genus0ImageFilename $OutputSurfaceFilename

    return [list $SurfaceImageFilename $OutputSurfaceFilename]
  }


package require BrainsGlue

CreateAutoLabelBrainSurface [lindex $argv 0] [lindex $argv 1] [lindex $argv 2] [lindex $argv 3] [lindex $argv 4] [lindex $argv 5]
