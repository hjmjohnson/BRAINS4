from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.traits import File
from nipype.utils.misc import isdefined

class itkConstantImageMathInputSpec(CommandLineInputSpec):
    inFilename = File(argstr='%s', desc = "inFilename", exists = True, mandatory = True, position = 0)
    fileMode = traits.Str(argstr='%s', desc = "fileMode", exists = True, mandatory = True, position = 1)
    value = traits.Int(argstr='%s', desc = "value", exists = True, mandatory = True, position = 2)
    operation = traits.String(argstr='%s', desc = "operation", exists = True, mandatory = True, position = 3)
    outFilename = traits.Str(argstr='%s', desc = "outFilename", exists = True, mandatory = True, position = 4)

class itkConstantImageMathOutputSpec(TraitedSpec):
    outFilename = File(desc = "outFilename", exists = True)

class itkConstantImageMath(CommandLine):

    input_spec = itkConstantImageMathInputSpec
    output_spec = itkConstantImageMathOutputSpec
    _cmd = "/scratch/brains/BRAINS3-build/src/bin/brains3 -b /raid0/homes/kpease/temp/itkWrapping/itkConstantImageMath.tcl"
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
        return super(itkConstantImageMath, self)._format_arg(name, spec, value)

