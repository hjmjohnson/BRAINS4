from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.base import File

class AutoTalairachParametersInputSpec(CommandLineInputSpec):
    ACPCLandmarkFile = File(argstr='%s', desc = "ACPCLandmarkFile", exists = True, mandatory = True, position = 0)
    brainMask = File(argstr='%s', desc = "BrainMask", exists = True, mandatory = True, position = 1)
    talairachBoxFile = traits.Str(argstr='%s', desc = "TalairachBoxFile", exists = True, mandatory = True, position = 2)
    talairachGridFile = traits.Str(argstr='%s', desc = "TalairachGridFile", exists = True, mandatory = True, position = 3)


class AutoTalairachParametersOutputSpec(TraitedSpec):
    talairachBoxFile = traits.Str(desc = "TalairachBoxFile", exists = True)
    talairachGridFile = traits.Str(desc = "TalairachGridFile", exists = True)


class AutoTalairachParameters(CommandLine):

    input_spec = AutoTalairachParametersInputSpec
    output_spec = AutoTalairachParametersOutputSpec
    _cmd = "/scratch/brains/BRAINS3-build/src/bin/brains3 -b /raid0/homes/kpease/temp/itkWrapping/AutoTalairachParameters.tcl "
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
        return super(AutoTalairachParameters, self)._format_arg(name, spec, value)

