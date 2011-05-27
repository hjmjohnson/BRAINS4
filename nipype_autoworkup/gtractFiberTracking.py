from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.base import File
from nipype.interfaces.base import Directory


class gtractFiberTrackingInputSpec(CommandLineInputSpec):
	inputTensorVolume = File( exists = "True",argstr = "--inputTensorVolume %s")
	inputAnisotropyVolume = File( exists = "True",argstr = "--inputAnisotropyVolume %s")
	inputStartingSeedsLabelMapVolume = File( exists = "True",argstr = "--inputStartingSeedsLabelMapVolume %s")
	startingSeedsLabel = traits.Int( argstr = "--startingSeedsLabel %d")
	inputEndingSeedsLabelMapVolume = File( exists = "True",argstr = "--inputEndingSeedsLabelMapVolume %s")
	endingSeedsLabel = traits.Int( argstr = "--endingSeedsLabel %d")
	inputTract = traits.Str( argstr = "--inputTract %s")
	outputTract = traits.Str( argstr = "--outputTract %s")
	writeXMLPolyDataFile = traits.Bool( argstr = "--writeXMLPolyDataFile ")
	trackingMethod = traits.Enum("Guided","Free","Streamline","GraphSearch", argstr = "--trackingMethod %s")
	guidedCurvatureThreshold = traits.Float( argstr = "--guidedCurvatureThreshold %f")
	maximumGuideDistance = traits.Float( argstr = "--maximumGuideDistance %f")
	seedThreshold = traits.Float( argstr = "--seedThreshold %f")
	trackingThreshold = traits.Float( argstr = "--trackingThreshold %f")
	curvatureThreshold = traits.Float( argstr = "--curvatureThreshold %f")
	branchingThreshold = traits.Float( argstr = "--branchingThreshold %f")
	maximumBranchPoints = traits.Int( argstr = "--maximumBranchPoints %d")
	useRandomWalk = traits.Bool( argstr = "--useRandomWalk ")
	randomSeed = traits.Int( argstr = "--randomSeed %d")
	branchingAngle = traits.Float( argstr = "--branchingAngle %f")
	minimumLength = traits.Float( argstr = "--minimumLength %f")
	maximumLength = traits.Float( argstr = "--maximumLength %f")
	stepSize = traits.Float( argstr = "--stepSize %f")
	useLoopDetection = traits.Bool( argstr = "--useLoopDetection ")
	useTend = traits.Bool( argstr = "--useTend ")
	tendF = traits.Float( argstr = "--tendF %f")
	tendG = traits.Float( argstr = "--tendG %f")


class gtractFiberTrackingOutputSpec(TraitedSpec):


class gtractFiberTracking(CommandLine):

    input_spec = gtractFiberTrackingInputSpec
    output_spec = gtractFiberTrackingOutputSpec
    _cmd = "Slicer3 --launch gtractFiberTracking "
    _outputs_filenames = {}

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
        return super(gtractFiberTracking, self)._format_arg(name, spec, value)

