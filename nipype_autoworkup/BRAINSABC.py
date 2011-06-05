from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec, File, Directory, traits, isdefined
import os

class BRAINSABCInputSpec(CommandLineInputSpec):
    inputVolumes = traits.List(File(exists=True), argstr = "----inputVolumes %s...")
    atlasDef = File( exists = "True",argstr = "----atlasDefinition %s")
    inputVolumeTypes = traits.List(traits.Str, sep = ",",argstr = "----inputVolumeTypes %s")
    outputDir = traits.Either(traits.Bool, Directory, argstr = "--outputDir %s")
    atlasToSubjectTransformType = traits.Enum("ID","Rigid","Affine","BSpline", argstr = "--atlasToSubjectTransformType %s")
    subjectIntermodeTransformType = traits.Enum("ID","Rigid","Affine","BSpline", argstr = "--subjectIntermodeTransformType %s")
    outputFormat = traits.Enum("NIFTI","Meta","Nrrd", argstr = "--outputFormat %s")
    resamplerInterpolatorType = traits.Enum("BSpline","NearestNeighbor","WindowedSinc","Linear","ResampleInPlace", argstr = "--interpolationMode %s")
    maxIterations = traits.Int( argstr = "--maxIterations %d")
    medianFilterSize = traits.List(traits.Int, sep = ",",argstr = "--medianFilterSize %d")
    filterIteration = traits.Int( argstr = "--filterIteration %d")
    filterTimeStep = traits.Float( argstr = "--filterTimeStep %f")
    filterMethod = traits.Enum("None","CurvatureFlow","GradientAnisotropicDiffusion","Median", argstr = "--filterMethod %s")
    maxBiasDegree = traits.Int( argstr = "--maxBiasDegree %d")
    atlasWarpingOff = traits.Bool( argstr = "--atlasWarpingOff ")
    gridSize = traits.List(traits.Int, sep = ",",argstr = "--gridSize %d")
    defaultSuffix = traits.Str( argstr = "----defaultSuffix %s")
    debuglevel = traits.Int( argstr = "----debuglevel %d")
    writeLess = traits.Bool( argstr = "----writeLess ")


class BRAINSABCOutputSpec(TraitedSpec):
    outputDir = Directory(exists=True, argstr = "--outputDir %s")


class BRAINSABC(CommandLine):

    input_spec = BRAINSABCInputSpec
    output_spec = BRAINSABCOutputSpec
    _cmd = " BRAINSABC "
    _outputs_filenames = {'outputDir':'outputDir'}

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
        return super(BRAINSABC, self)._format_arg(name, spec, value)

