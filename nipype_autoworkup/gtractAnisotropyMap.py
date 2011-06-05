from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec, File, Directory, traits, isdefined
import os

class gtractAnisotropyMapInputSpec(CommandLineInputSpec):
    inputTensorVolume = File( exists = "True",argstr = "--inputTensorVolume %s")
    anisotropyType = traits.Enum("ADC","FA","RA","VR","AD","RD","LI", argstr = "--anisotropyType %s")
    outputVolume = traits.Either(traits.Bool, File, argstr = "--outputVolume %s")


class gtractAnisotropyMapOutputSpec(TraitedSpec):
    outputVolume = File(exists=True, argstr = "--outputVolume %s")


class gtractAnisotropyMap(CommandLine):

    input_spec = gtractAnisotropyMapInputSpec
    output_spec = gtractAnisotropyMapOutputSpec
    _cmd = " gtractAnisotropyMap "
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
        return super(gtractAnisotropyMap, self)._format_arg(name, spec, value)

