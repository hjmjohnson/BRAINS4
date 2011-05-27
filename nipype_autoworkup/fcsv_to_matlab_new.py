from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.base import File
from nipype.interfaces.base import Directory


class fcsv_to_matlab_newInputSpec(CommandLineInputSpec):
	outputFile = traits.Either(traits.Bool, File, argstr = "----outputMatlabFile %s")
	landmarkTypesFile = traits.Either(traits.Bool, File, argstr = "----landmarkTypesFile %s")
	landmarkGlobPattern = traits.Str( argstr = "--landmarkGlobPattern %s")


class fcsv_to_matlab_newOutputSpec(TraitedSpec):
	outputFile = File(exists=True, argstr = "----outputMatlabFile %s")
	landmarkTypesFile = File(exists=True, argstr = "----landmarkTypesFile %s")


class fcsv_to_matlab_new(CommandLine):

    input_spec = fcsv_to_matlab_newInputSpec
    output_spec = fcsv_to_matlab_newOutputSpec
    _cmd = "Slicer3 --launch fcsv_to_matlab_new "
    _outputs_filenames = {'outputFile':'outputFile','landmarkTypesFile':'landmarkTypesFile'}

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
        return super(fcsv_to_matlab_new, self)._format_arg(name, spec, value)

