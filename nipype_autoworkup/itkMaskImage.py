from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.traits import File
from nipype.utils.misc import isdefined

class itkMaskImageInputSpec(CommandLineInputSpec):
    inImageFilename = File(argstr='%s', desc = "inImageFilename", exists = True, mandatory = True, position = 0)
    inMaskFilename = File(argstr='%s', desc = "inMaskFilename", exists = True, mandatory = True, position = 1)
    fileMode = traits.Str(argstr='%s', desc = "fileMode", exists = True, mandatory = True, position = 2)
    outFilename = traits.Str(argstr='%s', desc = "outFilename", exists = True, mandatory = True, position = 3)

class itkMaskImageOutputSpec(TraitedSpec):
    outFilename = File(desc = "outFilename", exists = True)

class itkMaskImage(CommandLine):

    input_spec = itkMaskImageInputSpec
    output_spec = itkMaskImageOutputSpec
    _cmd = "/scratch/brains/BRAINS3-build/src/bin/brains3 -b /raid0/homes/kpease/temp/itkWrapping/itkMaskImage.tcl"
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
        return super(itkMaskImage, self)._format_arg(name, spec, value)

