from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.traits import File
from nipype.interfaces.traits import Directory
from nipype.utils.misc import isdefined

class QuadMeshSmoothingInputSpec(CommandLineInputSpec):
    inputSurface = traits.Str( argstr = "----inputSurface %s")
    numberOfIterations = traits.Int( argstr = "--numberOfIterations %d")
    relaxationFactor = traits.Float( argstr = "--relaxationFactor %f")
    delaunayConforming = traits.Bool( argstr = "----delaunayConforming ")
    outputSurface = traits.Str( argstr = "----outputSurface %s")


class QuadMeshSmoothingOutputSpec(TraitedSpec):
    outputSurface = traits.File( argstr = "----outputSurface %s")


class QuadMeshSmoothing(CommandLine):

    input_spec = QuadMeshSmoothingInputSpec
    output_spec = QuadMeshSmoothingOutputSpec
    _cmd = "/scratch/brains/BRAINS3-build/src/bin/QuadMeshSmoothing "
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
        return super(QuadMeshSmoothing, self)._format_arg(name, spec, value)

