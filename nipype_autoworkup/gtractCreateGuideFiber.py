from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.base import File
from nipype.interfaces.base import Directory


class gtractCreateGuideFiberInputSpec(CommandLineInputSpec):
	inputFiber = traits.Str( argstr = "--inputFiber %s")
	numberOfPoints = traits.Int( argstr = "--numberOfPoints %d")
	outputFiber = traits.Str( argstr = "--outputFiber %s")
	writeXMLPolyDataFile = traits.Bool( argstr = "--writeXMLPolyDataFile ")


class gtractCreateGuideFiberOutputSpec(TraitedSpec):


class gtractCreateGuideFiber(CommandLine):

    input_spec = gtractCreateGuideFiberInputSpec
    output_spec = gtractCreateGuideFiberOutputSpec
    _cmd = "Slicer3 --launch gtractCreateGuideFiber "
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
        return super(gtractCreateGuideFiber, self)._format_arg(name, spec, value)

