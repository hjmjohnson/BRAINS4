from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.base import File
from nipype.interfaces.base import Directory

class BRAINSDiscreteClassInputSpec(CommandLineInputSpec):
    inputVolume = File( exists = "True",argstr = "--inputVolume %s")
    subcorticalMask = File( exists = "True",argstr = "--subcorticalMask %s")
    outputVolume = traits.Either(traits.Bool, File, argstr = "--outputVolume %s")
    subcorticalThreshold = traits.Float( argstr = "--subcorticalThreshold %f")
    corticalThreshold = traits.Float( argstr = "--corticalThreshold %f")
    csfThreshold = traits.Float( argstr = "--csfThreshold %f")


class BRAINSDiscreteClassOutputSpec(TraitedSpec):
    outputVolume = File(exists=True, argstr = "--outputVolume %s")


class BRAINSDiscreteClass(CommandLine):

    input_spec = BRAINSDiscreteClassInputSpec
    output_spec = BRAINSDiscreteClassOutputSpec
    _cmd = "/scratch/brains/BRAINS3-build/src/bin/BRAINSDiscreteClass "
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
        return super(BRAINSDiscreteClass, self)._format_arg(name, spec, value)

