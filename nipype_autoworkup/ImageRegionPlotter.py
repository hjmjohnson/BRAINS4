from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.base import File
from nipype.interfaces.base import Directory


class ImageRegionPlotterInputSpec(CommandLineInputSpec):
	inputVolume1 = File( exists = "True",argstr = "--inputVolume1 %s")
	inputVolume2 = File( exists = "True",argstr = "--inputVolume2 %s")
	inputBinaryROIVolume = File( exists = "True",argstr = "--inputBinaryROIVolume %s")
	inputLabelVolume = File( exists = "True",argstr = "--inputLabelVolume %s")
	numberOfHistogramBins = traits.Int( argstr = "--numberOfHistogramBins %d")
	outputJointHistogramData = traits.Str( argstr = "--outputJointHistogramData %s")
	useROIAUTO = traits.Bool( argstr = "--useROIAUTO ")
	useIntensityForHistogram = traits.Bool( argstr = "--useIntensityForHistogram ")
	verbose = traits.Bool( argstr = "--verbose ")


class ImageRegionPlotterOutputSpec(TraitedSpec):


class ImageRegionPlotter(CommandLine):

    input_spec = ImageRegionPlotterInputSpec
    output_spec = ImageRegionPlotterOutputSpec
    _cmd = "Slicer3 --launch ImageRegionPlotter "
    _outputs_filenames = {}

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
        return super(ImageRegionPlotter, self)._format_arg(name, spec, value)

