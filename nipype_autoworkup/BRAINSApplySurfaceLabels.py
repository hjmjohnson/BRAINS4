from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.base import File
from nipype.interfaces.base import Directory

class BRAINSApplySurfaceLabelsInputSpec(CommandLineInputSpec):
    inputLabelMap = File( exists = "True",argstr = "--inputLabelMap %s")
    inputSurface = File( exists = "True",argstr = "--inputSurface %s")
    cellDataName = traits.Str( exists = "True",argstr = "--cellDataName %s")
    outputSurface = traits.Either(traits.Bool, File, argstr = "--outputSurface %s")


class BRAINSApplySurfaceLabelsOutputSpec(TraitedSpec):
    outputSurface = File(exists=True, argstr = "--outputSurface %s")


class BRAINSApplySurfaceLabels(CommandLine):

    input_spec = BRAINSApplySurfaceLabelsInputSpec
    output_spec = BRAINSApplySurfaceLabelsOutputSpec
    _cmd = "/scratch/brains/BRAINS3-build/src/bin/BRAINSApplySurfaceLabels "
    _outputs_filenames = {'outputSurface':'outputSurface'}

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
        return super(BRAINSApplySurfaceLabels, self)._format_arg(name, spec, value)

