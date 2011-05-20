from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.traits import File
from nipype.interfaces.traits import Directory
from nipype.utils.misc import isdefined

class BRAINSConstellationDetectorInputSpec(CommandLineInputSpec):
    houghEyeDetectorMode = traits.Int( argstr = "--houghEyeDetectorMode %d")
    inputTemplateModel = File( exists = "True",argstr = "--inputTemplateModel %s")
    inputLLSModel = File( exists = "True",argstr = "--inputLLSModel %s")
    inputEPCAModelMat = File( exists = "True",argstr = "--inputEPCAModelMat %s")
    inputEPCAModelTxt = File( exists = "True",argstr = "--inputEPCAModelTxt %s")
    inputVolume = File( exists = "True",argstr = "--inputVolume %s")
    outputVolume = traits.Either(traits.Bool, File, argstr = "--outputVolume %s")
    outputResampledVolume = traits.Either(traits.Bool, File, argstr = "--outputResampledVolume %s")
    outputTransform = traits.Either(traits.Bool, File, argstr = "--outputTransform %s")
    outputLandmarksInInputSpace = traits.Either(traits.Bool, File, argstr = "--outputLandmarksInInputSpace %s")
    outputLandmarksInACPCAlignedSpace = traits.Either(traits.Bool, File, argstr = "--outputLandmarksInACPCAlignedSpace %s")
    inputLandmarksPaired = File( exists = "True",argstr = "--inputLandmarksPaired %s")
    outputLandmarksPaired = traits.Either(traits.Bool, File, argstr = "--outputLandmarksPaired %s")
    outputMRML = traits.Either(traits.Bool, File, argstr = "--outputMRML %s")
    outputVerificationScript = traits.Either(traits.Bool, File, argstr = "--outputVerificationScript %s")
    mspQualityLevel = traits.Int( argstr = "--mspQualityLevel %d")
    otsuPercentileThreshold = traits.Float( argstr = "--otsuPercentileThreshold %f")
    acLowerBound = traits.Float( argstr = "--acLowerBound %f")
    cutOutHeadInOutputVolume = traits.Bool( argstr = "--cutOutHeadInOutputVolume ")
    outputUntransformedClippedVolume = traits.Either(traits.Bool, File, argstr = "--outputUntransformedClippedVolume %s")
    rescaleIntensities = traits.Bool( argstr = "--rescaleIntensities ")
    trimRescaledIntensities = traits.Float( argstr = "--trimRescaledIntensities %f")
    rescaleIntensitiesOutputRange = traits.List("traits.Int", sep = ",",argstr = "--rescaleIntensitiesOutputRange %d")
    backgroundFillValueString = traits.Str( argstr = "--BackgroundFillValue %s")
    interpolationMode = traits.Enum("NearestNeighbor","Linear","BSpline","WindowedSinc", argstr = "--interpolationMode %s")
    forceACPoint = traits.List("traits.Float", sep = ",",argstr = "--forceACPoint %f")
    forcePCPoint = traits.List("traits.Float", sep = ",",argstr = "--forcePCPoint %f")
    forceVN4Point = traits.List("traits.Float", sep = ",",argstr = "--forceVN4Point %f")
    forceRPPoint = traits.List("traits.Float", sep = ",",argstr = "--forceRPPoint %f")
    inputLandmarksEMSP = File( exists = "True",argstr = "--inputLandmarksEMSP %s")
    forceHoughEyeDetectorReportFailure = traits.Bool( argstr = "--forceHoughEyeDetectorReportFailure ")
    radiusMPJ = traits.Float( argstr = "--rmpj %f")
    radiusAC = traits.Float( argstr = "--rac %f")
    radiusPC = traits.Float( argstr = "--rpc %f")
    radiusVN4 = traits.Float( argstr = "--rVN4 %f")
    debug = traits.Bool( argstr = "--debug ")
    verbose = traits.Bool( argstr = "--verbose ")
    writeBranded2DImage = traits.Either(traits.Bool, File, argstr = "--writeBranded2DImage %s")
    resultsDir = traits.Either(traits.Bool, traits.Directory, argstr = "--resultsDir %s")
    writedebuggingImagesLevel = traits.Int( argstr = "--writedebuggingImagesLevel %d")


class BRAINSConstellationDetectorOutputSpec(TraitedSpec):
    outputVolume = File(exists=True, argstr = "--outputVolume %s")
    outputResampledVolume = File(exists=True, argstr = "--outputResampledVolume %s")
    outputTransform = File(exists=True, argstr = "--outputTransform %s")
    outputLandmarksInInputSpace = File(exists=True, argstr = "--outputLandmarksInInputSpace %s")
    outputLandmarksInACPCAlignedSpace = File(exists=True, argstr = "--outputLandmarksInACPCAlignedSpace %s")
    outputLandmarksPaired = File(exists=True, argstr = "--outputLandmarksPaired %s")
    outputMRML = File(exists=True, argstr = "--outputMRML %s")
    outputVerificationScript = File(exists=True, argstr = "--outputVerificationScript %s")
    outputUntransformedClippedVolume = File(exists=True, argstr = "--outputUntransformedClippedVolume %s")
    writeBranded2DImage = File(exists=True, argstr = "--writeBranded2DImage %s")
    resultsDir = traits.Directory(exists=True, argstr = "--resultsDir %s")


class BRAINSConstellationDetector(CommandLine):
    input_spec = BRAINSConstellationDetectorInputSpec
    output_spec = BRAINSConstellationDetectorOutputSpec
#    _cmd = "/scratch/brains/BRAINS3-build/src/bin/BRAINSConstellationDetector "
    _cmd = "/raid0/homes/kpease/temp/itkWrapping/BRAINSConstellationDetector.sh "        # Workaround  :P
    _outputs_filenames = {'outputVolume':'outputVolume.nii','outputResampledVolume':'outputResampledVolume.nii','outputMRML':'outputMRML','outputLandmarksPaired':'outputLandmarksPaired','resultsDir':'resultsDir','outputTransform':'outputTransform.mat','writeBranded2DImage':'writeBranded2DImage','outputLandmarksInACPCAlignedSpace':'outputLandmarksInACPCAlignedSpace','outputLandmarksInInputSpace':'outputLandmarksInInputSpace','outputUntransformedClippedVolume':'outputUntransformedClippedVolume.nii','outputVerificationScript':'outputVerificationScript'}

    def _list_outputs(self):
        outputs = self.output_spec().get()
        for name in outputs.keys():
            coresponding_input = getattr(self.inputs, name)
            if isdefined(coresponding_input):
                if isinstance(coresponding_input, bool) and coresponding_input == True:
                    outputs[name] = os.path.abspath(self._outputs_filenames[name])
                else:
                    outputs[name] = coresponding_input
        return outputs

    def _format_arg(self, name, spec, value):
        if name in self._outputs_filenames.keys():
            if isinstance(value, bool):
                if value == True:
                    fname = os.path.abspath(self._outputs_filenames[name])
                else:
                    return ""
            else:
                fname = value
            return spec.argstr % fname
        return super(BRAINSConstellationDetector, self)._format_arg(name, spec, value)

