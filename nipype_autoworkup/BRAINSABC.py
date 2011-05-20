from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os, string
from nipype.interfaces.traits import File
from nipype.interfaces.traits import Directory
from nipype.utils.misc import isdefined

def rootname(path):
  splits = os.path.basename(path).split(".")
  if len(splits) > 1:
    return string.join(splits[:-1], ".")
  else:
    return splits[0]

def extension(path):
  splits = os.path.basename(path).split(".")
  if len(splits) > 1:
    return splits[-1]
  else:
    return ""

def GetExtensionlessBaseName(filename):
  basename = os.path.basename(filename)
  currExt = extension(basename)
#  open("/tmp/blah", "w").write(filename + "\n" + basename + "\n" + currExt + "\n" + rootname(basename) + "\n" + rootname(rootname(basename)))
  if currExt == "gz":
    return rootname(rootname(basename))
  else:
    return rootname(basename)


class BRAINSABCInputSpec(CommandLineInputSpec):
    inputVolumes = traits.List(type="traits.File", sep=",", exists = "True",argstr = "--inputVolumes %s")
    atlasDef = File( exists = "True",argstr = "--atlasDefinition %s")
    inputVolumeTypes = traits.List("traits.Str", sep = ",",argstr = "--inputVolumeTypes %s")
    outputDir = traits.Either(traits.Bool, traits.Directory, argstr = "--outputDir %s")
    atlasToSubjectTransformType = traits.Enum("ID","Rigid","Affine","BSpline", argstr = "--atlasToSubjectTransformType %s")
    subjectIntermodeTransformType = traits.Enum("ID","Rigid","Affine","BSpline", argstr = "--subjectIntermodeTransformType %s")
    outputFormat = traits.Enum("NIFTI","Meta","Nrrd", argstr = "--outputFormat %s")
    resamplerInterpolatorType = traits.Enum("BSpline","WindowedSinc","Linear", argstr = "--interpolatorType %s")
    filterIteration = traits.Int( argstr = "--filterIteration %d")
    maxIterations = traits.Int( argstr = "--maxIterations %d")
    filterTimeStep = traits.Float( argstr = "--filterTimeStep %f")
    filterMethod = traits.Enum("Curvature flow","Grad aniso diffusion", argstr = "--filterMethod %s")
    maxBiasDegree = traits.Int( argstr = "--maxBiasDegree %d")
    atlasWarpingOff = traits.Bool( argstr = "--atlasWarpingOff ")
    gridSize = traits.List("traits.Int", sep = ",",argstr = "--gridSize %d")
    defaultSuffix = traits.Str( argstr = "--defaultSuffix %s")
    debuglevel = traits.Int( argstr = "--debuglevel %d")
    writeLess = traits.Bool( argstr = "--writeLess ")


class BRAINSABCOutputSpec(TraitedSpec):
    outputDir = Directory()
    emsLabelImage = File()


class BRAINSABC(CommandLine):

    input_spec = BRAINSABCInputSpec
    output_spec = BRAINSABCOutputSpec
    _cmd = "/scratch/brains/BRAINS3-build/src/bin/BRAINSABC "
    _outputs_filenames = {'outputDir':'outputDir'}

    def _list_outputs(self):
        outputs = self.output_spec().get()
        for name in outputs.keys():
            try:
              coresponding_input = getattr(self.inputs, name)
              if isdefined(coresponding_input):
                  if isinstance(coresponding_input, bool) and coresponding_input == True:
                      outputs[name] = os.path.abspath(self._outputs_filenames[name])
                  else:
                      outputs[name] = coresponding_input
            except AttributeError:
              pass
        outputs["emsLabelImage"] = self.inputs.outputDir + "/" + GetExtensionlessBaseName(self.inputs.inputVolumes[0]) + "_labels_BRAINSABC.nii.gz"
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

