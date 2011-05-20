from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.traits import File
from nipype.utils.misc import isdefined

class PickBloodPlugsFromMarginInputSpec(CommandLineInputSpec):
    brainMaskFile = File(argstr='%s', desc = "BrainMaskFile", exists = True, mandatory = True, position = 0)
    T1File = File(argstr='%s', desc = "T1File", exists = True, mandatory = True, position = 1)
    T2File = File(argstr='%s', desc = "T2File", exists = True, mandatory = True, position = 2)
    PDFile = traits.Str(argstr='%s', desc = "PDFile", exists = True, mandatory = True, position = 3)
    emsLabelImage = File(argstr='%s', desc = "EmsLabelImage", exists = True, mandatory = True, position = 4)
    VbPlugFile = traits.Str(argstr='%s', desc = "VbPlugFile", exists = True, mandatory = True, position = 5)

class PickBloodPlugsFromMarginOutputSpec(TraitedSpec):
    VbPlugFile = File(desc = "VbPlugFile", exists = True)

class PickBloodPlugsFromMargin(CommandLine):

    input_spec = PickBloodPlugsFromMarginInputSpec
    output_spec = PickBloodPlugsFromMarginOutputSpec
    _cmd = "/scratch/brains/BRAINS3-build/src/bin/brains3 -b /raid0/homes/kpease/temp/itkWrapping/PickBloodPlugsFromMargin.tcl"

    def _gen_outfilename(self):
        outfile = self.inputs.VbPlugFile
        if not isdefined(outfile):
            outfile = fname_presuffix(self.inputs.inImageList[0],suffix='_out')
        return outfile

    def _gen_filename(self, name):
        if name == 'VbPlugFile':
            return self._gen_outfilename()
        return None

    def _list_outputs(self):
        outputs = self.output_spec().get()
        outputs['VbPlugFile'] = self._gen_outfilename()
        return outputs
