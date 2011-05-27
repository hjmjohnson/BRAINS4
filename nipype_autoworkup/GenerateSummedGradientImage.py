from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.base import File
from nipype.interfaces.base import Directory


class GenerateSummedGradientImageInputSpec(CommandLineInputSpec):
	inputVolume1 = File( exists = "True",argstr = "--inputVolume1 %s")
	inputVolume2 = File( exists = "True",argstr = "--inputVolume2 %s")
	outputFileName = traits.Either(traits.Bool, File, argstr = "--outputFileName %s")
	MaximumGradient = traits.Bool( argstr = "--MaximumGradient ")


class GenerateSummedGradientImageOutputSpec(TraitedSpec):
	outputFileName = File(exists=True, argstr = "--outputFileName %s")


class GenerateSummedGradientImage(CommandLine):

    input_spec = GenerateSummedGradientImageInputSpec
    output_spec = GenerateSummedGradientImageOutputSpec
    _cmd = "Slicer3 --launch GenerateSummedGradientImage "
    _outputs_filenames = {'outputFileName':'outputFileName'}

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
        return super(GenerateSummedGradientImage, self)._format_arg(name, spec, value)

