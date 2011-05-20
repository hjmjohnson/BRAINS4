proc itkAndImage {inFilename1 inFilename2 fileMode outFilename} {

  package require BrainsGlue

  set inImage1 [Brains::itk::LoadImage $inFilename1 $fileMode]
  set inImage2 [Brains::itk::LoadImage $inFilename2 $fileMode]
  set outImage [Brains::itk::AndImage $inImage1 $inImage2]
  Brains::itk::SaveImage $outImage $outFilename
}

itkAndImage [lindex $argv 0] [lindex $argv 1] [lindex $argv 2] [lindex $argv 3]

