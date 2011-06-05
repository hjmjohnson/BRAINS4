from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec, File, Directory, traits, isdefined
import os

class ESLRInputSpec(CommandLineInputSpec):
    inputVolume = File( exists = "True",argstr = "--inputVolume %s")
    outputVolume = traits.Either(traits.Bool, File, argstr = "--outputVolume %s")
    low = traits.Int( argstr = "--low %d")
    high = traits.Int( argstr = "--high %d")
    closingSize = traits.Int( argstr = "--closingSize %d")
    openingSize = traits.Int( argstr = "--openingSize %d")
    safetySize = traits.Int( argstr = "--safetySize %d")
    preserveOutside = traits.Bool( argstr = "--preserveOutside ")


class ESLROutputSpec(TraitedSpec):
    outputVolume = File(exists=True, argstr = "--outputVolume %s")


class ESLR(CommandLine):

    input_spec = ESLRInputSpec
    output_spec = ESLROutputSpec
    _cmd = " ESLR "
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
        return super(ESLR, self)._format_arg(name, spec, value)

