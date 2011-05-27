from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.base import File
from nipype.interfaces.base import Directory


class gtractFastMarchingTrackingInputSpec(CommandLineInputSpec):
	inputTensorVolume = File( exists = "True",argstr = "--inputTensorVolume %s")
	inputAnisotropyVolume = File( exists = "True",argstr = "--inputAnisotropyVolume %s")
	inputCostVolume = File( exists = "True",argstr = "--inputCostVolume %s")
	inputStartingSeedsLabelMapVolume = File( exists = "True",argstr = "--inputStartingSeedsLabelMapVolume %s")
	startingSeedsLabel = traits.Int( argstr = "--startingSeedsLabel %d")
	outputTract = traits.Str( argstr = "--outputTract %s")
	writeXMLPolyDataFile = traits.Bool( argstr = "--writeXMLPolyDataFile ")
	numberOfIterations = traits.Int( argstr = "--numberOfIterations %d")
	seedThreshold = traits.Float( argstr = "--seedThreshold %f")
	trackingThreshold = traits.Float( argstr = "--trackingThreshold %f")
	costStepSize = traits.Float( argstr = "--costStepSize %f")
	maximumStepSize = traits.Float( argstr = "--maximumStepSize %f")
	minimumStepSize = traits.Float( argstr = "--minimumStepSize %f")


class gtractFastMarchingTrackingOutputSpec(TraitedSpec):


class gtractFastMarchingTracking(CommandLine):

    input_spec = gtractFastMarchingTrackingInputSpec
    output_spec = gtractFastMarchingTrackingOutputSpec
    _cmd = "Slicer3 --launch gtractFastMarchingTracking "
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
        return super(gtractFastMarchingTracking, self)._format_arg(name, spec, value)

