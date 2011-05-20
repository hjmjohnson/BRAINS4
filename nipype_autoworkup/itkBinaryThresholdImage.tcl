proc itkBinaryThresholdImage {inFilename fileMode min max outFilename} {

  package require BrainsGlue

  set inImage [Brains::itk::LoadImage $inFilename $fileMode]
  set outImage [Brains::itk::BinaryThresholdImage $inImage $min $max]
  Brains::itk::SaveImage $outImage $outFilename
}

itkBinaryThresholdImage [lindex $argv 0] [lindex $argv 1] [lindex $argv 2] [lindex $argv 3] [lindex $argv 4]

