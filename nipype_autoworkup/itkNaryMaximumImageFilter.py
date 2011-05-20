import os

from nipype.interfaces.base import (CommandLine, CommandLineInputSpec,
                                    TraitedSpec, File,
                                    InputMultiPath, traits)
from nipype.utils.misc import isdefined
from nipype.utils.filemanip import fname_presuffix

class itkNaryMaximumImageFilterInputSpec(CommandLineInputSpec):
    inImageList = InputMultiPath(File(exists=True), argstr='%s...', sep=',', desc = "List of images", mandatory = True, position = 1)
    fileMode = traits.Str(argstr='%s', desc = "fileMode", exists = True, mandatory = True, position = 2)
    outFilename = File(argstr = '%s', desc = "output filename", position = 3, genfile=True)

class itkNaryMaximumImageFilterOutputSpec(TraitedSpec):
    outFilename = File(exists = True, desc = "outFilename")

class itkNaryMaximumImageFilter(CommandLine):
    input_spec = itkNaryMaximumImageFilterInputSpec
    output_spec = itkNaryMaximumImageFilterOutputSpec
    _cmd = "/scratch/brains/BRAINS3-build/src/bin/brains3 -b /raid0/homes/kpease/temp/itkWrapping/itkNaryMaximumImageFilter.tcl"

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


#from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
#import enthought.traits.api as traits
#import os
#from nipype.interfaces.traits import File
#from nipype.utils.misc import isdefined
#
#class itkNaryMaximumImageFilterInputSpec(CommandLineInputSpec):
#    inImageList = traits.List("traits.Str", sep=",", desc = "inImageList", exists = True, mandatory = True, position = 0)
#    fileMode = traits.Str(desc = "fileMode", exists = True, mandatory = True, position = 1)
#    outFilename = traits.Str(desc = "outFilename", exists = True, mandatory = True, position = 2)
#
#
#class itkNaryMaximumImageFilterOutputSpec(TraitedSpec):
#    outFilename = File(desc = "outFilename", exists = True, mandatory = True, position = 2)
#
#
#class itkNaryMaximumImageFilter(CommandLine):
#
#    input_spec = itkNaryMaximumImageFilterInputSpec
#    output_spec = itkNaryMaximumImageFilterOutputSpec
#    _cmd = "/scratch/brains/BRAINS3-build/src/bin/brains3 -b /raid0/homes/kpease/temp/itkWrapping/itkNaryMaximumImageFilter.tcl"
#    _outputs_filenames = {}
#
#    def _list_outputs(self):
#        outputs = self.output_spec().get()
#        for name in outputs.keys():
#            coresponding_input = getattr(self.inputs, name)
#            if isdefined(coresponding_input):
#                if isinstance(coresponding_input, bool) and coresponding_input == True:
#                    outputs[name] = os.path.abspath(self._outputs_filenames[name])
#                else:
#                    outputs[name] = coresponding_input
#        return outputs
#
#    def _format_arg(self, name, spec, value):
#        if name in self._outputs_filenames.keys():
#            if isinstance(value, bool):
#                if value == True:
#                    fname = os.path.abspath(self._outputs_filenames[name])
#                else:
#                    return ""
#            else:
#                fname = value
#            return spec.argstr % fname
#        return super(itkNaryMaximumImageFilter, self)._format_arg(name, spec, value)
#
#
