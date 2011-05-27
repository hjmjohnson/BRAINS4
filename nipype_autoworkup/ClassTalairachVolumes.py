from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.base import File
from nipype.interfaces.base import Directory

class ClassTalairachVolumesInputSpec(CommandLineInputSpec):
    brainMaskFile = File(argstr='%s', desc = "BrainMaskFile", exists = True, mandatory = True, position = 0)
    classImageFile = File(argstr='%s', desc = "ClassImageFile", exists = True, mandatory = True, position = 1)
    discreteImageFile = File(argstr='%s', desc = "DiscreteImageFile", exists = True, mandatory = True, position = 2)
    talairachBounds = File(argstr='%s', desc = "TalairchBounds", exists = True, mandatory = True, position = 3)
    talairachDir = Directory(argstr='%s', desc = "TalairachDir", exists = True, mandatory = True, position = 4)
    patientId = traits.Str(argstr='%s', desc = "PatientID", exists = True, mandatory = True, position = 5)
    scanId = traits.Str(argstr='%s', desc = "ScanId", exists = True, mandatory = True, position = 6)
    resultDir = Directory(argstr='%s', desc = "ResultDir", exists = True, mandatory = True, position = 7)


class ClassTalairachVolumesOutputSpec(TraitedSpec):
    ResultDir = Directory(desc = "ResultDir", exists = True)


class ClassTalairachVolumes(CommandLine):

    input_spec = ClassTalairachVolumesInputSpec
    output_spec = ClassTalairachVolumesOutputSpec
    _cmd = "/scratch/brains/BRAINS3-build/src/bin/brains3 -b /raid0/homes/kpease/temp/itkWrapping/ClassTalairachVolumes.tcl "
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
        return super(ClassTalairachVolumes, self)._format_arg(name, spec, value)

