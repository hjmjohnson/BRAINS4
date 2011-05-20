proc itkComputeImageMean {imageList outFilename} {

  package require BrainsGlue

  if {[llength $imageList] > 1} {
    foreach i $imageList {
      lappend imageList [Brains::itk::LoadImage $i "Signed-16bit"]
    }
    set meanImage [Brains::itk::ComputeImageMean $imageList]

    Brains::itk::SaveImage $meanImage $outFilename
    $meanImage Delete
  } else {
    file copy -force [lindex $imageList 0] $outFilename
  }
}

itkComputeImageMean [lrange $argv 0 end-1] [lindex $argv end]
