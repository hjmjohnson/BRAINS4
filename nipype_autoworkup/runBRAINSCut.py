from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.traits import File
from nipype.utils.misc import isdefined

class runBRAINSCutInputSpec(CommandLineInputSpec):
    subject = traits.Str(argstr='%s', desc = "subject", exists = True, mandatory = True, position = 0)
    imageMap = traits.List(argstr='%s', type="traits.Str", sep=":", desc = "imageMap", exists = True, mandatory = True, position = 1)
    atlasMap = traits.List(argstr='%s', type="traits.Str", sep=":", desc = "atlasMap", exists = True, mandatory = True, position = 2)
    regions = traits.List(argstr='%s', type="traits.Str", sep=",", desc = "regions", exists = True, mandatory = True, position = 3)
    probabilityMap = traits.List(argstr='%s', type="traits.Str", sep=":", desc = "probabilityMap", exists = True, mandatory = True, position = 4)
    xmlFile = traits.Str(argstr='%s', desc = "xmlFile", exists = True, mandatory = True, position = 5)
    outputDir = traits.Directory(argstr='%s', desc = "outputDir", exists = True, mandatory = True, position = 6)
    outputList = traits.List(argstr='%s', type="traits.File", sep=",", desc = "OutputAverageOfPassiveImages", exists = True, mandatory = True, position = 7)


class runBRAINSCutOutputSpec(TraitedSpec):
    outputDir = traits.Directory(desc = "outputDir", exists = True)
    outputList = traits.List(type="traits.File", sep=",", desc = "OutputAverageOfPassiveImages", exists = True)

class runBRAINSCut(CommandLine):

    input_spec = runBRAINSCutInputSpec
    output_spec = runBRAINSCutOutputSpec
    _cmd = "/scratch/brains/BRAINS3-build/src/bin/brains3 -b /raid0/homes/kpease/temp/itkWrapping/runBRAINSCut.tcl"
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
        return super(runBRAINSCut, self)._format_arg(name, spec, value)

