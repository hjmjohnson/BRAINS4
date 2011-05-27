from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.base import File

class itkOrImageInputSpec(CommandLineInputSpec):
    inFilename1 = File(argstr='%s', desc = "inFilename1", exists = True, mandatory = True, position = 0)
    inFilename2 = File(argstr='%s', desc = "inFilename2", exists = True, mandatory = True, position = 1)
    fileMode = traits.Str(argstr='%s', desc = "fileMode", exists = True, mandatory = True, position = 2)
    outFilename = traits.Str(argstr='%s', desc = "outFilename", exists = True, mandatory = True, position = 3)

class itkOrImageOutputSpec(TraitedSpec):
    outFilename = File(exists = True, desc = "outFilename")

class itkOrImage(CommandLine):
    input_spec = itkOrImageInputSpec
    output_spec = itkOrImageOutputSpec
    _cmd = "/scratch/brains/BRAINS3-build/src/bin/brains3 -b /raid0/homes/kpease/temp/itkWrapping/itkOrImage.tcl"

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


