from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.base import File
from nipype.interfaces.base import Directory


class gtractResampleFibersInputSpec(CommandLineInputSpec):
	inputForwardDeformationFieldVolume = File( exists = "True",argstr = "--inputForwardDeformationFieldVolume %s")
	inputReverseDeformationFieldVolume = File( exists = "True",argstr = "--inputReverseDeformationFieldVolume %s")
	inputTract = traits.Str( argstr = "--inputTract %s")
	outputTract = traits.Str( argstr = "--outputTract %s")
	writeXMLPolyDataFile = traits.Bool( argstr = "--writeXMLPolyDataFile ")


class gtractResampleFibersOutputSpec(TraitedSpec):


class gtractResampleFibers(CommandLine):

    input_spec = gtractResampleFibersInputSpec
    output_spec = gtractResampleFibersOutputSpec
    _cmd = "Slicer3 --launch gtractResampleFibers "
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
        return super(gtractResampleFibers, self)._format_arg(name, spec, value)

