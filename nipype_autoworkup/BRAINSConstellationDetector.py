from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec, File, Directory, traits, isdefined, InputMultiPath, OutputMultiPath
import os

class BRAINSConstellationDetectorInputSpec(CommandLineInputSpec):
    houghEyeDetectorMode = traits.Int( argstr = "--houghEyeDetectorMode %d")
    inputTemplateModel = File( exists = True,argstr = "--inputTemplateModel %s")
    inputLLSModel = File( exists = True,argstr = "--inputLLSModel %s")
    inputEPCAModelMat = File( exists = True,argstr = "--inputEPCAModelMat %s")
    inputEPCAModelTxt = File( exists = True,argstr = "--inputEPCAModelTxt %s")
    inputVolume = File( exists = True,argstr = "--inputVolume %s")
    outputVolume = traits.Either(traits.Bool, File(), argstr = "--outputVolume %s")
    outputResampledVolume = traits.Either(traits.Bool, File(), argstr = "--outputResampledVolume %s")
    outputTransform = traits.Either(traits.Bool, File(), argstr = "--outputTransform %s")
    outputLandmarksInInputSpace = traits.Either(traits.Bool, File(), argstr = "--outputLandmarksInInputSpace %s")
    outputLandmarksInACPCAlignedSpace = traits.Either(traits.Bool, File(), argstr = "--outputLandmarksInACPCAlignedSpace %s")
    inputLandmarksPaired = File( exists = True,argstr = "--inputLandmarksPaired %s")
    outputLandmarksPaired = traits.Either(traits.Bool, File(), argstr = "--outputLandmarksPaired %s")
    outputMRML = traits.Either(traits.Bool, File(), argstr = "--outputMRML %s")
    outputVerificationScript = traits.Either(traits.Bool, File(), argstr = "--outputVerificationScript %s")
    mspQualityLevel = traits.Int( argstr = "--mspQualityLevel %d")
    otsuPercentileThreshold = traits.Float( argstr = "--otsuPercentileThreshold %f")
    acLowerBound = traits.Float( argstr = "--acLowerBound %f")
    cutOutHeadInOutputVolume = traits.Bool( argstr = "--cutOutHeadInOutputVolume ")
    outputUntransformedClippedVolume = traits.Either(traits.Bool, File(), argstr = "--outputUntransformedClippedVolume %s")
    rescaleIntensities = traits.Bool( argstr = "--rescaleIntensities ")
    trimRescaledIntensities = traits.Float( argstr = "--trimRescaledIntensities %f")
    rescaleIntensitiesOutputRange = InputMultiPath(traits.Int, sep = ",",argstr = "--rescaleIntensitiesOutputRange %s")
    backgroundFillValueString = traits.Str( argstr = "--BackgroundFillValue %s")
    interpolationMode = traits.Enum("NearestNeighbor","Linear","ResampleInPlace","BSpline","WindowedSinc", argstr = "--interpolationMode %s")
    forceACPoint = InputMultiPath(traits.Float, sep = ",",argstr = "--forceACPoint %s")
    forcePCPoint = InputMultiPath(traits.Float, sep = ",",argstr = "--forcePCPoint %s")
    forceVN4Point = InputMultiPath(traits.Float, sep = ",",argstr = "--forceVN4Point %s")
    forceRPPoint = InputMultiPath(traits.Float, sep = ",",argstr = "--forceRPPoint %s")
    inputLandmarksEMSP = File( exists = True,argstr = "--inputLandmarksEMSP %s")
    forceHoughEyeDetectorReportFailure = traits.Bool( argstr = "--forceHoughEyeDetectorReportFailure ")
    radiusMPJ = traits.Float( argstr = "--rmpj %f")
    radiusAC = traits.Float( argstr = "--rac %f")
    radiusPC = traits.Float( argstr = "--rpc %f")
    radiusVN4 = traits.Float( argstr = "--rVN4 %f")
    debug = traits.Bool( argstr = "--debug ")
    verbose = traits.Bool( argstr = "--verbose ")
    writeBranded2DImage = traits.Either(traits.Bool, File(), argstr = "--writeBranded2DImage %s")
    resultsDir = traits.Either(traits.Bool, File(), argstr = "--resultsDir %s")
    writedebuggingImagesLevel = traits.Int( argstr = "--writedebuggingImagesLevel %d")


class BRAINSConstellationDetectorOutputSpec(TraitedSpec):
    outputVolume = File( exists = True)
    outputResampledVolume = File( exists = True)
    outputTransform = File( exists = True)
    outputLandmarksInInputSpace = File( exists = True)
    outputLandmarksInACPCAlignedSpace = File( exists = True)
    outputLandmarksPaired = File( exists = True)
    outputMRML = File( exists = True)
    outputVerificationScript = File( exists = True)
    outputUntransformedClippedVolume = File( exists = True)
    writeBranded2DImage = File( exists = True)
    resultsDir = File( exists = True)


class BRAINSConstellationDetector(CommandLine):

    input_spec = BRAINSConstellationDetectorInputSpec
    output_spec = BRAINSConstellationDetectorOutputSpec
    _cmd = " BRAINSConstellationDetector "
    _outputs_filenames = {'outputVolume':'outputVolume.nii.gz','outputResampledVolume':'outputResampledVolume.nii.gz','outputMRML':'outputMRML.mrml','outputLandmarksPaired':'outputLandmarksPaired.fcsv','resultsDir':'resultsDir','outputTransform':'outputTransform.mat','writeBranded2DImage':'writeBranded2DImage.png','outputLandmarksInACPCAlignedSpace':'outputLandmarksInACPCAlignedSpace.fcsv','outputLandmarksInInputSpace':'outputLandmarksInInputSpace.fcsv','outputUntransformedClippedVolume':'outputUntransformedClippedVolume.nii.gz','outputVerificationScript':'outputVerificationScript.sh'}

    def _list_outputs(self):
        outputs = self.output_spec().get()
        for name in outputs.keys():
            coresponding_input = getattr(self.inputs, name)
            if isdefined(coresponding_input):
                if isinstance(coresponding_input, bool) and coresponding_input == True:
                    outputs[name] = os.path.abspath(self._outputs_filenames[name])
                else:
                    if isinstance(coresponding_input, list):
                        outputs[name] = [os.path.abspath(inp) for inp in coresponding_input]
                    else:
                        outputs[name] = os.path.abspath(coresponding_input)
        return outputs

    def _format_arg(self, name, spec, value):
        if name in self._outputs_filenames.keys():
            if isinstance(value, bool):
                if value == True:
                    value = os.path.abspath(self._outputs_filenames[name])
                else:
                    return ""
        return super(BRAINSConstellationDetector, self)._format_arg(name, spec, value)

