from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.traits import File
from nipype.interfaces.traits import Directory
from nipype.utils.misc import isdefined

class BRAINSTalairachInputSpec(CommandLineInputSpec):
    AC = traits.List("traits.Float", sep = ",",argstr = "--AC %f")
    ACisIndex = traits.Bool( argstr = "--ACisIndex ")
    PC = traits.List("traits.Float", sep = ",",argstr = "--PC %f")
    PCisIndex = traits.Bool( argstr = "--PCisIndex ")
    SLA = traits.List("traits.Float", sep = ",",argstr = "--SLA %f")
    SLAisIndex = traits.Bool( argstr = "--SLAisIndex ")
    IRP = traits.List("traits.Float", sep = ",",argstr = "--IRP %f")
    IRPisIndex = traits.Bool( argstr = "--IRPisIndex ")
    inputVolume = File( exists = "True",argstr = "--inputVolume %s")
    outputBox = traits.Either(traits.Bool, File, argstr = "--outputBox %s")
    outputGrid = traits.Either(traits.Bool, File, argstr = "--outputGrid %s")


class BRAINSTalairachOutputSpec(TraitedSpec):
    outputBox = File(exists=True, argstr = "--outputBox %s")
    outputGrid = File(exists=True, argstr = "--outputGrid %s")


class BRAINSTalairach(CommandLine):

    input_spec = BRAINSTalairachInputSpec
    output_spec = BRAINSTalairachOutputSpec
    _cmd = "/scratch/brains/BRAINS3-build/src/bin/BRAINSTalairach "
    _outputs_filenames = {'outputGrid':'outputGrid','outputBox':'outputBox'}

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
        return super(BRAINSTalairach, self)._format_arg(name, spec, value)

