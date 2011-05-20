from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.traits import File
from nipype.utils.misc import isdefined

class ClipAndAverageTwoInputSpec(CommandLineInputSpec):
    activeImagesToDefineClipMask = traits.List(argstr='%s', type="traits.File", sep=",", desc = "ActiveImagesToDefineClipMask", exists = True, mandatory = True, position = 0)
    passiveImagesToClip = traits.List(argstr='%s', type="traits.File", sep=",", desc = "PassiveImagesToClip", exists = True, mandatory = True, position = 1)
    outputAverageOfActiveImages = traits.Str(argstr='%s', desc = "OutputAverageOfActiveImages", exists = True, mandatory = True, position = 2)
    outputAverageOfPassiveImages = traits.Str(argstr='%s', desc = "OutputAverageOfPassiveImages", exists = True, mandatory = True, position = 3)


class ClipAndAverageTwoOutputSpec(TraitedSpec):
    outputAverageOfActiveImages = traits.Str(desc = "OutputAverageOfActiveImages", exists = True)
    outputAverageOfPassiveImages = traits.Str(desc = "OutputAverageOfPassiveImages", exists = True)


class ClipAndAverageTwo(CommandLine):

    input_spec = ClipAndAverageTwoInputSpec
    output_spec = ClipAndAverageTwoOutputSpec
    _cmd = "/scratch/brains/BRAINS3-build/src/bin/brains3 -b /raid0/homes/kpease/temp/itkWrapping/ClipAndAverageTwo.tcl "
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
        return super(ClipAndAverageTwo, self)._format_arg(name, spec, value)

