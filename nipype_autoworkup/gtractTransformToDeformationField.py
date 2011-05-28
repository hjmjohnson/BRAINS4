from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.base import File
from nipype.interfaces.base import Directory


class gtractTransformToDeformationFieldInputSpec(CommandLineInputSpec):
	inputTransform = File( exists = "True",argstr = "--inputTransform %s")
	inputReferenceVolume = File( exists = "True",argstr = "--inputReferenceVolume %s")
	outputDeformationFieldVolume = traits.Either(traits.Bool, File, argstr = "--outputDeformationFieldVolume %s")


class gtractTransformToDeformationFieldOutputSpec(TraitedSpec):
	outputDeformationFieldVolume = File(exists=True, argstr = "--outputDeformationFieldVolume %s")


class gtractTransformToDeformationField(CommandLine):

    input_spec = gtractTransformToDeformationFieldInputSpec
    output_spec = gtractTransformToDeformationFieldOutputSpec
    _cmd = "Slicer3 --launch gtractTransformToDeformationField "
    _outputs_filenames = {'outputDeformationFieldVolume':'outputDeformationFieldVolume.nii'}

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
        return super(gtractTransformToDeformationField, self)._format_arg(name, spec, value)
