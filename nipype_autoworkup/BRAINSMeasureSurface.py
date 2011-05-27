from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.base import File
from nipype.interfaces.base import Directory

class BRAINSMeasureSurfaceInputSpec(CommandLineInputSpec):
    inputSurface = File( exists = "True",argstr = "--inputSurface %s")
    arrayName = traits.Str( argstr = "--arrayName %s")
    labels = traits.List("traits.Str", sep = ",",argstr = "--labelNames %s")
    subjectId = traits.Str( argstr = "--subjectId %s")
    scanId = traits.Str( argstr = "--scanId %s")
    writeCsvFile = traits.Bool( argstr = "--writeCsvFile ")
    writeXmlFile = traits.Bool( argstr = "--writeXmlFile ")
    csvFile = traits.Either(traits.Bool, File, argstr = "--csvFile %s")
    xmlFile = traits.Either(traits.Bool, File, argstr = "--xmlFile %s")
    testDepth = traits.Bool( argstr = "--testDepth ")
    totalDepthResults = traits.List("traits.Float", sep = ",",argstr = "--totalDepthResults %f")
    gyralDepthResults = traits.List("traits.Float", sep = ",",argstr = "--gyralDepthResults %f")
    sulcalDepthResults = traits.List("traits.Float", sep = ",",argstr = "--sulcalDepthResults %f")
    testArea = traits.Bool( argstr = "--testArea ")
    totalAreaResults = traits.List("traits.Float", sep = ",",argstr = "--totalAreaResults %f")
    gyralAreaResults = traits.List("traits.Float", sep = ",",argstr = "--gyralAreaResults %f")
    sulcalAreaResults = traits.List("traits.Float", sep = ",",argstr = "--sulcalAreaResults %f")
    testCurvature = traits.Bool( argstr = "--testCurvature ")
    totalCurvatureResults = traits.List("traits.Float", sep = ",",argstr = "--totalCurvatureResults %f")
    gyralCurvatureResults = traits.List("traits.Float", sep = ",",argstr = "--gyralCurvatureResults %f")
    sulcalCurvatureResults = traits.List("traits.Float", sep = ",",argstr = "--sulcalCurvatureResults %f")


class BRAINSMeasureSurfaceOutputSpec(TraitedSpec):
    csvFile = File(exists=True, argstr = "--csvFile %s")
    xmlFile = File(exists=True, argstr = "--xmlFile %s")


class BRAINSMeasureSurface(CommandLine):

    input_spec = BRAINSMeasureSurfaceInputSpec
    output_spec = BRAINSMeasureSurfaceOutputSpec
    _cmd = "/scratch/brains/BRAINS3-build/src/bin/BRAINSMeasureSurface "
    _outputs_filenames = {'xmlFile':'xmlFile','csvFile':'csvFile'}

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
        return super(BRAINSMeasureSurface, self)._format_arg(name, spec, value)

