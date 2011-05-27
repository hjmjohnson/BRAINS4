from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.base import File
from nipype.interfaces.base import Directory


class BRAINSLmkTransformInputSpec(CommandLineInputSpec):
	inputMovingLandmarks = File( exists = "True",argstr = "--inputMovingLandmarks %s")
	inputFixedLandmarks = File( exists = "True",argstr = "--inputFixedLandmarks %s")
	outputAffineTransform = traits.Either(traits.Bool, File, argstr = "--outputAffineTransform %s")
	inputMovingVolume = File( exists = "True",argstr = "--inputMovingVolume %s")
	inputReferenceVolume = File( exists = "True",argstr = "--inputReferenceVolume %s")
	outputResampledVolume = traits.Either(traits.Bool, File, argstr = "--outputResampledVolume %s")


class BRAINSLmkTransformOutputSpec(TraitedSpec):
	outputAffineTransform = File(exists=True, argstr = "--outputAffineTransform %s")
	outputResampledVolume = File(exists=True, argstr = "--outputResampledVolume %s")


class BRAINSLmkTransform(CommandLine):

    input_spec = BRAINSLmkTransformInputSpec
    output_spec = BRAINSLmkTransformOutputSpec
    _cmd = "Slicer3 --launch BRAINSLmkTransform "
    _outputs_filenames = {'outputResampledVolume':'outputResampledVolume.nii','outputAffineTransform':'outputAffineTransform.mat'}

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
        return super(BRAINSLmkTransform, self)._format_arg(name, spec, value)

