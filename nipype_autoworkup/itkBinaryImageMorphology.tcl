proc itkObjectMorphology {inFilename fileMode var1 var2 radius outFilename} {

  package require BrainsGlue

  set inImage [Brains::itk::LoadImage $inFilename $fileMode]
  set outImage [Brains::itk::ObjectMorphology $inImage $var1 $var2 [split $radius ,] ]
  Brains::itk::SaveImage $outImage $outFilename
}

itkObjectMorphology [lindex $argv 0] [lindex $argv 1] [lindex $argv 2] [lindex $argv 3] [lindex $argv 4] [lindex $argv 5]

