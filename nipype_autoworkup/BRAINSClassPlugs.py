from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.traits import File
from nipype.interfaces.traits import Directory
from nipype.utils.misc import isdefined

class BRAINSClassPlugsInputSpec(CommandLineInputSpec):
    t1Volume = File( exists = "True",argstr = "--t1Volume %s")
    t2Volume = File( exists = "True",argstr = "--t2Volume %s")
    pdVolume = File( exists = "True",argstr = "--pdVolume %s")
    searchVolume = File( exists = "True",argstr = "--searchVolume %s")
    gmPlugs = traits.Either(traits.Bool, File, argstr = "--gmPlugs %s")
    wmPlugs = traits.Either(traits.Bool, File, argstr = "--wmPlugs %s")
    csfPlugs = traits.Either(traits.Bool, File, argstr = "--csfPlugs %s")
    plugClassNames = traits.List("traits.Str", sep = ",",argstr = "--plugClassNames %s")
    t1ClassMeans = traits.List("traits.Float", sep = ",",argstr = "--t1ClassMeans %f")
    t2ClassMeans = traits.List("traits.Float", sep = ",",argstr = "--t2ClassMeans %f")
    pdClassMeans = traits.List("traits.Float", sep = ",",argstr = "--pdClassMeans %f")
    randomSeed = traits.Int( argstr = "--randomSeed %d")
    numberOfPlugs = traits.Int( argstr = "--numberOfPlugs %d")
    coverage = traits.Float( argstr = "--coverage %f")
    permissiveness = traits.Float( argstr = "--permissiveness %f")
    meanOutlier = traits.Float( argstr = "--meanOutlier %f")
    varOutlier = traits.Float( argstr = "--varOutlier %f")
    plugSize = traits.Float( argstr = "--plugSize %f")
    partitions = traits.List("traits.Int", sep = ",",argstr = "--partitions %d")
    numberOfClassPlugs = traits.List("traits.Int", sep = ",",argstr = "--numberOfClassPlugs %d")
    bloodMode = traits.Enum("Manual","Top","Bottom", argstr = "--bloodMode %s")
    bloodImage = traits.Enum("T1","T2","PD", argstr = "--bloodImage %s")
    vbPlugs = File( exists = "True",argstr = "--vbPlugs %s")


class BRAINSClassPlugsOutputSpec(TraitedSpec):
    gmPlugs = File(exists=True, argstr = "--gmPlugs %s")
    wmPlugs = File(exists=True, argstr = "--wmPlugs %s")
    csfPlugs = File(exists=True, argstr = "--csfPlugs %s")


class BRAINSClassPlugs(CommandLine):

    input_spec = BRAINSClassPlugsInputSpec
    output_spec = BRAINSClassPlugsOutputSpec
    _cmd = "/scratch/brains/BRAINS3-build/src/bin/BRAINSClassPlugs "
    _outputs_filenames = {'gmPlugs':'gmPlugs.nii','wmPlugs':'wmPlugs.nii','csfPlugs':'csfPlugs.nii'}

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
        return super(BRAINSClassPlugs, self)._format_arg(name, spec, value)

