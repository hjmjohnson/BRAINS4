from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.traits import File
from nipype.interfaces.traits import Directory
from nipype.utils.misc import isdefined

class BRAINSMushInputSpec(CommandLineInputSpec):
    inputFirstVolume = File( exists = "True",argstr = "--inputFirstVolume %s")
    inputSecondVolume = File( exists = "True",argstr = "--inputSecondVolume %s")
    inputMaskVolume = File( exists = "True",argstr = "--inputMaskVolume %s")
    outputWeightsFile = traits.Either(traits.Bool, File, argstr = "--outputWeightsFile %s")
    outputImage = traits.Either(traits.Bool, File, argstr = "--outputImage %s")
    outputMask = traits.Either(traits.Bool, File, argstr = "--outputMask %s")
    seed = traits.List("traits.Int", sep = ",",argstr = "--seed %d")
    desiredMean = traits.Float( argstr = "--desiredMean %f")
    desiredVariance = traits.Float( argstr = "--desiredVariance %f")
    lowerThresholdFactorPre = traits.Float( argstr = "--lowerThresholdFactorPre %f")
    upperThresholdFactorPre = traits.Float( argstr = "--upperThresholdFactorPre %f")
    lowerThresholdFactor = traits.Float( argstr = "--lowerThresholdFactor %f")
    upperThresholdFactor = traits.Float( argstr = "--upperThresholdFactor %f")
    boundingBoxSize = traits.List("traits.Int", sep = ",",argstr = "--boundingBoxSize %d")
    boundingBoxStart = traits.List("traits.Int", sep = ",",argstr = "--boundingBoxStart %d")


class BRAINSMushOutputSpec(TraitedSpec):
    outputWeightsFile = File(exists=True, argstr = "--outputWeightsFile %s")
    outputImage = File(exists=True, argstr = "--outputImage %s")
    outputMask = File(exists=True, argstr = "--outputMask %s")


class BRAINSMush(CommandLine):

    input_spec = BRAINSMushInputSpec
    output_spec = BRAINSMushOutputSpec
    _cmd = "/scratch/brains/BRAINS3-build/src/bin/BRAINSMush "
    _outputs_filenames = {'outputWeightsFile':'outputWeightsFile','outputImage':'outputImage.nii','outputMask':'outputMask.nii'}

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
        return super(BRAINSMush, self)._format_arg(name, spec, value)

