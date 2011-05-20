proc itkObjectMorphology {inFilename fileMode var1 var2 radius var3 outFilename} {

  package require BrainsGlue

  set inImage [Brains::itk::LoadImage $inFilename $fileMode]
  set outImage [Brains::itk::ObjectMorphology $inImage $var1 $var2 [split $radius ,] $var3]
  Brains::itk::SaveImage $outImage $outFilename
}

itkObjectMorphology [lindex $argv 0] [lindex $argv 1] [lindex $argv 2] [lindex $argv 3] [lindex $argv 4] [lindex $argv 5] [lindex $argv 6]

