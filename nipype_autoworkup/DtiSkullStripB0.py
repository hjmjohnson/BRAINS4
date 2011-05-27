from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.base import File

class DtiSkullStripB0InputSpec(CommandLineInputSpec):
    B0File = File(argstr='%s', desc = "B0File", exists = True, mandatory = True, position = 0)
    ClippedB0File = traits.Str(argstr='%s', desc = "ClippedB0File", exists = True, mandatory = True, position = 1)
    Threshold = traits.Int(argstr='%s', desc = "Threshold", exists = True, mandatory = True, position = 2)
    ErodeSize = traits.Int(argstr='%s', desc = "ErodeSize", exists = True, mandatory = True, position = 3)
    DilateSize = traits.Int(argstr='%s', desc = "DilateSize", exists = True, mandatory = True, position = 4)

class DtiSkullStripB0OutputSpec(TraitedSpec):
    ClippedB0File = File(desc = "ClippedB0File", exists = True)

class DtiSkullStripB0(CommandLine):

    input_spec = DtiSkullStripB0InputSpec
    output_spec = DtiSkullStripB0OutputSpec
    _cmd = "/scratch/brains/BRAINS3-build/src/bin/brains3 -b /raid0/homes/kpease/temp/itkWrapping/DtiSkullStripB0.tcl "
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
        return super(DtiSkullStripB0, self)._format_arg(name, spec, value)

