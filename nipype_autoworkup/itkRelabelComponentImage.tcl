proc itkRelabelComponentImage {inFilename fileMode val outFilename} {

  package require BrainsGlue

  set inImage [Brains::itk::LoadImage $inFilename $fileMode]
  set outImage [Brains::itk::RelabelComponentImage $inImage $val]
  Brains::itk::SaveImage $outImage $outFilename
}

itkRelabelComponentImage [lindex $argv 0] [lindex $argv 1] [lindex $argv 2] [lindex $argv 3]

