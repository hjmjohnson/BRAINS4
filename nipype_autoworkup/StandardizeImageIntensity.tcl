
    ##############################################################################
    # This function will rescale T1 image intensities from a broad array of
    # dynamic ranges into a consistent dynamic range based on an estimate
    # of WM intensities. The main purpose is as a pre-processing step to deal
    # with raw scanner images that may appear to be very bright or very dark
    # due to a few outlier pixels those outlier pixels adversly affect the
    # contrast when the image is put into an 8-bit image space.
    ##############################################################################
    proc StandardizeImageIntensity { ImageFilename BrainLabelImageFilename ResultImageFilename {MinLabel 1} {MaxLabel 255}} {

      if {[Brains::Utils::CheckOutputsNewer [list $ResultImageFilename] \
                              [list $ImageFilename $BrainLabelImageFilename]] == false } {

        # Create the mask
        set brainLabelImage [Brains::itk::LoadImage $BrainLabelImageFilename "Unsigned-8bit"]
        set brainTissueMask [Brains::itk::BinaryThresholdImage $brainLabelImage $MinLabel $MaxLabel]
        set image [Brains::itk::LoadImage $ImageFilename "Float-Single" ]

        set result [AutoStandardizeMaskIntensity $image $brainTissueMask]

        Brains::itk::SaveImage $result $ResultImageFilename

        # Clean Up Memory
        ${brainLabelImage} Delete
        ${brainTissueMask} Delete
        ${image} Delete
        ${result} Delete
      }
    }


    # Brains::AutoWorkup::AutoStandardizeMaskIntensity --
    #
    #  This function will rescale image intensities from
    #  a broad array of dynamic ranges into a consistent
    #  dynamic range based on image statistics. The main
    #  purpose is as a brightening step to deal with bias
    #  field corrected raw scanner images that may appear
    #  to be very bright or very dark due to a few outlier
    #  pixels, those outlier pixels adversly affect the contrast.
    #
    # Arguments:
    #  image       - Input T1 weighted image
    #  mask        - Estimate of the brain mask
    #
    # Results:
    #  Returns the resulting rescaled T1 weighted image

    proc AutoStandardizeMaskIntensity { image mask } {

      set maskedImage [Brains::itk::MaskImage $image $mask]

      set imageMax [Brains::itkUtils::GetImageMax $maskedImage]
      set imageMin [Brains::itkUtils::GetImageMin $maskedImage]

      set tailFraction 0.0005
      set topValue [ItkPercentileMaskedIntensity ${image} ${mask} [expr 1.0 - ${tailFraction}] ]
      set bottomValue [ItkPercentileMaskedIntensity ${image} ${mask} ${tailFraction} ]

      puts "Window Min: $bottomValue"
      puts "Window Max: $topValue"
      puts "Image Min: $imageMin"
      puts "Image Max: $imageMax"

      set rescaled [Brains::itk::IntensityWindowingImage $image 0 255.0 $bottomValue $topValue]
      set castImage [Brains::itk::CastImage $rescaled "Unsigned-8bit" ]

      $maskedImage Delete
      $rescaled Delete

      return $castImage
    }



    # Brains::AutoWorkup::ItkPercentileMaskedIntensity --
    #
    #  This function meets the need of finding the image
    #  median within the brain mask. Optional parameters
    #  reflect the algorithm's generality with respect to
    #  percentile and precision.  This algorithm does not
    #  interpolate within the failing bin, nor should it.
    #
    # Arguments:
    #  image       - Input T1 weighted image
    #  mask        - Estimate of the brain mask
    #  percent     - Percentile for signal intensity estimate
    #  numBins     - Number of bins considered for the estimate
    #
    # Results:
    #  Returns the resulting percentile intensity

    proc ItkPercentileMaskedIntensity { image mask {percent 0.50} {numBins 100} } {

      set maskedImage [Brains::itk::MaskImage $image $mask]

      set inputType [Brains::itkUtils::getItkImageType $maskedImage]
      if {$inputType == "Unsupported"} {
        error "Error in ItkPercentileMaskedIntensity: Invalid image data type. Support Unsigned-8bit, Signed-16bit, Unsigned-16bit, and Float-single."
      }

      set histogramFilter [itkBrainsScalarImageToHistogramGeneratorI${inputType}_New]
      $histogramFilter SetInputImage $maskedImage
      $histogramFilter SetNumberOfBins 32768
      $histogramFilter SetMarginalScale 1.0
      $histogramFilter SetHistogramMin 0.0
      $histogramFilter SetHistogramMax 32767.0
      $histogramFilter Update

      set size [expr [$histogramFilter GetTotalFrequency] - [$histogramFilter GetFrequency 0]]
      set percentile [expr ${size} * ${percent}]

      set sum 0.0
      for {set i 1} {$i < 32768} {incr i} {
          #puts "$i $size $percentile : $sum"
          set sum [expr ${sum} + [$histogramFilter GetFrequency $i]]
          if {${sum} >= ${percentile}} {
              break
          }
      }

      $histogramFilter Delete
      $maskedImage Delete

      # Return the lower bound of the failing percentile interval.
      return $i
    }


package require BrainsGlue

StandardizeImageIntensity [lindex $argv 0] [lindex $argv 1] [lindex $argv 2] [lindex $argv 3] [lindex $argv 4]
