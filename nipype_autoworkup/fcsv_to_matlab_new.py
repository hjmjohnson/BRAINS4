from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec, File, Directory, traits, isdefined, InputMultiPath, OutputMultiPath
import os

class fcsv_to_matlab_newInputSpec(CommandLineInputSpec):
    outputFile = traits.Either(traits.Bool, File(), hash_files = False,argstr = "--outputMatlabFile %s")
    landmarkTypesFile = traits.Either(traits.Bool, File(), hash_files = False,argstr = "--landmarkTypesFile %s")
    landmarkGlobPattern = traits.Str( argstr = "--landmarkGlobPattern %s")


class fcsv_to_matlab_newOutputSpec(TraitedSpec):
    outputFile = File( exists = True)
    landmarkTypesFile = File( exists = True)


class fcsv_to_matlab_new(CommandLine):

    input_spec = fcsv_to_matlab_newInputSpec
    output_spec = fcsv_to_matlab_newOutputSpec
    _cmd = " fcsv_to_matlab_new "
    _outputs_filenames = {'outputFile':'outputFile','landmarkTypesFile':'landmarkTypesFile'}

    def _list_outputs(self):
        outputs = self.output_spec().get()
        for name in outputs.keys():
            coresponding_input = getattr(self.inputs, name)
            if isdefined(coresponding_input):
                if isinstance(coresponding_input, bool) and coresponding_input == True:
                    outputs[name] = os.path.abspath(self._outputs_filenames[name])
                else:
                    if isinstance(coresponding_input, list):
                        outputs[name] = [os.path.abspath(inp) for inp in coresponding_input]
                    else:
                        outputs[name] = os.path.abspath(coresponding_input)
        return outputs

    def _format_arg(self, name, spec, value):
        if name in self._outputs_filenames.keys():
            if isinstance(value, bool):
                if value == True:
                    value = os.path.abspath(self._outputs_filenames[name])
                else:
                    return ""
        return super(fcsv_to_matlab_new, self)._format_arg(name, spec, value)

