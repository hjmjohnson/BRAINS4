from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.base import File


class itkObjectMorphologyInputSpec(CommandLineInputSpec):
    inFilename = File(argstr='%s', desc = "inFilename", exists = True, mandatory = True, position = 0)
    fileMode = traits.Str(argstr='%s', desc = "fileMode", exists = True, mandatory = True, position = 1)
    var1 = traits.String(argstr='%s', desc = "var1", exists = True, mandatory = True, position = 2)
    var2 = traits.String(argstr='%s', desc = "var2", exists = True, mandatory = True, position = 3)
    radius = traits.List(argstr='%s', type = "traits.Float", sep = ",", desc = "radius", exists = True, mandatory = True, position = 4)
    var3 = traits.Int(argstr='%s', desc = "var3", exists = True, mandatory = True, position = 5)
    outFilename = traits.Str(argstr='%s', desc = "outFilename", exists = True, mandatory = True, position = 6)

class itkObjectMorphologyOutputSpec(TraitedSpec):
    outFilename = File(exists = True, desc = "outFilename")

class itkObjectMorphology(CommandLine):
    input_spec = itkObjectMorphologyInputSpec
    output_spec = itkObjectMorphologyOutputSpec
    _cmd = "/scratch/brains/BRAINS3-build/src/bin/brains3 -b /raid0/homes/kpease/temp/itkWrapping/itkObjectMorphology.tcl"

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


