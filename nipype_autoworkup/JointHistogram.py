from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec, File, Directory, traits, isdefined, InputMultiPath, OutputMultiPath
import os

class JointHistogramInputSpec(CommandLineInputSpec):
    inputVolume1 = File( exists = True,argstr = "--inputVolume1 %s")
    inputVolume2 = File( exists = True,argstr = "--inputVolume2 %s")
    outputJointHistogramImage = traits.Str( argstr = "--outputJointHistogramImage %s")
    verbose = traits.Bool( argstr = "--verbose ")


class JointHistogramOutputSpec(TraitedSpec):


class JointHistogram(CommandLine):

    input_spec = JointHistogramInputSpec
    output_spec = JointHistogramOutputSpec
    _cmd = " JointHistogram "
    _outputs_filenames = {}

    def _list_outputs(self):
        outputs = self.output_spec().get()
        for name in outputs.keys():
            coresponding_input = getattr(self.inputs, name)
            if isdefined(coresponding_input):
                if isinstance(coresponding_input, bool) and coresponding_input == True:
                    outputs[name] = os.path.abspath(self._outputs_filenames[name])
                else:
                    if isinstance(coresponding_input, list):
                        outputs[name] = [os.path.abspath(inp) for inp in coresponding_input]
                    else:
                        outputs[name] = os.path.abspath(coresponding_input)
        return outputs

    def _format_arg(self, name, spec, value):
        if name in self._outputs_filenames.keys():
            if isinstance(value, bool):
                if value == True:
                    value = os.path.abspath(self._outputs_filenames[name])
                else:
                    return ""
        return super(JointHistogram, self)._format_arg(name, spec, value)

