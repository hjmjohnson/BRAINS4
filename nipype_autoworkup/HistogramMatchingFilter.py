from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec, File, Directory, traits, isdefined
import os

class HistogramMatchingFilterInputSpec(CommandLineInputSpec):
    inputVolume = File( exists = "True",argstr = "--inputVolume %s")
    referenceVolume = File( exists = "True",argstr = "--referenceVolume %s")
    outputVolume = traits.Either(traits.Bool, File, argstr = "--outputVolume %s")
    referenceBinaryVolume = File( exists = "True",argstr = "--referenceBinaryVolume %s")
    inputBinaryVolume = File( exists = "True",argstr = "--inputBinaryVolume %s")
    numberOfMatchPoints = traits.Int( argstr = "--numberOfMatchPoints %d")
    numberOfHistogramBins = traits.Int( argstr = "--numberOfHistogramBins %d")
    writeHistogram = traits.Str( argstr = "--writeHistogram %s")
    histogramAlgorithm = traits.Enum("OtsuHistogramMatching", argstr = "--histogramAlgorithm %s")
    verbose = traits.Bool( argstr = "--verbose ")


class HistogramMatchingFilterOutputSpec(TraitedSpec):
    outputVolume = File(exists=True, argstr = "--outputVolume %s")


class HistogramMatchingFilter(CommandLine):

    input_spec = HistogramMatchingFilterInputSpec
    output_spec = HistogramMatchingFilterOutputSpec
    _cmd = " HistogramMatchingFilter "
    _outputs_filenames = {'outputVolume':'outputVolume.nii'}

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
        return super(HistogramMatchingFilter, self)._format_arg(name, spec, value)

