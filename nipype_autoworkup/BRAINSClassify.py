from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.base import File
from nipype.interfaces.base import Directory

class BRAINSClassifyInputSpec(CommandLineInputSpec):
    t1Volume = File( exists = "True",argstr = "--t1Volume %s")
    t2Volume = File( exists = "True",argstr = "--t2Volume %s")
    pdVolume = File( exists = "True",argstr = "--pdVolume %s")
    gmPlugs = File( exists = "True",argstr = "--gmPlugs %s")
    wmPlugs = traits.Either(traits.Bool, File, argstr = "--wmPlugs %s")
    csfPlugs = File( exists = "True",argstr = "--csfPlugs %s")
    bloodPlugs = File( exists = "True",argstr = "--bloodPlugs %s")
    BrainVolume = File( exists = "True",argstr = "--BrainVolume %s")
    classVolume = traits.Either(traits.Bool, File, argstr = "--classVolume %s")
    grossTrim = traits.Float( argstr = "--grossTrim %f")
    spatialTrim = traits.Float( argstr = "--spatialTrim %f")
    x = traits.Bool( argstr = "--x ")
    y = traits.Bool( argstr = "--y ")
    z = traits.Bool( argstr = "--z ")
    xx = traits.Bool( argstr = "--xx ")
    yy = traits.Bool( argstr = "--yy ")
    zz = traits.Bool( argstr = "--zz ")
    xy = traits.Bool( argstr = "--xy ")
    xz = traits.Bool( argstr = "--xz ")
    yz = traits.Bool( argstr = "--yz ")
    histogramEqualize = traits.Bool( argstr = "--histogramEqualize ")
    generateSeperateImages = traits.Bool( argstr = "--generateSeperateImages ")
    excludeVolume = File( exists = "True",argstr = "--excludeVolume %s")


class BRAINSClassifyOutputSpec(TraitedSpec):
    wmPlugs = File(exists=True, argstr = "--wmPlugs %s")
    classVolume = File(exists=True, argstr = "--classVolume %s")


class BRAINSClassify(CommandLine):

    input_spec = BRAINSClassifyInputSpec
    output_spec = BRAINSClassifyOutputSpec
    _cmd = "/scratch/brains/BRAINS3-build/src/bin/BRAINSClassify "
    _outputs_filenames = {'wmPlugs':'wmPlugs.nii','classVolume':'classVolume'}

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
        return super(BRAINSClassify, self)._format_arg(name, spec, value)

