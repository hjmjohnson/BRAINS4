from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.base import File
from nipype.interfaces.base import Directory


class BRAINSMultiModeSegmentInputSpec(CommandLineInputSpec):
	inputVolumes = File( exists = "True",argstr = "----inputVolumes %s")
	inputMaskVolume = File( exists = "True",argstr = "----inputMaskVolume %s")
	outputROIMaskVolume = traits.Either(traits.Bool, File, argstr = "----outputROIMaskVolume %s")
	outputClippedVolumeROI = traits.Either(traits.Bool, File, argstr = "----outputClippedVolumeROI %s")
	lowerThreshold = traits.List("traits.Float", sep = ",",argstr = "----lowerThreshold %f")
	upperThreshold = traits.List("traits.Float", sep = ",",argstr = "----upperThreshold %f")


class BRAINSMultiModeSegmentOutputSpec(TraitedSpec):
	outputROIMaskVolume = File(exists=True, argstr = "----outputROIMaskVolume %s")
	outputClippedVolumeROI = File(exists=True, argstr = "----outputClippedVolumeROI %s")


class BRAINSMultiModeSegment(CommandLine):

    input_spec = BRAINSMultiModeSegmentInputSpec
    output_spec = BRAINSMultiModeSegmentOutputSpec
    _cmd = "Slicer3 --launch BRAINSMultiModeSegment "
    _outputs_filenames = {'outputROIMaskVolume':'outputROIMaskVolume.nii','outputClippedVolumeROI':'outputClippedVolumeROI.nii'}

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
        return super(BRAINSMultiModeSegment, self)._format_arg(name, spec, value)

