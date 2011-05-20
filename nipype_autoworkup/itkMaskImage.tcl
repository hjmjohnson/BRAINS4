proc itkMaskImage {inImageFilename inMaskFilename fileMode outFilename} {

  package require BrainsGlue

  set inImage [Brains::itk::LoadImage $inImageFilename $fileMode]
  set inMask [Brains::itk::LoadImage $inMaskFilename $fileMode]
  set outImage [Brains::itk::MaskImage $inImage $inMask]
  Brains::itk::SaveImage $outImage $outFilename
}

itkMaskImage [lindex $argv 0] [lindex $argv 1] [lindex $argv 2] [lindex $argv 3]

