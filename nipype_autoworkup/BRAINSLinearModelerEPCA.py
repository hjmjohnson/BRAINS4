from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec, File, Directory, traits, isdefined, InputMultiPath, OutputMultiPath
import os

class BRAINSLinearModelerEPCAInputSpec(CommandLineInputSpec):
    inputTrainingList = File( exists = True,argstr = "--inputTrainingList %s")


class BRAINSLinearModelerEPCAOutputSpec(TraitedSpec):


class BRAINSLinearModelerEPCA(CommandLine):

    input_spec = BRAINSLinearModelerEPCAInputSpec
    output_spec = BRAINSLinearModelerEPCAOutputSpec
    _cmd = " BRAINSLinearModelerEPCA "
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
        return super(BRAINSLinearModelerEPCA, self)._format_arg(name, spec, value)

