from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.traits import File
from nipype.interfaces.traits import Directory
from nipype.utils.misc import isdefined

class BRAINSTalairachMaskInputSpec(CommandLineInputSpec):
    inputVolume = File( exists = "True",argstr = "--inputVolume %s")
    talairachParameters = File( exists = "True",argstr = "--talairachParameters %s")
    talairachBox = File( exists = "True",argstr = "--talairachBox %s")
    hemisphereMode = traits.Enum("left","right","both", argstr = "--hemisphereMode %s")
    expand = traits.Bool( argstr = "--expand ")
    outputVolume = traits.Either(traits.Bool, File, argstr = "--outputVolume %s")


class BRAINSTalairachMaskOutputSpec(TraitedSpec):
    outputVolume = File(exists=True, argstr = "--outputVolume %s")


class BRAINSTalairachMask(CommandLine):

    input_spec = BRAINSTalairachMaskInputSpec
    output_spec = BRAINSTalairachMaskOutputSpec
    _cmd = "/scratch/brains/BRAINS3-build/src/bin/BRAINSTalairachMask "
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
        return super(BRAINSTalairachMask, self)._format_arg(name, spec, value)

