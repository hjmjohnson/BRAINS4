from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.base import File

class StandardizeImageIntensityInputSpec(CommandLineInputSpec):
    imageFilename = File(argstr='%s', desc = "ImageFilename", exists = True, mandatory = True, position = 0)
    brainLabelImageFilename = File(argstr='%s', desc = "BrainLabelImageFilename", exists = True, mandatory = True, position = 1)
    resultImageFilename = traits.Str(argstr='%s', desc = "ResultImageFilename", exists = True, mandatory = True, position = 2)
    minLabel = traits.Int(argstr='%s', desc = "MinLabel", exists = True, mandatory = True, position = 3)
    maxLabel = traits.Int(argstr='%s', desc = "MaxLabel", exists = True, mandatory = True, position = 4)


class StandardizeImageIntensityOutputSpec(TraitedSpec):
    resultImageFilename = File(desc = "ResultImageFilename", exists = True)


class StandardizeImageIntensity(CommandLine):

    input_spec = StandardizeImageIntensityInputSpec
    output_spec = StandardizeImageIntensityOutputSpec
    _cmd = "/scratch/brains/BRAINS3-build/src/bin/brains3 -b /raid0/homes/kpease/temp/itkWrapping/StandardizeImageIntensity.tcl"
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
        return super(StandardizeImageIntensity, self)._format_arg(name, spec, value)

