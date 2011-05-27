from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.base import File
from nipype.interfaces.base import Directory


class BRAINSAlignMSPInputSpec(CommandLineInputSpec):
	inputVolume = File( exists = "True",argstr = "--inputVolume %s")
	resampleMSP = traits.Either(traits.Bool, File, argstr = "--OutputresampleMSP %s")
	verbose = traits.Bool( argstr = "--verbose ")
	resultsDir = traits.Either(traits.Bool, File, argstr = "--resultsDir %s")
	writedebuggingImagesLevel = traits.Int( argstr = "--writedebuggingImagesLevel %d")
	mspQualityLevel = traits.Int( argstr = "--mspQualityLevel %d")
	rescaleIntensities = traits.Bool( argstr = "--rescaleIntensities ")
	trimRescaledIntensities = traits.Float( argstr = "--trimRescaledIntensities %f")
	rescaleIntensitiesOutputRange = traits.List("traits.Int", sep = ",",argstr = "--rescaleIntensitiesOutputRange %d")
	backgroundFillValueString = traits.Str( argstr = "--BackgroundFillValue %s")
	interpolationMode = traits.Enum("NearestNeighbor","Linear","ResampleInPlace","BSpline","WindowedSinc", argstr = "--interpolationMode %s")


class BRAINSAlignMSPOutputSpec(TraitedSpec):
	resampleMSP = File(exists=True, argstr = "--OutputresampleMSP %s")
	resultsDir = File(exists=True, argstr = "--resultsDir %s")


class BRAINSAlignMSP(CommandLine):

    input_spec = BRAINSAlignMSPInputSpec
    output_spec = BRAINSAlignMSPOutputSpec
    _cmd = "Slicer3 --launch BRAINSAlignMSP "
    _outputs_filenames = {'resampleMSP':'resampleMSP','resultsDir':'resultsDir'}

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
        return super(BRAINSAlignMSP, self)._format_arg(name, spec, value)

