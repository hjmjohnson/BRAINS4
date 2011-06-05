from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec, File, Directory, traits, isdefined
import os

class gtractResampleDWIInPlaceInputSpec(CommandLineInputSpec):
    inputVolume = File( exists = "True",argstr = "--inputVolume %s")
    inputTransform = File( exists = "True",argstr = "--inputTransform %s")
    debugLevel = traits.Int( argstr = "----debugLevel %d")
    outputVolume = traits.Either(traits.Bool, File, argstr = "--outputVolume %s")


class gtractResampleDWIInPlaceOutputSpec(TraitedSpec):
    outputVolume = File(exists=True, argstr = "--outputVolume %s")


class gtractResampleDWIInPlace(CommandLine):

    input_spec = gtractResampleDWIInPlaceInputSpec
    output_spec = gtractResampleDWIInPlaceOutputSpec
    _cmd = " gtractResampleDWIInPlace "
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
        return super(gtractResampleDWIInPlace, self)._format_arg(name, spec, value)

