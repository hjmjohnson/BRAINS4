from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.traits import File
from nipype.utils.misc import isdefined

class itkRelabelComponentImageInputSpec(CommandLineInputSpec):
    inFilename = File(argstr='%s', desc = "inFilename", exists = True, mandatory = True, position = 0)
    fileMode = traits.Str(argstr='%s', desc = "fileMode", exists = True, mandatory = True, position = 1)
    val = traits.Int(argstr='%s', desc = "val", exists = True, mandatory = True, position = 2)
    outFilename = traits.Str(argstr='%s', desc = "outFilename", exists = True, mandatory = True, position = 3)

class itkRelabelComponentImageOutputSpec(TraitedSpec):
    outFilename = File(exists = True, desc = "outFilename")

class itkRelabelComponentImage(CommandLine):

    input_spec = itkRelabelComponentImageInputSpec
    output_spec = itkRelabelComponentImageOutputSpec
    _cmd = "/scratch/brains/BRAINS3-build/src/bin/brains3 -b /raid0/homes/kpease/temp/itkWrapping/itkRelabelComponentImage.tcl"

    def _gen_outfilename(self):
        outfile = self.inputs.outFilename
        if not isdefined(outfile):
            outfile = fname_presuffix(self.inputs.inImageList[0],suffix='_out')
        return outfile

    def _gen_filename(self, name):
        if name == 'outFilename':
            return self._gen_outfilename()
        return None

    def _list_outputs(self):
        outputs = self.output_spec().get()
        outputs['outFilename'] = self._gen_outfilename()
        return outputs
