from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.base import File
from nipype.interfaces.base import Directory


class BRAINSInitilizedControlPointsInputSpec(CommandLineInputSpec):
	inputVolume = File( exists = "True",argstr = "----inputVolume %s")
	outputVolume = traits.Either(traits.Bool, File, argstr = "----outputVolume %s")
	splineGridSize = traits.List("traits.Int", sep = ",",argstr = "--splineGridSize %d")
	permuteOrder = traits.List("traits.Int", sep = ",",argstr = "--permuteOrder %d")
	outputLandmarksFile = traits.Str( argstr = "----outputLandmarksFile %s")


class BRAINSInitilizedControlPointsOutputSpec(TraitedSpec):
	outputVolume = File(exists=True, argstr = "----outputVolume %s")


class BRAINSInitilizedControlPoints(CommandLine):

    input_spec = BRAINSInitilizedControlPointsInputSpec
    output_spec = BRAINSInitilizedControlPointsOutputSpec
    _cmd = "Slicer3 --launch BRAINSInitilizedControlPoints "
    _outputs_filenames = {'outputVolume':'outputVolume.nii'}

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
        return super(BRAINSInitilizedControlPoints, self)._format_arg(name, spec, value)

