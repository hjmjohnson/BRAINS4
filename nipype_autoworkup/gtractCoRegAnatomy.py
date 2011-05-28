from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.base import File
from nipype.interfaces.base import Directory


class gtractCoRegAnatomyInputSpec(CommandLineInputSpec):
	inputVolume = File( exists = "True",argstr = "--inputVolume %s")
	inputAnatomicalVolume = File( exists = "True",argstr = "--inputAnatomicalVolume %s")
	vectorIndex = traits.Int( argstr = "--vectorIndex %d")
	inputRigidTransform = File( exists = "True",argstr = "--inputRigidTransform %s")
	outputTransformName = traits.Either(traits.Bool, File, argstr = "--outputTransformName %s")
	transformType = traits.Enum("Rigid","Bspline", argstr = "--transformType %s")
	numberOfIterations = traits.Int( argstr = "--numberOfIterations %d")
	gridSize = traits.List("traits.Int", sep = ",",argstr = "--gridSize %d")
	borderSize = traits.Int( argstr = "--borderSize %d")
	numberOfHistogramBins = traits.Int( argstr = "--numberOfHistogramBins %d")
	spatialScale = traits.Int( argstr = "--spatialScale %d")
	convergence = traits.Float( argstr = "--convergence %f")
	gradientTolerance = traits.Float( argstr = "--gradientTolerance %f")
	maxBSplineDisplacement = traits.Float( argstr = "--maxBSplineDisplacement %f")
	maximumStepSize = traits.Float( argstr = "--maximumStepSize %f")
	minimumStepSize = traits.Float( argstr = "--minimumStepSize %f")
	translationScale = traits.Float( argstr = "--translationScale %f")
	relaxationFactor = traits.Float( argstr = "--relaxationFactor %f")
	numberOfSamples = traits.Int( argstr = "--numberOfSamples %d")
	useMomentsAlign = traits.Bool( argstr = "--useMomentsAlign ")
	useGeometryAlign = traits.Bool( argstr = "--useGeometryAlign ")
	useCenterOfHeadAlign = traits.Bool( argstr = "--useCenterOfHeadAlign ")


class gtractCoRegAnatomyOutputSpec(TraitedSpec):
	outputTransformName = File(exists=True, argstr = "--outputTransformName %s")


class gtractCoRegAnatomy(CommandLine):

    input_spec = gtractCoRegAnatomyInputSpec
    output_spec = gtractCoRegAnatomyOutputSpec
    _cmd = "Slicer3 --launch gtractCoRegAnatomy "
    _outputs_filenames = {'outputTransformName':'outputTransformName.mat'}

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
        return super(gtractCoRegAnatomy, self)._format_arg(name, spec, value)
