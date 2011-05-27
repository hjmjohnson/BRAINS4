from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.base import File
from nipype.interfaces.base import Directory

class QuadMeshDecimationInputSpec(CommandLineInputSpec):
    inputSurface = traits.Str( argstr = "--inputSurface %s")
    numberOfElements = traits.Int( argstr = "--numberOfElements %d")
    topologyChange = traits.Bool( argstr = "--topologyChange ")
    outputSurface = traits.Str( argstr = "--outputSurface %s")


class QuadMeshDecimationOutputSpec(TraitedSpec):
    outputSurface = traits.File( argstr = "--outputSurface %s")



class QuadMeshDecimation(CommandLine):

    input_spec = QuadMeshDecimationInputSpec
    output_spec = QuadMeshDecimationOutputSpec
    _cmd = "/scratch/brains/BRAINS3-build/src/bin/QuadMeshDecimation "
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
        return super(QuadMeshDecimation, self)._format_arg(name, spec, value)

