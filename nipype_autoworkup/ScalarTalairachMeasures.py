from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.base import File

class ScalarTalairachMeasuresInputSpec(CommandLineInputSpec):
    ScalarFileList = traits.List(argstr='%s', type="traits.File", sep=":", desc = "ScalarFileList", exists = True, mandatory = True, position = 0)
    BrainMaskFile = traits.List(argstr='%s', type="traits.File", sep=",", desc = "PassiveImagesToClip", exists = True, mandatory = True, position = 1)
    ClassImageFile = File(argstr='%s', desc = "ClassImageFile", exists = True, mandatory = True, position = 2)
    TalairachBounds = File(argstr='%s', desc = "TalairachBounds", exists = True, mandatory = True, position = 3)
    TalairachDir = traits.Directory(argstr='%s', desc = "TalairachDir", exists = True, mandatory = True, position = 4)
    PatientId = traits.Str(argstr='%s', desc = "PatientId", exists = True, mandatory = True, position = 5)
    ScanId = traits.Str(argstr='%s', desc = "ScanId", exists = True, mandatory = True, position = 6)
    ResultDir = traits.Directory(argstr='%s', desc = "ResultDir", exists = True, mandatory = True, position = 7)


class ScalarTalairachMeasuresOutputSpec(TraitedSpec):
    ResultDir = traits.Directory(desc = "ResultDir", exists = True)


class ScalarTalairachMeasures(CommandLine):

    input_spec = ScalarTalairachMeasuresInputSpec
    output_spec = ScalarTalairachMeasuresOutputSpec
    _cmd = "/scratch/brains/BRAINS3-build/src/bin/brains3 -b /raid0/homes/kpease/temp/itkWrapping/ScalarTalairachMeasures.tcl"
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
        return super(ScalarTalairachMeasures, self)._format_arg(name, spec, value)

