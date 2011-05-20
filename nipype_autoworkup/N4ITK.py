from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.traits import File
from nipype.interfaces.traits import Directory
from nipype.utils.misc import isdefined

class N4ITKInputSpec(CommandLineInputSpec):
    inputImageName = File( exists = "True",argstr = "--inputimage %s")
    maskImageName = File( exists = "True",argstr = "--maskimage %s")
    outputImageName = traits.Either(traits.Bool, File, argstr = "--outputimage %s")
    outputBiasFieldName = traits.Either(traits.Bool, File, argstr = "--outputbiasfield %s")
    Force2D = traits.Bool( argstr = "--force2D ")
    numberOfIterations = traits.List("traits.Int", sep = ",",argstr = "--iterations %d")
    convergenceThreshold = traits.Float( argstr = "--convergencethreshold %f")
    initialMeshResolution = traits.List("traits.Float", sep = ",",argstr = "--meshresolution %f")
    splineDistance = traits.Float( argstr = "--splinedistance %f")
    shrinkFactor = traits.Int( argstr = "--shrinkfactor %d")
    bsplineOrder = traits.Int( argstr = "--bsplineorder %d")
    weightImageName = File( exists = "True",argstr = "--weightimage %s")
    alpha = traits.Float( argstr = "--bsplinealpha %f")
    beta = traits.Float( argstr = "--bsplinebeta %f")
    histogramSharpening = traits.List("traits.Float", sep = ",",argstr = "--histogramsharpening %f")
    biasFieldFullWidthAtHalfMaximum = traits.Float( argstr = "--biasFieldFullWidthAtHalfMaximum %f")
    weinerFilterNoise = traits.Float( argstr = "--weinerFilterNoise %f")
    numberOfHistogramBins = traits.Int( argstr = "--numberOfHistogramBins %d")


class N4ITKOutputSpec(TraitedSpec):
    outputImageName = File(exists=True, argstr = "--outputimage %s")
    outputBiasFieldName = File(exists=True, argstr = "--outputbiasfield %s")


class N4ITK(CommandLine):

    input_spec = N4ITKInputSpec
    output_spec = N4ITKOutputSpec
    _cmd = "/scratch/brains/BRAINS3-build/src/bin/N4ITK "
    _outputs_filenames = {'outputBiasFieldName':'outputBiasFieldName.nii','outputImageName':'outputImageName.nii'}

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
        return super(N4ITK, self)._format_arg(name, spec, value)

