from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec, File, Directory, traits, isdefined
import os

class BRAINSConstellationModelerInputSpec(CommandLineInputSpec):
    verbose = traits.Bool( argstr = "--verbose ")
    inputTrainingList = File( exists = "True",argstr = "--inputTrainingList %s")
    outputModel = traits.Either(traits.Bool, File, argstr = "--outputModel %s")
    saveOptimizedLandmarks = traits.Bool( argstr = "--saveOptimizedLandmarks ")
    optimizedLandmarksFilenameExtender = traits.Str( argstr = "--optimizedLandmarksFilenameExtender %s")
    resultsDir = traits.Either(traits.Bool, File, argstr = "--resultsDir %s")
    mspQualityLevel = traits.Int( argstr = "--mspQualityLevel %d")
    rescaleIntensities = traits.Bool( argstr = "--rescaleIntensities ")
    trimRescaledIntensities = traits.Float( argstr = "--trimRescaledIntensities %f")
    rescaleIntensitiesOutputRange = traits.List(traits.Int, sep = ",",argstr = "--rescaleIntensitiesOutputRange %d")
    backgroundFillValueString = traits.Str( argstr = "--BackgroundFillValue %s")
    writedebuggingImagesLevel = traits.Int( argstr = "--writedebuggingImagesLevel %d")


class BRAINSConstellationModelerOutputSpec(TraitedSpec):
    outputModel = File(exists=True, argstr = "--outputModel %s")
    resultsDir = File(exists=True, argstr = "--resultsDir %s")


class BRAINSConstellationModeler(CommandLine):

    input_spec = BRAINSConstellationModelerInputSpec
    output_spec = BRAINSConstellationModelerOutputSpec
    _cmd = " BRAINSConstellationModeler "
    _outputs_filenames = {'outputModel':'outputModel','resultsDir':'resultsDir'}

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
        return super(BRAINSConstellationModeler, self)._format_arg(name, spec, value)

