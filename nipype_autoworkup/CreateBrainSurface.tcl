
    ##############################################################################
    # Create Surfaces for the left and right Hemisphere Separately
    ##############################################################################
    proc CreateBrainSurface {BrainMaskFile WarpedCerebellumFile HemisphereMaskFile TissueClassFile \
                             OutputImageFilename OutputSurfaceFilename} {

      if {[Brains::Utils::CheckOutputsNewer \
                 [list $OutputImageFilename $OutputSurfaceFilename ] \
                 [list $BrainMaskFile $WarpedCerebellumFile $HemisphereMaskFile $TissueClassFile ] \
          ] == false } {
        set cerebellumMask [Brains::itk::LoadImage $WarpedCerebellumFile "Signed-16bit"]
        set notWarpedCerebellum [Brains::itk::NotImage $cerebellumMask]
        $cerebellumMask Delete

        set brainMask [Brains::itk::LoadImage $BrainMaskFile "Signed-16bit"]
        set hemisphereMask [Brains::itk::LoadImage $HemisphereMaskFile "Signed-16bit"]
        set tmpInclusionRegion [Brains::itk::AndImage $hemisphereMask $brainMask]
        $brainMask Delete
        $hemisphereMask Delete

        set clippedRegion [Brains::itk::AndImage $tmpInclusionRegion $notWarpedCerebellum]
        $notWarpedCerebellum Delete
        $tmpInclusionRegion Delete

        set classImage [Brains::itk::LoadImage $TissueClassFile "Signed-16bit"]
        set surfaceImage [Brains::itk::MaskImage  $classImage $clippedRegion]
        $classImage Delete
        $clippedRegion Delete

        Brains::itk::SaveImage $surfaceImage $OutputImageFilename

        set surfaceValue 130
        set depthValue 190
        set highValue 255
        set contourValue 0.5
        set maxRMSError 0.005
        set targetReduction 0.50
        set numIterations 50
        set passBand 0.1
        set maxDepth 4.0
        set antiAliasFlag 1
        set measureDepth 1
        set measureCurvature 1
        set preserveTopology 1
        set boundarySmoothing 1
        set featureEdgeSmoothing 1
        set normalizedCoordinates 1
        set boundarySmoothing 1
        set keepLargestConnected 1

        Brains::External::runBrainsCortex $OutputImageFilename $OutputSurfaceFilename $surfaceValue $depthValue $highValue \
            $contourValue $maxRMSError $targetReduction $numIterations $passBand $maxDepth $antiAliasFlag \
            $measureDepth $measureCurvature $preserveTopology $boundarySmoothing $normalizedCoordinates $boundarySmoothing \
            $keepLargestConnected
      }
      return [list $OutputImageFilename $OutputSurfaceFilename]
    }

    ##############################################################################
    # Create the brain surface to estimate both curvature and cortical depth
    ##############################################################################
    proc runBrainsCortex {ImageFile OutputSurface {SurfaceValue 130} {DepthValue 190} {HighValue 255} \
        {ContourValue 0.5} {MaxRMSError 0.005} {TargetReduction 0.9999} {NumIterations 50} {PassBand 0.1} \
        {MaxDepth 4.0} {AntiAliasFlag 1} {MeasureDepth 1} {MeasureCurvature 1} {PreserveTopology 1} \
        {BoundarySmoothing 1} {FeatureEdgeSmoothing 1} {NormalizeCoordinates 1} {KeepLargestConnected 1}} {

      if {[Brains::Utils::CheckOutputsNewer $OutputSurface $ImageFile] == false } {
        set command "exec [file dirname [info nameofexecutable]]/BRAINSMarchingCubes"
        append command " --inputFile $ImageFile"
        append command " --outputSurface $OutputSurface"
        append command " --surfaceValue $SurfaceValue"
        append command " --depthSurfaceValue $DepthValue"
        append command " --maxSurfaceValue $HighValue"
        append command " --contourValue $ContourValue"
        append command " --maxRMSError $MaxRMSError"
        append command " --targetReduction $TargetReduction"
        append command " --numIterations $NumIterations"
        append command " --passBand $PassBand"
        append command " --maxDepth $MaxDepth"
        if {$PreserveTopology} {append command " --preserveTopology"}
        if {$AntiAliasFlag} {append command " --antiAlias"}
        if {$MeasureCurvature} {append command " --measureCurvature"}
        if {$MeasureDepth} {append command " --measureDepth"}

        if {$BoundarySmoothing} {append command " --boundarySmoothing"}
        if {$FeatureEdgeSmoothing} {append command " --featureEdgeSmoothing"}
        if {$NormalizeCoordinates} {append command " --normalizeCoordinates"}
        if {$KeepLargestConnected} {append command " --largestConnected"}

        ###VAM - DEBUG
        # Write out depth surface for comparison
        #
        #append command " --writeDepthSurface"
        #append command " --outputDepthSurface [file rootname $OutputSurface]_190.vtk"

        append command "  >&@stdout"

        puts "BRAINSMarchingCubes command: ${command}"
        if { [catch {eval ${command}} PrintTypeScript] } {
          puts "Error: $PrintTypeScript"
          return 1
        }
      }
      return 0
  }


package require BrainsGlue

CreateBrainSurface [lindex $argv 0] [lindex $argv 1] [lindex $argv 2] [lindex $argv 3] [lindex $argv 4] [lindex $argv 5]

