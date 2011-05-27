from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.base import File
from nipype.interfaces.base import Directory


class extractNrrdVectorIndexInputSpec(CommandLineInputSpec):
	inputVolume = File( exists = "True",argstr = "--inputVolume %s")
	vectorIndex = traits.Int( argstr = "--vectorIndex %d")
	setImageOrientation = traits.Enum("AsAcquired","Axial","Coronal","Sagittal", argstr = "--setImageOrientation %s")
	outputVolume = traits.Either(traits.Bool, File, argstr = "--outputVolume %s")


class extractNrrdVectorIndexOutputSpec(TraitedSpec):
	outputVolume = File(exists=True, argstr = "--outputVolume %s")


class extractNrrdVectorIndex(CommandLine):

    input_spec = extractNrrdVectorIndexInputSpec
    output_spec = extractNrrdVectorIndexOutputSpec
    _cmd = "Slicer3 --launch extractNrrdVectorIndex "
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
        return super(extractNrrdVectorIndex, self)._format_arg(name, spec, value)

