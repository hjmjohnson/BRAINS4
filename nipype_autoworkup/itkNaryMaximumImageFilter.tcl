proc itkNaryMaximumImageFilter {inImageList fileMode outFilename} {

  package require BrainsGlue

  set index 1
  set binaryImageList [list]
  foreach i [ split $inImageList , ] {
      set inputImage [Brains::itk::LoadImage $i $fileMode]
      lappend binaryImageList $inputImage
      incr index
  }
  set resultImage [Brains::itk::NaryMaximumImageFilter $binaryImageList]
  Brains::itk::SaveImage $resultImage $outFilename
  foreach i $binaryImageList {
      $i Delete
  }
}

itkNaryMaximumImageFilter [lindex $argv 0] [lindex $argv 1] [lindex $argv 2]
