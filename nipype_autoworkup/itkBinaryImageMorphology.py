from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.base import File

class itkBinaryImageMorphologyInputSpec(CommandLineInputSpec):
    inFilename = File(argstr='%s', desc = "inFilename", exists = True, mandatory = True, position = 0)
    fileMode = traits.Str(argstr='%s', desc = "fileMode", exists = True, mandatory = True, position = 1)
    var1 = traits.String(argstr='%s', desc = "var1", exists = True, mandatory = True, position = 2)
    var2 = traits.String(argstr='%s', desc = "var2", exists = True, mandatory = True, position = 3)
    radius = traits.List(argstr='%s', type = "traits.Float", sep = ",", desc = "radius", exists = True, mandatory = True, position = 4)
    outFilename = traits.Str(argstr='%s', desc = "outFilename", exists = True, mandatory = True, position = 5)


class itkBinaryImageMorphologyOutputSpec(TraitedSpec):
    outFilename = traits.Str(desc = "outFilename", exists = True)


class itkBinaryImageMorphology(CommandLine):

    input_spec = itkBinaryImageMorphologyInputSpec
    output_spec = itkBinaryImageMorphologyOutputSpec
    _cmd = "/scratch/brains/BRAINS3-build/src/bin/brains3 -b /raid0/homes/kpease/temp/itkWrapping/itkBinaryImageMorphology.tcl "
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
        return super(itkBinaryImageMorphology, self)._format_arg(name, spec, value)

