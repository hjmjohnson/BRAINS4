from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec, File, Directory, traits, isdefined
import os

class gtractInvertBSplineTransformInputSpec(CommandLineInputSpec):
    inputReferenceVolume = File( exists = "True",argstr = "--inputReferenceVolume %s")
    inputTransform = File( exists = "True",argstr = "--inputTransform %s")
    outputTransform = traits.Either(traits.Bool, File, argstr = "--outputTransform %s")
    landmarkDensity = traits.List(traits.Int, sep = ",",argstr = "--landmarkDensity %d")


class gtractInvertBSplineTransformOutputSpec(TraitedSpec):
    outputTransform = File(exists=True, argstr = "--outputTransform %s")


class gtractInvertBSplineTransform(CommandLine):

    input_spec = gtractInvertBSplineTransformInputSpec
    output_spec = gtractInvertBSplineTransformOutputSpec
    _cmd = " gtractInvertBSplineTransform "
    _outputs_filenames = {'outputTransform':'outputTransform.mat'}

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
        return super(gtractInvertBSplineTransform, self)._format_arg(name, spec, value)

