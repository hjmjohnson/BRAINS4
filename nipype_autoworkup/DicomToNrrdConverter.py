from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.traits import File
from nipype.interfaces.traits import Directory
from nipype.utils.misc import isdefined

class DicomToNrrdConverterInputSpec(CommandLineInputSpec):
    inputDicomDirectory = Directory( exists = "True",argstr = "--inputDicomDirectory %s")
    outputDirectory = traits.Either(traits.Bool, Directory, argstr = "--outputDirectory %s")
    outputVolume = traits.Str( argstr = "--outputVolume %s")
    smallGradientThreshold = traits.Float( argstr = "--smallGradientThreshold %f")
    writeProtocolGradientsFile = traits.Bool( argstr = "--writeProtocolGradientsFile ")
    useIdentityMeaseurementFrame = traits.Bool( argstr = "--useIdentityMeaseurementFrame ")
    useBMatrixGradientDirections = traits.Bool( argstr = "--useBMatrixGradientDirections ")


class DicomToNrrdConverterOutputSpec(TraitedSpec):
    outputDirectory = Directory(exists=True, argstr = "--outputDirectory %s")


class DicomToNrrdConverter(CommandLine):

    input_spec = DicomToNrrdConverterInputSpec
    output_spec = DicomToNrrdConverterOutputSpec
    _cmd = "/scratch/brains/BRAINS3-build/src/bin/DicomToNrrdConverter"
    _outputs_filenames = {'outputDirectory':'outputDirectory'}

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
        return super(DicomToNrrdConverter, self)._format_arg(name, spec, value)

