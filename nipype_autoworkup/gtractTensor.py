from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.base import File
from nipype.interfaces.base import Directory


class gtractTensorInputSpec(CommandLineInputSpec):
	inputVolume = File( exists = "True",argstr = "--inputVolume %s")
	outputVolume = traits.Either(traits.Bool, File, argstr = "--outputVolume %s")
	medianFilterSize = traits.List("traits.Int", sep = ",",argstr = "--medianFilterSize %d")
	maskProcessingMode = traits.Enum("NOMASK","ROIAUTO","ROI", argstr = "--maskProcessingMode %s")
	maskVolume = File( exists = "True",argstr = "--maskVolume %s")
	backgroundSuppressingThreshold = traits.Int( argstr = "--backgroundSuppressingThreshold %d")
	resampleIsotropic = traits.Bool( argstr = "--resampleIsotropic ")
	voxelSize = traits.Float( argstr = "--size %f")
	b0Index = traits.Int( argstr = "--b0Index %d")
	applyMeasurementFrame = traits.Bool( argstr = "--applyMeasurementFrame ")
	ignoreIndex = traits.List("traits.Int", sep = ",",argstr = "--ignoreIndex %d")


class gtractTensorOutputSpec(TraitedSpec):
	outputVolume = File(exists=True, argstr = "--outputVolume %s")


class gtractTensor(CommandLine):

    input_spec = gtractTensorInputSpec
    output_spec = gtractTensorOutputSpec
    _cmd = "Slicer3 --launch gtractTensor "
    _outputs_filenames = {'outputVolume':'outputVolume.nrrd'}

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
        return super(gtractTensor, self)._format_arg(name, spec, value)

