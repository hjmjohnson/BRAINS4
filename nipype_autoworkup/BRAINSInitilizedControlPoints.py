from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec, File, Directory, traits, isdefined, InputMultiPath, OutputMultiPath
import os

class BRAINSInitilizedControlPointsInputSpec(CommandLineInputSpec):
    inputVolume = File( exists = True,argstr = "--inputVolume %s")
    outputVolume = traits.Either(traits.Bool, File(), hash_files = False,argstr = "--outputVolume %s")
    splineGridSize = InputMultiPath(traits.Int, sep = ",",argstr = "--splineGridSize %s")
    permuteOrder = InputMultiPath(traits.Int, sep = ",",argstr = "--permuteOrder %s")
    outputLandmarksFile = traits.Str( argstr = "--outputLandmarksFile %s")


class BRAINSInitilizedControlPointsOutputSpec(TraitedSpec):
    outputVolume = File( exists = True)


class BRAINSInitilizedControlPoints(CommandLine):

    input_spec = BRAINSInitilizedControlPointsInputSpec
    output_spec = BRAINSInitilizedControlPointsOutputSpec
    _cmd = " BRAINSInitilizedControlPoints "
    _outputs_filenames = {'outputVolume':'outputVolume.nii'}

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
        return super(BRAINSInitilizedControlPoints, self)._format_arg(name, spec, value)

