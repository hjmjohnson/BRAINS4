from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec, File, Directory, traits, isdefined
import os

class GenerateLabelMapFromProbabilityMapInputSpec(CommandLineInputSpec):
    inputVolumes = traits.List(File(exists=True), argstr = "--inputVolumes %s...")
    outputLabelVolume = File( exists = "True",argstr = "--outputLabelVolume %s")


class GenerateLabelMapFromProbabilityMapOutputSpec(TraitedSpec):


class GenerateLabelMapFromProbabilityMap(CommandLine):

    input_spec = GenerateLabelMapFromProbabilityMapInputSpec
    output_spec = GenerateLabelMapFromProbabilityMapOutputSpec
    _cmd = " GenerateLabelMapFromProbabilityMap "
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
        return super(GenerateLabelMapFromProbabilityMap, self)._format_arg(name, spec, value)

