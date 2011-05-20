from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.traits import File
from nipype.utils.misc import isdefined

class CreateGenusZeroBrainSurfaceInputSpec(CommandLineInputSpec):
    BrainMaskFile = File(argstr='%s', desc = "BrainMaskFile", exists = True, mandatory = True, position = 0)
    WarpedCerebellumFile = File(argstr='%s', desc = "WarpedCerebellumFile", exists = True, mandatory = True, position = 1)
    HemisphereMaskFile = File(argstr='%s', desc = "HemisphereMaskFile", exists = True, mandatory = True, position = 2)
    TissueClassFile = File(argstr='%s', desc = "TissueClassFile", exists = True, mandatory = True, position = 3)
    SurfaceImageFilename = traits.Str(argstr='%s', desc = "SurfaceImageFilename", exists = True, mandatory = True, position = 4)
    OutputSurfaceFilename = traits.Str(argstr='%s', desc = "OutputSurfaceFilename", exists = True, mandatory = True, position = 5)

class CreateGenusZeroBrainSurfaceOutputSpec(TraitedSpec):
    SurfaceImageFilename = File(desc = "SurfaceImageFilename", exists = True)
    OutputSurfaceFilename = File(desc = "OutputSurfaceFilename", exists = True)

class CreateGenusZeroBrainSurface(CommandLine):

    input_spec = CreateGenusZeroBrainSurfaceInputSpec
    output_spec = CreateGenusZeroBrainSurfaceOutputSpec
    _cmd = "/scratch/brains/BRAINS3-build/src/bin/brains3 -b /raid0/homes/kpease/temp/itkWrapping/CreateGenusZeroBrainSurface.tcl "
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
        return super(CreateGenusZeroBrainSurface, self)._format_arg(name, spec, value)

