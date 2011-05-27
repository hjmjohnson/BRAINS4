from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.base import File
from nipype.interfaces.base import Directory


class BRAINSCutInputSpec(CommandLineInputSpec):
	netConfiguration = File( exists = "True",argstr = "--netConfiguration %s")
	trainModelStartIndex = traits.Int( argstr = "--trainModelStartIndex %d")
	verbose = traits.Int( argstr = "--verbose %d")
	multiStructureThreshold = traits.Bool( argstr = "--multiStructureThreshold ")
	histogramEqualization = traits.Bool( argstr = "--histogramEqualization ")
	doTest = traits.Bool( argstr = "--doTest ")
	generateProbability = traits.Bool( argstr = "--generateProbability ")
	createVectors = traits.Bool( argstr = "--createVectors ")
	trainModel = traits.Bool( argstr = "--trainModel ")
	applyModel = traits.Bool( argstr = "--applyModel ")
	validate = traits.Bool( argstr = "--validate ")


class BRAINSCutOutputSpec(TraitedSpec):


class BRAINSCut(CommandLine):

    input_spec = BRAINSCutInputSpec
    output_spec = BRAINSCutOutputSpec
    _cmd = "Slicer3 --launch BRAINSCut "
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
        return super(BRAINSCut, self)._format_arg(name, spec, value)

