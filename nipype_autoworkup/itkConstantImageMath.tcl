proc itkConstantImageMath {inFilename fileMode value operation outFilename} {

  package require BrainsGlue

  set inImage [Brains::itk::LoadImage $inFilename $fileMode]
  set outImage [Brains::itk::ConstantImageMath $inImage $value $operation]
  Brains::itk::SaveImage $outImage $outFilename
}

itkConstantImageMath [lindex $argv 0] [lindex $argv 1] [lindex $argv 2] [lindex $argv 3] [lindex $argv 4]

