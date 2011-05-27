#!/usr/bin/python
#
#################################################################################
## Program:   BRAINS (Brain Research: Analysis of Images, Networks, and Systems)
## Module:    $RCSfile: $
## Language:  Python
## Date:      $Date:  $
## Version:   $Revision: $
##
##   Copyright (c) Iowa Mental Health Clinical Research Center. All rights reserved.
##   See BRAINSCopyright.txt or http:/www.psychiatry.uiowa.edu/HTML/Copyright.html
##   for details.
##
##      This software is distributed WITHOUT ANY WARRANTY; without even
##      the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
##      PURPOSE.  See the above copyright notices for more information.
##
#################################################################################

import nipype.interfaces.io as nio           # Data i/o
import nipype.interfaces.spm as spm          # spm
import nipype.interfaces.matlab as mlab      # how to run matlab
import nipype.interfaces.fsl as fsl          # fsl
import nipype.interfaces.utility as util     # utility
import nipype.pipeline.engine as pe          # pypeline engine
import nipype.algorithms.rapidart as ra      # artifact detection
import nipype.algorithms.modelgen as model   # model specification
import enthought.traits.api as traits

from nipype.interfaces.base import BaseInterface, TraitedSpec

from BRAINSConstellationDetector import *
"""
from AutoTalairachParameters import *
from BRAINSABC import *
from BRAINSApplySurfaceLabels import *
from BRAINSClassify import *
from BRAINSClassPlugs import *
from BRAINSCut import *
from BRAINSDemonWarp import *
from BRAINSDiscreteClass import *
from BRAINSFit import *
from BRAINSMeasureSurface import *
from BRAINSMush import *
from BRAINSResample import *
from BRAINSROIAuto import *
from BRAINSTalairachMask import *
from BRAINSTalairach import *
from ClassTalairachVolumes import *
from ClipAndAverageTwo import *
from CreateAutoLabelBrainSurface import *
from CreateBrainSurface import *
from CreateGenusZeroBrainSurface import *
from DicomToNrrdConverter import *
from DtiSkullStripB0 import *
from extractNrrdVectorIndex import *
from GenerateSummedGradientImage import *
from gtractAnisotropyMap import *
from gtractConcatDwi import *
from gtractCoregBvalues import *
from gtractTensor import *
from itkAndImage import *
from itkBinaryImageMorphology import *
from itkBinaryThresholdImage import *
from itkConstantImageMath import *
from itkMaskImage import *
from itkNaryMaximumImageFilter import *
from itkObjectMorphology import *
from itkOrImage import *
from itkRelabelComponentImage import *
from N4ITK import *
from PickBloodPlugsFromMargin import *
from QuadMeshDecimation import *
from QuadMeshSmoothing import *
from runBRAINSCut import *
from ScalarTalairachMeasures import *
from StandardizeImageIntensity import *
"""

import os, sys, string, shutil, glob, re


# Set BrainsConfig variables

BRAINS_BIN_DIR=os.environ["BRAINS_BIN_DIR"]

AutoWorkupVersion = "110"
T1ACPCModelFile = BRAINS_BIN_DIR + "/T1.mdl"
T2ACPCModelFile = BRAINS_BIN_DIR + "/T2.mdl"
TalairachDir = BRAINS_BIN_DIR + "/talairach"
EmsAtlasDir = BRAINS_BIN_DIR + "/Atlas/BRAINSABC"
BRAINSABCAtlasDir = BRAINS_BIN_DIR + "/Atlas/Atlas_20101105"
BRAINSANNDir = BRAINS_BIN_DIR + "/Atlas/ANN_2010_Beta"
IplFlag = "1"
GlobalDataDir = "/raid0/data/new_data/brains3"
GtractVersion = "GTRACT_v4.0"

#NOTICE!  This wasn't defined previously!!
EarlierAtlasDir = BRAINSABCAtlasDir

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
  if currExt == "gz":
    return rootname(rootname(basename))
  else:
    return rootname(basename)

def ConstellationBasename(image):
  return os.path.basename(rootname(rootname(image)))

def count_files(list_of_files):
  return range(len(list_of_files))

# ---
# NODE: GenerateT1T2ImageList
#  * Combine a list of T1 and T2 images, and make a separate T1/T2 type list.
#

class GenerateT1T2ImageListInputSpec(TraitedSpec):
  open("/tmp/blah", "a").write("UUUUUU\n")
  T1ImageList = traits.List(type="traits.File", sep=",", exists=True, mandatory=True)
  T2ImageList = traits.List(type="traits.File", sep=",", exists=True, mandatory=True)

class GenerateT1T2ImageListOutputSpec(TraitedSpec):
  open("/tmp/blah", "a").write("VVVVVV\n")
  outputList = traits.List(type="traits.File")
  outputTypesList = traits.List(type="traits.File")

class GenerateT1T2ImageList(BaseInterface):
  open("/tmp/blah", "a").write("WWWWWW\n")
  input_spec = GenerateT1T2ImageListInputSpec
  output_spec = GenerateT1T2ImageListOutputSpec

  def _run_interface(self, runtime):
#    self._outputList = ""
#    self._outputTypesList = ""
    self._outputTypesList = []
    for Image in self.inputs.T1ImageList:
#      self._outputList += "," + Image
#      self._outputTypesList += ",T1"
      self._outputTypesList.append("T1")
    for Image in self.inputs.T2ImageList:
#      self._outputList += "," + Image
#      self._outputTypesList += ",T2"
      self._outputTypesList.append("T2")
#    self._outputList = self._outputList[1:]
    self._outputList = self.inputs.T1ImageList + self.inputs.T2ImageList
#    self._outputTypesList = self._outputTypesList[1:]
    open("/tmp/blah", "a").write("XXXXXX " + str(self._outputList) + "\n")
    runtime.returncode = 0
    return runtime

  def _list_outputs(self):
    open("/tmp/blah", "a").write("YYYYYY " + str(self._outputList) + "\n")
    outputs = self._outputs().get()
    outputs["outputList"] = self._outputList
    outputs["outputTypesList"] = self._outputTypesList
    return outputs

# ---
# NODE: GenerateT1T2ImageList
#  * Figures out what files are generated by BRAINSABC so that we can link them into the pipeline, since BRAINSABC doesn't output them.  :P
#  * !!!!!NOTICE!!!!! :: If BRAINSABC changes what files it needs to generate, this will NOT auto-update!  You must update it here as well.
#

class GenerateCorrectedImageFilenamesInputSpec(TraitedSpec):
  outputDir = traits.Str(exists=True, mandatory=True)
  T1AcpcImageList = traits.List(type="traits.File", sep=",", exists=True, mandatory=True)
  T2AcpcImageList = traits.List(type="traits.File", sep=",", exists=True, mandatory=True)

class GenerateCorrectedImageFilenamesOutputSpec(TraitedSpec):
  T1BaseName = traits.Str()
  T2BaseName = traits.Str()
  T1CorrectedImageFileNames = traits.List(type="traits.File", sep=",")
  T2CorrectedImageFileNames = traits.List(type="traits.File", sep=",")

class GenerateCorrectedImageFilenames(BaseInterface):
  input_spec = GenerateCorrectedImageFilenamesInputSpec
  output_spec = GenerateCorrectedImageFilenamesOutputSpec

  def _run_interface(self, runtime):
    self._T1CorrectedImageFileNames = []
    self._T2CorrectedImageFileNames = []
    for Image in self.inputs.T1AcpcImageList:
      self._T1BaseName = GetExtensionlessBaseName(Image)
      self._T1CorrectedImageFileNames.append(self.inputs.outputDir + "/" + self._T1BaseName + "_corrected_BRAINSABC.nii.gz")
    for Image in self.inputs.T2AcpcImageList:
      self._T2BaseName = GetExtensionlessBaseName(Image)
      self._T2CorrectedImageFileNames.append(self.inputs.outputDir + "/" + self._T2BaseName + "_corrected_BRAINSABC.nii.gz")
    runtime.returncode = 0
    return runtime

  def _list_outputs(self):
     outputs = self._outputs().get()
     outputs["T1BaseName"] = self._T1BaseName
     outputs["T1CorrectedImageFileNames"] = self._T1CorrectedImageFileNames
     outputs["T2BaseName"] = self._T2BaseName
     outputs["T2CorrectedImageFileNames"] = self._T2CorrectedImageFileNames
     return outputs


# ---
# NODE: GenerateBRAINSCutMaps
#  * Creates the image, atlas, and probability maps for BRAINSCut.
#

class GenerateBRAINSCutMapsInputSpec(TraitedSpec):
  resultDir = traits.Str(exists=True, mandatory=True)
  T1Image = traits.File(exists=True, mandatory=True)
  T2Image = traits.File(exists=True, mandatory=True)
  SGImage = traits.File(exists=True, mandatory=True)
  atlasDir = traits.Str(exists=True, mandatory=True)
  scanId = traits.Str(exists=True, mandatory=True)
  annDir= traits.Str(exists=True, mandatory=True)

class GenerateBRAINSCutMapsOutputSpec(TraitedSpec):
  imageMap = traits.Str()
  atlasMap = traits.Str()
  caudateProbabilityMap = traits.Str()
  caudateXml = traits.Str()
  leftCaudate = traits.Str()
  rightCaudate = traits.Str()
  caudateList = traits.Str()
  putamenProbabilityMap = traits.Str()
  putamenXml = traits.Str()
  leftPutamen = traits.Str()
  rightPutamen = traits.Str()
  putamenList = traits.Str()
  thalamusProbabilityMap = traits.Str()
  thalamusXml = traits.Str()
  leftThalamus = traits.Str()
  rightThalamus = traits.Str()
  thalamusList = traits.Str()
  hippocampusProbabilityMap = traits.Str()
  hippocampusXml = traits.Str()
  leftHippocampus = traits.Str()
  rightHippocampus = traits.Str()
  hippocampusList = traits.Str()
  accumbensProbabilityMap = traits.Str()
  accumbensXml = traits.Str()
  leftAccumbens = traits.Str()
  rightAccumbens = traits.Str()
  accumbensList = traits.Str()
  globusProbabilityMap = traits.Str()
  globusXml = traits.Str()
  leftGlobus = traits.Str()
  rightGlobus = traits.Str()
  globusList = traits.Str()

class GenerateBRAINSCutMaps(BaseInterface):
  input_spec = GenerateBRAINSCutMapsInputSpec
  output_spec = GenerateBRAINSCutMapsOutputSpec

  def _run_interface(self, runtime):
    self._imageMap = "T1," + self.inputs.T1Image + ":T2," + self.inputs.T2Image + ":SG," + self.inputs.SGImage
    self._atlasMap = "T1," + self.inputs.atlasDir + "/template_t1.nii.gz:T2,na:SG,na"
    self._caudateProbabilityMap = "l_caudate," + self.inputs.annDir + "/l_caudate_ProbabilityMap.nii.gz:r_caudate," + self.inputs.annDir + "/r_caudate_ProbabilityMap.nii.gz"
    self._caudateXml = self.inputs.resultDir + "/" + self.inputs.scanId + "caudate.xml"
    self._leftCaudate = self.inputs.resultDir + "/" + self.inputs.scanId + "_l_caudate_ANN.nii.gz"
    self._rightCaudate = self.inputs.resultDir + "/" + self.inputs.scanId + "_r_caudate_ANN.nii.gz"
    self._caudateList = self._leftCaudate + "," + self._rightCaudate
    self._putamenProbabilityMap = "l_putamen," + self.inputs.annDir + "/l_putamen_ProbabilityMap.nii.gz:" + "r_putamen," + self.inputs.annDir + "/r_putamen_ProbabilityMap.nii.gz"
    self._putamenXml = self.inputs.resultDir + "/" + self.inputs.scanId + "putamen.xml"
    self._leftPutamen = self.inputs.resultDir + "/" + self.inputs.scanId + "_l_putamen_ANN.nii.gz"
    self._rightPutamen = self.inputs.resultDir + "/" + self.inputs.scanId + "_r_putamen_ANN.nii.gz"
    self._putamenList = self._leftPutamen + "," + self._rightPutamen
    self._thalamusProbabilityMap = "l_thalamus," + self.inputs.annDir + "/l_thalamus_ProbabilityMap.nii.gz:" + "r_thalamus," + self.inputs.annDir + "/r_thalamus_ProbabilityMap.nii.gz"
    self._thalamusXml = self.inputs.resultDir + "/" + self.inputs.scanId + "thalamus.xml"
    self._leftThalamus = self.inputs.resultDir + "/" + self.inputs.scanId + "_l_thalamus_ANN.nii.gz"
    self._rightThalamus = self.inputs.resultDir + "/" + self.inputs.scanId + "_r_thalamus_ANN.nii.gz"
    self._thalamusList = self._leftThalamus + "," + self._rightThalamus
    self._hippocampusProbabilityMap = "l_hippocampus," + self.inputs.annDir + "/l_hippocampus_ProbabilityMap.nii.gz:" + "r_hippocampus," + self.inputs.annDir + "/r_hippocampus_ProbabilityMap.nii.gz"
    self._hippocampusXml = self.inputs.resultDir + "/" + self.inputs.scanId + "hippocampus.xml"
    self._leftHippocampus = self.inputs.resultDir + "/" + self.inputs.scanId + "_l_hippocampus_ANN.nii.gz"
    self._rightHippocampus = self.inputs.resultDir + "/" + self.inputs.scanId + "_r_hippocampus_ANN.nii.gz"
    self._hippocampusList = self._leftHippocampus + "," + self._rightHippocampus
    self._accumbensProbabilityMap = "l_accumbens," + self.inputs.annDir + "/l_accumbens_ProbabilityMap.nii.gz:" + "r_accumbens," + self.inputs.annDir + "/r_accumbens_ProbabilityMap.nii.gz"
    self._accumbensXml = self.inputs.resultDir + "/" + self.inputs.scanId + "accumbens.xml"
    self._leftAccumbens = self.inputs.resultDir + "/" + self.inputs.scanId + "_l_accumbens_ANN.nii.gz"
    self._rightAccumbens = self.inputs.resultDir + "/" + self.inputs.scanId + "_r_accumbens_ANN.nii.gz"
    self._accumbensList = self._leftAccumbens + "," + self._rightAccumbens
    self._globusProbabilityMap = "l_globus," + self.inputs.annDir + "/l_globus_ProbabilityMap.nii.gz:" + "r_globus," + self.inputs.annDir + "/r_globus_ProbabilityMap.nii.gz"
    self._globusXml = self.inputs.resultDir + "/" + self.inputs.scanId + "globus.xml"
    self._leftGlobus = self.inputs.resultDir + "/" + self.inputs.scanId + "_l_globus_ANN.nii.gz"
    self._rightGlobus = self.inputs.resultDir + "/" + self.inputs.scanId + "_r_globus_ANN.nii.gz"
    self._globusList = self._leftGlobus + "," + self._rightGlobus
    runtime.returncode = 0
    return runtime

  def _list_outputs(self):
    outputs = self._outputs().get()
    outputs["imageMap"] = self._imageMap
    outputs["atlasMap"] = self._atlasMap
    outputs["caudateProbabilityMap"] = self._caudateProbabilityMap
    outputs["caudateXml"] = self._caudateXml
    outputs["leftCaudate"] = self._leftCaudate
    outputs["rightCaudate"] = self._rightCaudate
    outputs["caudateList"] = self._caudateList
    outputs["putamenProbabilityMap"] = self._putamenProbabilityMap
    outputs["putamenXml"] = self._putamenXml
    outputs["leftPutamen"] = self._leftPutamen
    outputs["rightPutamen"] = self._rightPutamen
    outputs["putamenList"] = self._putamenList
    outputs["thalamusProbabilityMap"] = self._thalamusProbabilityMap
    outputs["thalamusXml"] = self._thalamusXml
    outputs["leftThalamus"] = self._leftThalamus
    outputs["rightThalamus"] = self._rightThalamus
    outputs["thalamusList"] = self._thalamusList
    outputs["hippocampusProbabilityMap"] = self._hippocampusProbabilityMap
    outputs["hippocampusXml"] = self._hippocampusXml
    outputs["leftHippocampus"] = self._leftHippocampus
    outputs["rightHippocampus"] = self._rightHippocampus
    outputs["hippocampusList"] = self._hippocampusList
    outputs["accumbensProbabilityMap"] = self._accumbensProbabilityMap
    outputs["accumbensXml"] = self._accumbensXml
    outputs["leftAccumbens"] = self._leftAccumbens
    outputs["rightAccumbens"] = self._rightAccumbens
    outputs["accumbensList"] = self._accumbensList
    outputs["globusProbabilityMap"] = self._globusProbabilityMap
    outputs["globusXml"] = self._globusXml
    outputs["leftGlobus"] = self._leftGlobus
    outputs["rightGlobus"] = self._rightGlobus
    outputs["globusList"] = self._globusList
    return outputs


# ---
# Main function

def WorkupANONRAW(ScanDir, Version=110, Mode=10, InterpolationMode="Linear"):

  ScanId = os.path.basename(ScanDir)
  PatientId = os.path.basename(os.path.dirname(ScanDir))

  print [ScanDir, PatientId, ScanId]

  RAWPrefix = ScanDir + "/ANONRAW/" + PatientId + "_" + ScanId
  T1Image = RAWPrefix + "_T1_COR.nii.gz"
  T2Image = RAWPrefix + "_T2_COR.nii.gz"
  InputOtherImages = RAWPrefix + "_PD_COR.nii.gz"
  ImageType = "Nifti"

  if (os.path.exists(T1Image)) and (os.path.exists(T2Image)):
    WorkupT1T2(ScanDir, [ T1Image ], [ T2Image ], Version, InterpolationMode, Mode, [])    # NOTICE: Old DwiList arg was "10", which makes no sense.
  else:
    print "Error: Did not find default T1 (" + T1Image + ") and T2 (" + T2Image + ") images."


def WorkupT1T2(ScanDir, T1Images, T2Images, Version=110, InterpolationMode="Linear", Mode=10, DwiList=[]):

  if len(T1Images) < 1:
    print "ERROR:  Length of T1 image list is 0,  at least one T1 image must be specified."
    sys.exit(-1)
  if len(T2Images) < 1:
    print "ERROR:  Length of T2 image list is 0,  at least one T2 image must be specified."
    sys.exit(-1)

  ScanId = os.path.basename(ScanDir)
  PatientId = os.path.basename(os.path.dirname(ScanDir))

  InputOtherImages = ""
  ## if the first image listed is a directory, assume dicom, else assume nifti
  if os.path.isdir(T1Images[0]):
    ImageType = "DICOM"
    print( "ERROR: DICOM to Nifti conversion not yet supported. {0}".format(T1Images))
    print( "ERROR: DICOM to Nifti conversion not yet supported. {0}".format(T1Images[0]))
    sys.exit(1)
  else:
    ImageType = "Nifti"


  ########################################################
  # Build up directories and file lists.
  ResultDir = ScanDir + "/" + str(Mode) + "_AUTO." + str(Version)
  TalairachResultDir = ResultDir + "/Talairach"
  ANNResultDir = ResultDir + "/ANN"
  Stage1ResultsDir = ResultDir + "/Stage1"
  BRAINSABCResultDir = ResultDir + "/BSITKBRAINSABC"
  WorkDir = ResultDir + "/Surface"
  talairachBoxes = ["nfrontal_box", "temporal_box", "parietal_box", "occipital_box"]
  binaryImageList = []
  binaryImageList_count = []
  regionNameList = []
  talairachBoxFiles = []
  index = 1
  for fileName in talairachBoxes:
    talairachBoxFiles.append(TalairachDir + "/" + fileName)
    binaryImageList.append(TalairachResultDir + "/" + ScanId + "_ACPC_" + fileName + "_seg.nii.gz")
    regionNameList.append(fileName.split()[0])
    binaryImageList_count.append(index)
    index += 1
  BRAINSABCAtlas = BRAINSABCAtlasDir + "/template_t1.nii.gz"
  leftHemisphere = BRAINSABCAtlasDir + "/template_leftHemisphere.nii.gz"
  rightHemisphere = BRAINSABCAtlasDir + "/template_rightHemisphere.nii.gz"
  cerebellumMask = BRAINSABCAtlasDir + "/template_cerebellum.nii.gz"
  ventriclesMask = BRAINSABCAtlasDir + "/template_ventricles.nii.gz"
  i = 1
  DWIBaseDir = "."
  if len(DwiList):
    DWIBaseDir = os.path.dirname(DwiList[0])
  DWIAnalysisDir = DWIBaseDir + "/" + GtractVersion
  nrrdRawFiles = []
  for dir in DwiList:
    nrrdRawFiles.append(DWIAnalysisDir + "/" + ScanId + "_DWI_Raw_Run_%d.nhdr" % i)
    i += 1
  nrrdBaseFiles = []
  nrrdRawFiles = []
  nrrdCoregFiles = []
  DWIOutputTransforms = []
  for i in range(1, len(DwiList) + 1):
    nrrdBaseFiles.append(DWIAnalysisDir + "/" + ScanId + "_DWI_Raw_Run_%d.nhdr" % i)
    nrrdRawFiles.append(DWIAnalysisDir + "/" + ScanId + "_DWI_Raw_Run_%d.nhdr" % i)
    nrrdCoregFiles.append(DWIAnalysisDir + "/" + ScanId + "_DWI_Coreg_Run_%d.nhdr" % i)
    DWIOutputTransforms.append(DWIAnalysisDir + "/" + ScanId + "_DWI_Coreg_Run_%d_Transform.txt" % i)

  ########################################################
  # Make directories
  try:
    os.makedirs(ANNResultDir)
  except OSError:
    pass
  try:
    os.makedirs(Stage1ResultsDir)
  except OSError:
    pass
  try:
    os.makedirs(BRAINSABCResultDir)
  except OSError:
    pass
  try:
    os.makedirs(WorkDir)
  except OSError:
    pass
  try:
    os.makedirs(DWIBaseDir)
  except OSError:
    pass
  try:
    os.makedirs(DWIAnalysisDir)
  except OSError:
    pass
  try:
    os.makedirs(TalairachResultDir)
  except OSError:
    pass

  ########################################################
  # Convert Images if Required
  if ImageType == "DICOM":
    print "ERROR: DICOM to Nifti conversion not yet supported."
    sys.exit(1)

    """
    Stage0ResultsDir = ResultDir + "/Stage0"

    uniq = 0
    for InputT1Image in T1Images:
      T1NiftiImage = Stage0ResultsDir + "/" + ScanId + "_SCAN" + uniq + "_T1.nii.gz"
      uniq += 1
      BRAINSImageConversionT1 = pe.Node(interface=BRAINSImageConversion(), name="BRAINSImageConversionT1")
      BRAINSImageConversionT1.inputs.InputT1Image = InputT1Image
      BRAINSImageConversionT1.inputs.T1NiftiImage = T1NiftiImage
      BRAINSImageConversionT1.inputs.1 = 1
      T1NiftiImageList.append(T1NiftiImage)

    uniq = 0
    for InputT2Image in T2Images:
      T2NiftiImage = Stage0ResultsDir + "/" + ScanId + "_SCAN" + uniq + "_T2.nii.gz"
      uniq += 1
      BRAINSImageConversionT2 = pe.Node(interface=BRAINSImageConversion(), name="BRAINSImageConversionT2")
      BRAINSImageConversionT2.inputs.InputT2Image = InputT2Image
      BRAINSImageConversionT2.inputs.T2NiftiImage = T2NiftiImage
      BRAINSImageConversionT2.inputs.1 = 1
      T2NiftiImageList.append(T2NiftiImage)
    """

  else:
    T1NiftiImageList = T1Images
    T2NiftiImageList = T2Images

  T1Basename = ConstellationBasename(T1NiftiImageList[0])
  T2Basename = ConstellationBasename(T2NiftiImageList[0])

  ########################################################
  # Run ACPC Detect on first T1 Image - Base Image
  ########################################################
  BRAINSConstellationDetectorT1 = pe.Node(interface=BRAINSConstellationDetector(), name="BRAINSConstellationDetectorT1")
  BRAINSConstellationDetectorT1.inputs.inputVolume = T1NiftiImageList[0]
  BRAINSConstellationDetectorT1.inputs.inputTemplateModel = T1ACPCModelFile
  BRAINSConstellationDetectorT1.outputs.resultsDir = Stage1ResultsDir
  BRAINSConstellationDetectorT1.outputs.outputResampledVolume = Stage1ResultsDir + "/" + T1Basename + "_ACPC.nii.gz"            #$# T1AcpcImage / T1AcpcImageList
  BRAINSConstellationDetectorT1.inputs.outputTransform = Stage1ResultsDir + "/" + T1Basename + "_ACPC_transform.mat"            #$# T1TransformFile
  BRAINSConstellationDetectorT1.inputs.outputLandmarksInInputSpace = Stage1ResultsDir + "/" + T1Basename + "_ACPC_Original.fcsv"        #$# T1OriginalFile
  BRAINSConstellationDetectorT1.inputs.outputLandmarksInACPCAlignedSpace = Stage1ResultsDir + "/" + T1Basename + "_ACPC_Landmarks.fcsv"    #$# T1LandmarkFile
  BRAINSConstellationDetectorT1.inputs.outputMRML = Stage1ResultsDir + "/" + T1Basename + "_ACPC_Scene.mrml"                #$# T1MRMLFile
  BRAINSConstellationDetectorT1.inputs.interpolationMode = InterpolationMode
  BRAINSConstellationDetectorT1.inputs.houghEyeDetectorMode = 1
  BRAINSConstellationDetectorT1.inputs.acLowerBound = 80

  ########################################################
  # Run ACPC Detect on T1 Images
  ########################################################

  BRAINSConstellationDetectorT1Batch = pe.MapNode(interface=BRAINSConstellationDetector(), name="BRAINSConstellationDetectorT1Batch", iterfield=["inputVolume"])
  BRAINSConstellationDetectorT1Batch.inputs.inputTemplateModel = T1ACPCModelFile
  BRAINSConstellationDetectorT1Batch.outputs.resultsDir = Stage1ResultsDir
  BRAINSConstellationDetectorT1Batch.outputs.outputVolume = Stage1ResultsDir + "/" + T1Basename + "_ACPC_InPlace.nii.gz"                #$# T1AcpcImageList
  BRAINSConstellationDetectorT1Batch.outputs.outputTransform = Stage1ResultsDir + "/" + T1Basename + "_ACPC_transform.mat"
  BRAINSConstellationDetectorT1Batch.inputs.outputLandmarksInInputSpace = Stage1ResultsDir + "/" + T1Basename + "_ACPC_Original.fcsv"
  BRAINSConstellationDetectorT1Batch.inputs.outputLandmarksInACPCAlignedSpace = Stage1ResultsDir + "/" + T1Basename + "_ACPC_Landmarks.fcsv"
  BRAINSConstellationDetectorT1Batch.inputs.outputMRML = Stage1ResultsDir + "/" + T1Basename + "_ACPC_Scene.mrml"
  BRAINSConstellationDetectorT1Batch.inputs.interpolationMode = InterpolationMode
  BRAINSConstellationDetectorT1Batch.inputs.houghEyeDetectorMode = 1
  BRAINSConstellationDetectorT1Batch.inputs.acLowerBound = 80
  BRAINSConstellationDetectorT1Batch.inputs.inputVolume = T1NiftiImageList

  ########################################################
  # Run ACPC Detect on remaining T2 Images
  ########################################################

  BRAINSConstellationDetectorT2Batch = pe.MapNode(interface=BRAINSConstellationDetector(), name="BRAINSConstellationDetectorT2Batch", iterfield=["inputVolume"])
  BRAINSConstellationDetectorT2Batch.inputs.inputTemplateModel = T2ACPCModelFile
#  BRAINSConstellationDetectorT2Batch.inputs.resultsDir = Stage1ResultsDir
  BRAINSConstellationDetectorT2Batch.inputs.outputResampledVolume = Stage1ResultsDir + "/" + T2Basename + "_ACPC_InPlace.nii.gz"                #$# T2AcpcImageList
  BRAINSConstellationDetectorT2Batch.inputs.outputTransform = Stage1ResultsDir + "/" + T2Basename + "_ACPC_transform.mat"
  BRAINSConstellationDetectorT2Batch.inputs.outputLandmarksInInputSpace = Stage1ResultsDir + "/" + T2Basename + "_ACPC_Original.fcsv"
  BRAINSConstellationDetectorT2Batch.inputs.outputLandmarksInACPCAlignedSpace = Stage1ResultsDir + "/" + T2Basename + "_ACPC_Landmarks.fcsv"
  BRAINSConstellationDetectorT2Batch.inputs.outputMRML = Stage1ResultsDir + "/" + T2Basename + "_ACPC_Scene.mrml"
  BRAINSConstellationDetectorT2Batch.inputs.interpolationMode = InterpolationMode
  BRAINSConstellationDetectorT2Batch.inputs.houghEyeDetectorMode = 0
  BRAINSConstellationDetectorT2Batch.inputs.acLowerBound = 80
  BRAINSConstellationDetectorT2Batch.inputs.inputVolume = T2NiftiImageList


  ##############################################################################
  # Perform BRAINSABC Segmentation - This will generate a discrete classification
  #      and bias field corrected images.
  ##############################################################################

  T1T2ImageList = pe.Node(interface=GenerateT1T2ImageList(), name="T1T2ImageList")

  BRAINSABCNode = pe.Node(interface=BRAINSABC(), name="BRAINSABCNode")
  BRAINSABCNode.inputs.maxIterations = 3
  BRAINSABCNode.inputs.maxBiasDegree = 4
  BRAINSABCNode.inputs.resamplerInterpolatorType = InterpolationMode
  BRAINSABCNode.inputs.atlasDef = EarlierAtlasDir + "/AtlasDefinition.xml"
  BRAINSABCNode.inputs.outputDir = BRAINSABCResultDir

  itkBinaryThresholdImageEms = pe.Node(interface=itkBinaryThresholdImage(), name="itkBinaryThresholdImageEms")
  itkBinaryThresholdImageEms.inputs.fileMode = "Unsigned-8bit"
  itkBinaryThresholdImageEms.inputs.min = 1
  itkBinaryThresholdImageEms.inputs.max = 4
  itkBinaryThresholdImageEms.inputs.outFilename = "/tmp/itkBinaryThresholdImageEms.nii.gz"    # True        #$# emsBrainMask

  itkBinaryImageMorphology_erodeMask = pe.Node(interface=itkBinaryImageMorphology(), name="itkBinaryImageMorphology_erodeMask")
  itkBinaryImageMorphology_erodeMask.inputs.fileMode = "Unsigned-8bit"
  itkBinaryImageMorphology_erodeMask.inputs.var1 = "Erode"
  itkBinaryImageMorphology_erodeMask.inputs.var2 = "Ball"
  itkBinaryImageMorphology_erodeMask.inputs.radius = [2,2,2]
  itkBinaryImageMorphology_erodeMask.inputs.outFilename = "/tmp/itkBianryImageMorphology_erodeMask.nii.gz"    #True    #$# erodeMask

  itkRelabelComponentImage_node = pe.Node(interface=itkRelabelComponentImage(), name="itkRelabelComponentImage_node")
  itkRelabelComponentImage_node.inputs.fileMode = "Unsigned-8bit"
  itkRelabelComponentImage_node.inputs.val = 30000
  itkRelabelComponentImage_node.inputs.outFilename = "/tmp/itkRelabelComponentImage_node.nii.gz"    # True        #$# largestRegionMask

  itkBinaryImageMorphology_dilateMask = pe.Node(interface=itkBinaryImageMorphology(), name="itkBinaryImageMorphology_dilateMask")
  itkBinaryImageMorphology_dilateMask.inputs.fileMode = "Unsigned-8bit"
  itkBinaryImageMorphology_dilateMask.inputs.var1 = "Dilate"
  itkBinaryImageMorphology_dilateMask.inputs.var2 = "Ball"
  itkBinaryImageMorphology_dilateMask.inputs.radius = [4,4,4]
  itkBinaryImageMorphology_dilateMask.inputs.outFilename = "/tmp/itkBinaryImageMorphology_dilateMask.nii.gz"     # True    #$# dilateMask

  itkAndImage_BrainMask = pe.Node(interface=itkAndImage(), name="itkAndImage_BrainMask")
  itkAndImage_BrainMask.inputs.fileMode = "Unsigned-8bit"
  itkAndImage_BrainMask.inputs.outFilename = ResultDir + "/" + ScanId + "_BRAINSABC_Brain.nii.gz"                #$# BrainMask

  #### Make Average Images from bias corrected data

  CorrectedImageFilenames = pe.Node(interface=GenerateCorrectedImageFilenames(), name="CorrectedImageFilenames")

  ClipAndAverageTwo_node = pe.Node(interface=ClipAndAverageTwo(), name="ClipAndAverageTwo_node")
  ClipAndAverageTwo_node.inputs.outputAverageOfActiveImages = ResultDir + "/" + ScanId + "_AVG_T1.nii.gz"    #$# T1AcpcBfcImage
  ClipAndAverageTwo_node.inputs.outputAverageOfPassiveImages = ResultDir + "/" + ScanId + "_AVG_T2.nii.gz"    #$# T2AcpcBfcImage


  ########################################################
  # Normalize and Scale to 8bit
  StandardizeImageIntensity_T1 = pe.Node(interface=StandardizeImageIntensity(), name="StandardizeImageIntensity_T1")
  StandardizeImageIntensity_T1.inputs.resultImageFilename = ResultDir + "/" + ScanId + "_ACPC_T1_BFC_norm.nii.gz"    #$# T1NormalizeBfc
  StandardizeImageIntensity_T1.inputs.minLabel = 1
  StandardizeImageIntensity_T1.inputs.maxLabel = 255

  StandardizeImageIntensity_T2 = pe.Node(interface=StandardizeImageIntensity(), name="StandardizeImageIntensity_T2")
  StandardizeImageIntensity_T2.inputs.resultImageFilename = ResultDir + "/" + ScanId + "_ACPC_T2_BFC_norm.nii.gz"    #$# T2NormalizeBfc
  StandardizeImageIntensity_T2.inputs.minLabel = 1
  StandardizeImageIntensity_T2.inputs.maxLabel = 255

  AutoTalairachParameters_node = pe.Node(interface=AutoTalairachParameters(), name="AutoTalairachParameters_node")
  AutoTalairachParameters_node.inputs.talairachBoxFile = ResultDir + "/" + ScanId + "Talairach_BB.vtk"        #$# TalairachBoxFile
  AutoTalairachParameters_node.inputs.talairachGridFile = ResultDir + "/" + ScanId + "Talairach_Grid.vtk"        #$# talairachGridFile

  # Define Venous Blood Plugs
  PickBloodPlugsFromMargin_node = pe.Node(interface=PickBloodPlugsFromMargin(), name="PickBloodPlugsFromMargin_node")
  PickBloodPlugsFromMargin_node.inputs.PDFile = "."
  PickBloodPlugsFromMargin_node.inputs.VbPlugFile = ResultDir + "/" + ScanId + "Auto_VB.nii.gz"            #$# VBplugs

  # Create Class Plugs (GM/WM/CSF)

  BRAINSClassPlugs_node = pe.Node(interface=BRAINSClassPlugs(), name="BRAINSClassPlugs_node")
#  BRAINSClassPlugs_node.inputs.PDNormalizeBfc = "."
  BRAINSClassPlugs_node.inputs.gmPlugs = ResultDir + "/" + ScanId + "Brains_GM.nii.gz"    #$# GreyPlugs
  BRAINSClassPlugs_node.inputs.wmPlugs = ResultDir + "/" + ScanId + "Brains_WM.nii.gz"    #$# WhitePlugs
  BRAINSClassPlugs_node.inputs.csfPlugs = ResultDir + "/" + ScanId + "Brains_CSF.nii.gz"    #$# CsfPlugs
  BRAINSClassPlugs_node.inputs.plugClassNames = ["gm","wm","csf"]
  BRAINSClassPlugs_node.inputs.t1ClassMeans = [80.0,114.0,30.0,0.0]
  BRAINSClassPlugs_node.inputs.t2ClassMeans = [80.0,30.0,223.0,0.0]
#  BRAINSClassPlugs_node.inputs.pdClassMeans = [173.0,141.0,190.0,0.0]
  BRAINSClassPlugs_node.inputs.randomSeed = 0
  BRAINSClassPlugs_node.inputs.numberOfPlugs = 4000
  BRAINSClassPlugs_node.inputs.coverage = 0.85
  BRAINSClassPlugs_node.inputs.permissiveness = 0.5
  BRAINSClassPlugs_node.inputs.meanOutlier = 1.0
  BRAINSClassPlugs_node.inputs.varOutlier = 10.0
  BRAINSClassPlugs_node.inputs.plugSize = 2.0
  BRAINSClassPlugs_node.inputs.partitions = [1,1,1]
  BRAINSClassPlugs_node.inputs.numberOfClassPlugs = [4000,2000,200]
  BRAINSClassPlugs_node.inputs.bloodMode = "Manual"
  BRAINSClassPlugs_node.inputs.bloodImage = "T1"

  # Create BRAINS Tissue Classified Image
  # grossTrim waqs 2.5 for MR6 - Had to increase for 3T
  BRAINSClassify_node = pe.Node(interface=BRAINSClassify(), name="BRAINSClassify_node")
  BRAINSClassify_node.inputs.classVolume = ResultDir + "/" + ScanId + "_ACPC_Class.nii.gz"    #$# classVolume
  BRAINSClassify_node.inputs.grossTrim = 2.5
  BRAINSClassify_node.inputs.spatialTrim = 0.0
  BRAINSClassify_node.inputs.x = True
  BRAINSClassify_node.inputs.y = True
  BRAINSClassify_node.inputs.z = True
  BRAINSClassify_node.inputs.xx = True
  BRAINSClassify_node.inputs.yy = True
  BRAINSClassify_node.inputs.zz = True
  BRAINSClassify_node.inputs.xy = True
  BRAINSClassify_node.inputs.xz = True
  BRAINSClassify_node.inputs.yz = True
  BRAINSClassify_node.inputs.histogramEqualize = True

  # Create Discrete Classified Image
  BRAINSTalairachMask_Basal = pe.Node(interface=BRAINSTalairachMask(), name="BRAINSTalairachMask_Basal")
  BRAINSTalairachMask_Basal.inputs.talairachBox = TalairachDir + "/basal_box"        #$# TalairachBasalBox
  BRAINSTalairachMask_Basal.inputs.outputVolume = TalairachResultDir + "/" + ScanId + "_ACPC_basal_box.nii.gz"        #$# BasalMask

  BRAINSDiscreteClass_node = pe.Node(interface=BRAINSDiscreteClass(), name="BRAINSDiscreteClass_node")
  BRAINSDiscreteClass_node.inputs.outputVolume = ResultDir + "/" + ScanId + "_ACPC_Discrete_Class.nii.gz"        #$# DiscreteClassVolume
  BRAINSDiscreteClass_node.inputs.subcorticalThreshold = 197

  ########################################################
  # Create the Summed Gradient Image
  GenerateSummedGradientImage_node = pe.Node(interface=GenerateSummedGradientImage(), name="GenerateSummedGradientImage_node")
  GenerateSummedGradientImage_node.inputs.outputFileName = ResultDir + "/ANN" + "/" + ScanId + "Summed_Gradient.nii.gz"    #$# SGImage

  ########################################################
  # Generate Brain Mask - ANN
  # Talk to Regina about how to add new Brain mask here

  ########################################################
  # Generate ANN Subcortical Labels
  ########################################################

  BRAINSCutMaps = pe.Node(interface=GenerateBRAINSCutMaps(), name="BRAINSCutMaps")
  BRAINSCutMaps.inputs.resultDir = ANNResultDir
  BRAINSCutMaps.inputs.atlasDir = BRAINSABCAtlasDir
  BRAINSCutMaps.inputs.scanId = ScanId
  BRAINSCutMaps.inputs.annDir = BRAINSANNDir

  #Caudate
  runBRAINSCut_caudate = pe.Node(interface=runBRAINSCut(), name="runBRAINSCut_caudate")
  runBRAINSCut_caudate.inputs.subject = ScanId
  runBRAINSCut_caudate.inputs.regions = ["caudate"]
  runBRAINSCut_caudate.inputs.xmlFile = ANNResultDir + "/" + ScanId + "caudate.xml"    #$# regionXmlFile
  runBRAINSCut_caudate.inputs.outputDir = ANNResultDir

  #Putamen
  runBRAINSCut_putamen = pe.Node(interface=runBRAINSCut(), name="runBRAINSCut_putamen")
  runBRAINSCut_putamen.inputs.subject = ScanId
  runBRAINSCut_putamen.inputs.regions = ["putamen"]
  runBRAINSCut_putamen.inputs.xmlFile = ANNResultDir + "/" + ScanId + "putamen.xml"    #$# regionXmlFile
  runBRAINSCut_putamen.inputs.outputDir = ANNResultDir

  #Thalamus
  runBRAINSCut_thalamus = pe.Node(interface=runBRAINSCut(), name="runBRAINSCut_thalamus")
  runBRAINSCut_thalamus.inputs.subject = ScanId
  runBRAINSCut_thalamus.inputs.regions = ["thalamus"]
  runBRAINSCut_thalamus.inputs.xmlFile = ANNResultDir + "/" + ScanId + "thalamus.xml"    #$# regionXmlFile
  runBRAINSCut_thalamus.inputs.outputDir = ANNResultDir

  #Hippocampus
  runBRAINSCut_hippocampus = pe.Node(interface=runBRAINSCut(), name="runBRAINSCut_hippocampus")
  runBRAINSCut_hippocampus.inputs.subject = ScanId
  runBRAINSCut_hippocampus.inputs.regions = ["hippocampus"]
  runBRAINSCut_hippocampus.inputs.xmlFile = ANNResultDir + "/" + ScanId + "hippocampus.xml"    #$# regionXmlFile
  runBRAINSCut_hippocampus.inputs.outputDir = ANNResultDir

  #Accumbens
  runBRAINSCut_accumbens = pe.Node(interface=runBRAINSCut(), name="runBRAINSCut_accumbens")
  runBRAINSCut_accumbens.inputs.subject = ScanId
  runBRAINSCut_accumbens.inputs.regions = ["accumbens"]
  runBRAINSCut_accumbens.inputs.xmlFile = ANNResultDir + "/" + ScanId + "accumbens.xml"    #$# regionXmlFile
  runBRAINSCut_accumbens.inputs.outputDir = ANNResultDir

  #Globus
  runBRAINSCut_globus = pe.Node(interface=runBRAINSCut(), name="runBRAINSCut_globus")
  runBRAINSCut_globus.inputs.subject = ScanId
  runBRAINSCut_globus.inputs.regions = ["globus"]
  runBRAINSCut_globus.inputs.xmlFile = ANNResultDir + "/" + ScanId + "globus.xml"    #$# regionXmlFile
  runBRAINSCut_globus.inputs.outputDir = ANNResultDir

  imageMeasureResults = pe.Node(interface=ClassTalairachVolumes(), name="imageMeasureResults")
  imageMeasureResults.inputs.talairachDir = TalairachDir
  imageMeasureResults.inputs.patientId = PatientId
  imageMeasureResults.inputs.scanId = ScanId
  imageMeasureResults.inputs.resultDir = ResultDir

  # Placeholder for Atlas Based Labeling of the brain

  #Clip T1 image to the brain
  itkMaskImage_clipT1 = pe.Node(interface=itkMaskImage(), name="itkMaskImage_clipT1")
  itkMaskImage_clipT1.inputs.fileMode = "Signed-16bit"
  itkMaskImage_clipT1.inputs.outFilename = WorkDir + "/" + ScanId + "T1_clip.nii.gz"    #$# clipT1Filename

  #Register Atlas with Subject - Affine
  BRAINSFit_T1 = pe.Node(interface=BRAINSFit(), name="BRAINSFit_T1")
  BRAINSFit_T1.inputs.movingVolume = BRAINSABCAtlas
  BRAINSFit_T1.inputs.transformType = ["Rigid","ScaleVersor3D"]
  BRAINSFit_T1.inputs.outputTransform = WorkDir + "/" + ScanId + "EmsAtlas_Transform.mat"    #$# affineTransform
  BRAINSFit_T1.inputs.numberOfSamples = 400000
  BRAINSFit_T1.inputs.translationScale = 1000
  BRAINSFit_T1.inputs.numberOfIterations = [1500]
  BRAINSFit_T1.inputs.minimumStepLength = [0.005,0.001]
  BRAINSFit_T1.inputs.failureExitCode = 1
  BRAINSFit_T1.inputs.outputVolume = WorkDir + "/" + ScanId + "_AffineAtlas.nii.gz"
  BRAINSFit_T1.inputs.outputVolumePixelType = "short"
  BRAINSFit_T1.inputs.fixedVolumeTimeIndex = 0
  BRAINSFit_T1.inputs.movingVolumeTimeIndex = 0
  BRAINSFit_T1.inputs.initializeTransformMode = "useCenterOfHeadAlign"
  BRAINSFit_T1.inputs.maskProcessingMode = "ROIAUTO"
  BRAINSFit_T1.inputs.skewScale = 1.0
  BRAINSFit_T1.inputs.reproportionScale = 1.0
  BRAINSFit_T1.inputs.numberOfHistogramBins = 50
  BRAINSFit_T1.inputs.numberOfMatchPoints = 10

  #DemonWarp BRAINSABCAtlas -> subjT1
  BRAINSDemonWarp_node = pe.Node(interface=BRAINSDemonWarp(), name="BRAINSDemonWarp_node")
  BRAINSDemonWarp_node.inputs.movingVolume = BRAINSABCAtlas
  BRAINSDemonWarp_node.inputs.outputDeformationFieldVolume = WorkDir + "/" + ScanId + "Atlas_DeformationField.nii.gz"    #$# deformationField
  BRAINSDemonWarp_node.inputs.outputVolume = WorkDir + "/" + ScanId + "Atlas.nii.gz"            #$# warpedAtlas
  BRAINSDemonWarp_node.inputs.numberOfHistogramBins = 256
  BRAINSDemonWarp_node.inputs.numberOfMatchPoints = 11
  BRAINSDemonWarp_node.inputs.numberOfPyramidLevels = 5
  BRAINSDemonWarp_node.inputs.arrayOfPyramidLevelIterations = [400,200,100,10,2]
  BRAINSDemonWarp_node.inputs.medianFilterSize = [1,1,1]
  BRAINSDemonWarp_node.inputs.inputPixelType = "short"
  BRAINSDemonWarp_node.inputs.outputPixelType = "short"
  BRAINSDemonWarp_node.inputs.registrationFilterType = "Diffeomorphic"
  BRAINSDemonWarp_node.inputs.smoothDeformationFieldSigma = 2

  #Warped Atlas based Regions
  BRAINSResample_leftHemisphere = pe.Node(interface=BRAINSResample(), name="BRAINSResample_leftHemisphere")
  BRAINSResample_leftHemisphere.inputs.inputVolume = leftHemisphere
  BRAINSResample_leftHemisphere.inputs.outputVolume = WorkDir + "/" + ScanId + "leftHemisphere_warped.nii.gz"    #$# warpedLeftHemisphere
  BRAINSResample_leftHemisphere.inputs.pixelType = "uchar"
  BRAINSResample_leftHemisphere.inputs.interpolationMode = "Linear"
  BRAINSResample_leftHemisphere.inputs.defaultValue = 0.0

  BRAINSResample_rightHemisphere = pe.Node(interface=BRAINSResample(), name="BRAINSResample_rightHemisphere")
  BRAINSResample_rightHemisphere.inputs.inputVolume = rightHemisphere
  BRAINSResample_rightHemisphere.inputs.outputVolume = WorkDir + "/" + ScanId + "rightHemisphere_warped.nii.gz"    #$# warpedRightHemisphere
  BRAINSResample_rightHemisphere.inputs.pixelType = "uchar"
  BRAINSResample_rightHemisphere.inputs.interpolationMode = "Linear"
  BRAINSResample_rightHemisphere.inputs.defaultValue = 0.0

  BRAINSResample_cerebellum = pe.Node(interface=BRAINSResample(), name="BRAINSResample_cerebellum")
  BRAINSResample_cerebellum.inputs.inputVolume = cerebellumMask
  BRAINSResample_cerebellum.inputs.outputVolume = WorkDir + "/" + ScanId + "cerebellum_warped.nii.gz"        #$# warpedCerebellum
  BRAINSResample_cerebellum.inputs.pixelType = "uchar"
  BRAINSResample_cerebellum.inputs.interpolationMode = "Linear"
  BRAINSResample_cerebellum.inputs.defaultValue = 0.0

  BRAINSResample_ventricles = pe.Node(interface=BRAINSResample(), name="BRAINSResample_ventricles")
  BRAINSResample_ventricles.inputs.inputVolume = ventriclesMask
  BRAINSResample_ventricles.inputs.outputVolume = WorkDir + "/" + ScanId + "ventricles_warped.nii.gz"        #$# warpedVentricles
  BRAINSResample_ventricles.inputs.pixelType = "uchar"
  BRAINSResample_ventricles.inputs.interpolationMode = "Linear"
  BRAINSResample_ventricles.inputs.defaultValue = 0.0

  #Create a separate VTK file for each hemisphere surface
  CreateBrainSurface_leftHemisphere = pe.Node(interface=CreateBrainSurface(), name="CreateBrainSurface_leftHemisphere")
  CreateBrainSurface_leftHemisphere.inputs.outputImageFilename = WorkDir + "/" + ScanId + "_leftTissueClass.nii.gz"    #$# leftHemisphereImage
  CreateBrainSurface_leftHemisphere.inputs.outputSurfaceFilename = ResultDir + "/" + ScanId + "_left_surface.vtk"    #$# leftSurface

  CreateBrainSurface_rightHemisphere = pe.Node(interface=CreateBrainSurface(), name="CreateBrainSurface_rightHemisphere")
  CreateBrainSurface_rightHemisphere.inputs.outputImageFilename = WorkDir + "/" + ScanId + "_rightTissueClass.nii.gz"        #$# rightHemisphereImage
  CreateBrainSurface_rightHemisphere.inputs.outputSurfaceFilename = ResultDir + "/" + ScanId + "_right_surface.vtk"    #$# rightSurface

  # Create surfaces for auto-labeling
  CreateAutoLabelBrainSurface_leftHemisphere = pe.Node(interface=CreateAutoLabelBrainSurface(), name="CreateAutoLabelBrainSurface_leftHemisphere")

  CreateAutoLabelBrainSurface_rightHemisphere = pe.Node(interface=CreateAutoLabelBrainSurface(), name="CreateAutoLabelBrainSurface_rightHemisphere")

  #########################################################
  # Create the Talairach Box Regions
  #########################################################
  BRAINSTalairachMask_ClassVolume = pe.MapNode(interface=BRAINSTalairachMask(), name="BRAINSTalairachMask_ClassVolume", iterfield=['talairachBox', 'outputVolume'])
  BRAINSTalairachMask_ClassVolume.inputs.hemisphereMode = "both"
  BRAINSTalairachMask_ClassVolume.inputs.expand = True
  BRAINSTalairachMask_ClassVolume.inputs.outputVolume = binaryImageList

  #########################################################
  # Merge the binary images into a label map
  #########################################################
  itkConstantImageMath_LabelMap = pe.MapNode(interface=itkConstantImageMath(), name="itkConstantImageMath_LabelMap", iterfield=["inFilename", "value"])
  itkConstantImageMath_LabelMap.inputs.fileMode = "Signed-16bit"
  itkConstantImageMath_LabelMap.inputs.operation = "Multiply"
  itkConstantImageMath_LabelMap.inputs.outFilename = "/tmp/itkConstantImageMath_LabelMap_outFilename.nii.gz"    #$# labelImage
  itkConstantImageMath_LabelMap.inputs.value = binaryImageList_count

  itkNaryMaximumImageFilter_LabelMap = pe.Node(interface=itkNaryMaximumImageFilter(), name="itkNaryMaximumImageFilter_LabelMap")
  itkNaryMaximumImageFilter_LabelMap.inputs.fileMode = "Signed-16bit"
  itkNaryMaximumImageFilter_LabelMap.inputs.outFilename = TalairachResultDir + "/" + ScanId + "_ACPC_Talairach_LabelMap.nii.gz"    #$# talairachLabelMapFile


  #########################################################
  # Label and Measure the Surface
  #########################################################

  BRAINSApplySurfaceLabels_left = pe.Node(interface=BRAINSApplySurfaceLabels(), name="BRAINSApplySurfaceLabels_left")
  BRAINSApplySurfaceLabels_left.inputs.cellDataName = "Talairach-Lobes"
  BRAINSApplySurfaceLabels_left.inputs.outputSurface = ResultDir + "/" + ScanId + "_left_surface_tal.vtk"    #$# LeftLabelSurface

  BRAINSApplySurfaceLabels_right = pe.Node(interface=BRAINSApplySurfaceLabels(), name="BRAINSApplySurfaceLabels_right")
  BRAINSApplySurfaceLabels_right.inputs.cellDataName = "Talairach-Lobes"
  BRAINSApplySurfaceLabels_right.inputs.outputSurface = ResultDir + "/" + ScanId + "_right_surface_tal.vtk"    #$# RightLabelSurface

  BRAINSMeasureSurface_left = pe.Node(interface=BRAINSMeasureSurface(), name="BRAINSMeasureSurface_left")
  BRAINSMeasureSurface_left.inputs.arrayName = "Talairach-Lobes"
  BRAINSMeasureSurface_left.inputs.labels = regionNameList
  BRAINSMeasureSurface_left.inputs.writeCsvFile = True
  BRAINSMeasureSurface_left.inputs.csvFile = ResultDir + "/StandardSurfaceMeasures.csv"    #$# resultCsvFile
  BRAINSMeasureSurface_left.inputs.subjectId = PatientId
  BRAINSMeasureSurface_left.inputs.scanId = ScanId

  BRAINSMeasureSurface_right = pe.Node(interface=BRAINSMeasureSurface(), name="BRAINSMeasureSurface_right")
  BRAINSMeasureSurface_right.inputs.arrayName = "Talairach-Lobes"
  BRAINSMeasureSurface_right.inputs.labels = regionNameList
  BRAINSMeasureSurface_right.inputs.writeCsvFile = True
  BRAINSMeasureSurface_right.inputs.csvFile = ResultDir + "/StandardSurfaceMeasures.csv"    #$# resultCsvFile
  BRAINSMeasureSurface_right.inputs.subjectId = PatientId
  BRAINSMeasureSurface_right.inputs.scanId = ScanId

  #
  # Genus 0 Surface Generation
  #

  # Fill in the image to eliminate ventricles, and subcortical strutures
  # Generate a binary representation for subsequent operations
  itkBinaryThresholdImage_warpedVentricles = pe.Node(interface=itkBinaryThresholdImage(), name="itkBinaryThresholdImage_warpedVentricles")
  itkBinaryThresholdImage_warpedVentricles.inputs.fileMode = "Unsigned-8bit"
  itkBinaryThresholdImage_warpedVentricles.inputs.min = 1
  itkBinaryThresholdImage_warpedVentricles.inputs.max = 255
  itkBinaryThresholdImage_warpedVentricles.inputs.outFilename = "/tmp/itkBinaryThresholdImage_warpedVentricles.nii.gz"    #$# binaryVentricle

  itkBinaryThresholdImage_rightCaudate = pe.Node(interface=itkBinaryThresholdImage(), name="itkBinaryThresholdImage_rightCaudate")
  itkBinaryThresholdImage_rightCaudate.inputs.fileMode = "Unsigned-8bit"
  itkBinaryThresholdImage_rightCaudate.inputs.min = 1
  itkBinaryThresholdImage_rightCaudate.inputs.max = 255
  itkBinaryThresholdImage_rightCaudate.inputs.outFilename = "/tmp/itkBinaryThresholdImage_rightCaudate.nii.gz"    #$# binaryRightCaudate

  itkBinaryThresholdImage_leftCaudate = pe.Node(interface=itkBinaryThresholdImage(), name="itkBinaryThresholdImage_leftCaudate")
  itkBinaryThresholdImage_leftCaudate.inputs.fileMode = "Unsigned-8bit"
  itkBinaryThresholdImage_leftCaudate.inputs.min = 1
  itkBinaryThresholdImage_leftCaudate.inputs.max = 255
  itkBinaryThresholdImage_leftCaudate.inputs.outFilename = "/tmp/itkBinaryThresholdImage_leftCaudate.nii.gz"    #$# binaryLeftCaudate

  itkBinaryThresholdImage_rightPutamen = pe.Node(interface=itkBinaryThresholdImage(), name="itkBinaryThresholdImage_rightPutamen")
  itkBinaryThresholdImage_rightPutamen.inputs.fileMode = "Unsigned-8bit"
  itkBinaryThresholdImage_rightPutamen.inputs.min = 1
  itkBinaryThresholdImage_rightPutamen.inputs.max = 255
  itkBinaryThresholdImage_rightPutamen.inputs.outFilename = "/tmp/itkBinaryThresholdImage_rightPutamen.nii.gz"    #$# binaryRightPutamen

  itkBinaryThresholdImage_leftPutamen = pe.Node(interface=itkBinaryThresholdImage(), name="itkBinaryThresholdImage_leftPutamen")
  itkBinaryThresholdImage_leftPutamen.inputs.fileMode = "Unsigned-8bit"
  itkBinaryThresholdImage_leftPutamen.inputs.min = 1
  itkBinaryThresholdImage_leftPutamen.inputs.max = 255
  itkBinaryThresholdImage_leftPutamen.inputs.outFilename = "/tmp/itkBinaryThresholdImage_leftPutamen.nii.gz"    #$# binaryLeftPutamen

  itkBinaryThresholdImage_rightThalamus = pe.Node(interface=itkBinaryThresholdImage(), name="itkBinaryThresholdImage_rightThalamus")
  itkBinaryThresholdImage_rightThalamus.inputs.fileMode = "Unsigned-8bit"
  itkBinaryThresholdImage_rightThalamus.inputs.min = 1
  itkBinaryThresholdImage_rightThalamus.inputs.max = 255
  itkBinaryThresholdImage_rightThalamus.inputs.outFilename = "/tmp/itkBinaryThresholdImage_rightThalamus.nii.gz"    #$# binaryRightThalamus

  itkBinaryThresholdImage_leftThalamus = pe.Node(interface=itkBinaryThresholdImage(), name="itkBinaryThresholdImage_leftThalamus")
  itkBinaryThresholdImage_leftThalamus.inputs.fileMode = "Unsigned-8bit"
  itkBinaryThresholdImage_leftThalamus.inputs.min = 1
  itkBinaryThresholdImage_leftThalamus.inputs.max = 255
  itkBinaryThresholdImage_leftThalamus.inputs.outFilename = "/tmp/itkBinaryThresholdImage_leftThalamus.nii.gz"    #$# binaryLeftThalamus

  ########## Combine Regions to Fill Class Image ###########
  itkOrImage_binaryCaudate = pe.Node(interface=itkOrImage(), name="itkOrImage_binaryCaudate")
  itkOrImage_binaryCaudate.inputs.fileMode = "Unsigned-8bit"
  itkOrImage_binaryCaudate.inputs.outFilename = "/tmp/itkOrImage_binaryCaudate.nii.gz"            #$# binaryCaudate

  itkOrImage_binaryPutamen = pe.Node(interface=itkOrImage(), name="itkOrImage_binaryPutamen")
  itkOrImage_binaryPutamen.inputs.fileMode = "Unsigned-8bit"
  itkOrImage_binaryPutamen.inputs.outFilename = "/tmp/itkOrImage_binaryPutamen.nii.gz"            #$# binaryPutamen

  itkOrImage_binaryThalamus = pe.Node(interface=itkOrImage(), name="itkOrImage_binaryThalamus")
  itkOrImage_binaryThalamus.inputs.fileMode = "Unsigned-8bit"
  itkOrImage_binaryThalamus.inputs.outFilename = "/tmp/itkOrImage_binaryThalamus.nii.gz"        #$# binaryThalamus

  itkOrImage_binaryBasalGanglia = pe.Node(interface=itkOrImage(), name="itkOrImage_binaryBasalGanglia")
  itkOrImage_binaryBasalGanglia.inputs.fileMode = "Unsigned-8bit"
  itkOrImage_binaryBasalGanglia.inputs.outFilename = "/tmp/itkOrImage_binaryBasalGanglia.nii.gz"    #$# binaryBasalGanglia

  itkOrImage_binarySubcortical = pe.Node(interface=itkOrImage(), name="itkOrImage_binarySubcortical")
  itkOrImage_binarySubcortical.inputs.fileMode = "Unsigned-8bit"
  itkOrImage_binarySubcortical.inputs.outFilename = "/tmp/itkOrImage_binarySubcortical.nii.gz"        #$# binarySubcortical

  itkOrImage_binaryCombinedRegion = pe.Node(interface=itkOrImage(), name="itkOrImage_binaryCombinedRegion")
  itkOrImage_binaryCombinedRegion.inputs.fileMode = "Unsigned-8bit"
  itkOrImage_binaryCombinedRegion.inputs.outFilename = "/tmp/itkOrImage_binaryCombinedRegion.nii.gz"    #$# binaryCombinedRegion

  itkObjectMorphology_fillRegion = pe.Node(interface=itkObjectMorphology(), name="itkObjectMorphology_fillRegion")
  itkObjectMorphology_fillRegion.inputs.fileMode = "Unsigned-8bit"
  itkObjectMorphology_fillRegion.inputs.var1 = "Dilate"
  itkObjectMorphology_fillRegion.inputs.var2 = "Ball"
  itkObjectMorphology_fillRegion.inputs.radius = [1,1,1]
  itkObjectMorphology_fillRegion.inputs.var3 = 1
  itkObjectMorphology_fillRegion.inputs.outFilename = "/tmp/itkObjectMorphology_fillRegion.nii.gz"    #$# binaryFillRegion

  # Create the Filled Class Image
  itkConstantImageMath2 = pe.Node(interface=itkConstantImageMath(), name="itkConstantImageMath2")
  itkConstantImageMath2.inputs.fileMode = "Unsigned-8bit"
  itkConstantImageMath2.inputs.value = 230
  itkConstantImageMath2.inputs.operation = "Multiply"
  itkConstantImageMath2.inputs.outFilename = "/tmp/itkConstantImageMath2.nii.gz"            #$# scaledFillRegion

  Merge_ScaledFillRegion_ClassVolume = pe.Node(interface=util.Merge(2), name='Merge_ScaledFillRegion_ClassVolume')

  itkNaryMaximumImageFilter2 = pe.Node(interface=itkNaryMaximumImageFilter(), name="itkNaryMaximumImageFilter2")
  itkNaryMaximumImageFilter2.inputs.fileMode = "Unsigned-8bit"
  itkNaryMaximumImageFilter2.inputs.outFilename = WorkDir + "/" + ScanId + "Filled_class.nii.gz"    #$# resultClassFilename

  #Create a separate VTK file for each hemisphere surface
  # Erode the brain mask slightly to eliminate small handles
  # on the surface - These are connections to dura
  itkBinaryThresholdImage_brainMask = pe.Node(interface=itkBinaryThresholdImage(), name="itkBinaryThresholdImage_brainMask")
  itkBinaryThresholdImage_brainMask.inputs.fileMode = "Signed-16bit"
  itkBinaryThresholdImage_brainMask.inputs.min = 1
  itkBinaryThresholdImage_brainMask.inputs.max = 255
  itkBinaryThresholdImage_brainMask.inputs.outFilename = "/tmp/itkBinaryThresholdImage_brainMask.nii.gz"    #$# brainMask

  itkObjectMorphology_brainMask = pe.Node(interface=itkObjectMorphology(), name="itkObjectMorphology_brainMask")
  itkObjectMorphology_brainMask.inputs.fileMode = "Signed-16bit"
  itkObjectMorphology_brainMask.inputs.var1 = "Erode"
  itkObjectMorphology_brainMask.inputs.var2 = "Ball"
  itkObjectMorphology_brainMask.inputs.radius = [1,1,1]
  itkObjectMorphology_brainMask.inputs.var3 = 1
  itkObjectMorphology_brainMask.inputs.outFilename = WorkDir + "/" + ScanId + "brainErode.nii.gz"    #$# tmpBrainMask

  # Create Genus 0 surfaces
  CreateGenusZeroBrainSurface_left = pe.Node(interface=CreateGenusZeroBrainSurface(), name="CreateGenusZeroBrainSurface_left")
  CreateGenusZeroBrainSurface_left.inputs.OutputSurfaceFilename = ResultDir + "/" + ScanId + "left_surface.vtk"    #$# leftSurfaceGenusZero

  CreateGenusZeroBrainSurface_right = pe.Node(interface=CreateGenusZeroBrainSurface(), name="CreateGenusZeroBrainSurface_right")
  CreateGenusZeroBrainSurface_right.inputs.OutputSurfaceFilename = ResultDir + "/" + ScanId + "right_surface.vtk"    #$# rightSurfaceGenusZero

  # Decimate Surface
  QuadMeshDecimation_left = pe.Node(interface=QuadMeshDecimation(), name="QuadMeshDecimation_left")
  QuadMeshDecimation_left.inputs.outputSurface = ResultDir + "/" + ScanId + "left_surface_decimated.vtk"    #$# leftDecimateSurface
  QuadMeshDecimation_left.inputs.numberOfElements = 70000

  QuadMeshDecimation_right = pe.Node(interface=QuadMeshDecimation(), name="QuadMeshDecimation_right")
  QuadMeshDecimation_right.inputs.outputSurface = ResultDir + "/" + ScanId + "right_surface_decimated.vtk"    #$# rightDecimateSurface
  QuadMeshDecimation_right.inputs.numberOfElements = 70000

  # Smooth Surfaces
  QuadMeshSmoothing_left = pe.Node(interface=QuadMeshSmoothing(), name="QuadMeshSmoothing_left")
  QuadMeshSmoothing_left.inputs.outputSurface = ResultDir + "/" + ScanId + "g0_left_surface_smooth.vtk"    #$# leftGenusZeroSurface
  QuadMeshSmoothing_left.inputs.numberOfIterations = 5
  QuadMeshSmoothing_left.inputs.relaxationFactor = 0.1

  QuadMeshSmoothing_right = pe.Node(interface=QuadMeshSmoothing(), name="QuadMeshSmoothing_right")
  QuadMeshSmoothing_right.inputs.outputSurface = ResultDir + "/" + ScanId + "g0_right_surface_smooth.vtk"    #$# rightGenusZeroSurface
  QuadMeshSmoothing_right.inputs.numberOfIterations = 5
  QuadMeshSmoothing_right.inputs.relaxationFactor = 0.1

  # Analyze DWI Data if present
  ### Convert the DICOM image to NRRD format
  DicomToNrrdConverter_node = pe.MapNode(interface=DicomToNrrdConverter(), name="DicomToNrrdConverter_node", iterfield=['inputDicomDirectory', 'outputVolume'])
  DicomToNrrdConverter_node.inputs.inputDicomDirectory = DwiList
  DicomToNrrdConverter_node.inputs.outputVolume = nrrdRawFiles

  ### Co-register B-values
  gtractCoregBvalues_node = pe.MapNode(interface=gtractCoregBvalues(), name="gtractCoregBvalues_node", iterfield=['fixedVolume', 'movingVolume', 'outputVolume', 'outputTransform'])
  gtractCoregBvalues_node.inputs.fixedVolume = nrrdBaseFiles
  gtractCoregBvalues_node.inputs.fixedVolumeIndex = 0
  gtractCoregBvalues_node.inputs.movingVolume = nrrdRawFiles
  gtractCoregBvalues_node.inputs.outputVolume = nrrdCoregFiles
  gtractCoregBvalues_node.inputs.outputTransform = DWIOutputTransforms
  gtractCoregBvalues_node.inputs.eddyCurrentCorrection = True

  ### Concatinate DWIs
  gtractConcatDwi_node = pe.Node(interface=gtractConcatDwi(), name="gtractConcatDwi_node")
  gtractConcatDwi_node.inputs.inputVolume = nrrdCoregFiles
  gtractConcatDwi_node.inputs.outputVolume = DWIAnalysisDir + "/" + ScanId + "_DWI_Concat_Runs.nhdr"    #$# DWINrrd

  ### Create Tensor

  gtractTensor_node = pe.Node(interface=gtractTensor(), name="gtractTensor_node")
  gtractTensor_node.inputs.outputVolume = DWIAnalysisDir + "/" + ScanId + "_DWI_Tensor.nhdr"    #$# nrrdTensorFile
  gtractTensor_node.inputs.medianFilterSize = [1,1,1]
  gtractTensor_node.inputs.backgroundSuppressingThreshold = 50

  ### Create Scalar Images
  gtractAnisotropyMap_FA = pe.Node(interface=gtractAnisotropyMap(), name="gtractAnisotropyMap_FA")
  gtractAnisotropyMap_FA.inputs.outputVolume = DWIAnalysisDir + "/" + ScanId + "_DWI_FA.nhdr"    #$# faFile
  gtractAnisotropyMap_FA.inputs.anisotropyType = "FA"

  gtractAnisotropyMap_ADC = pe.Node(interface=gtractAnisotropyMap(), name="gtractAnisotropyMap_ADC")
  gtractAnisotropyMap_ADC.inputs.outputVolume = DWIAnalysisDir + "/" + ScanId + "_DWI_ADC.nhdr"    #$# adcFile
  gtractAnisotropyMap_ADC.inputs.anisotropyType = "ADC"

  gtractAnisotropyMap_AD = pe.Node(interface=gtractAnisotropyMap(), name="gtractAnisotropyMap_AD")
  gtractAnisotropyMap_AD.inputs.outputVolume = DWIAnalysisDir + "/" + ScanId + "_DWI_AD.nhdr"    #$# adFile
  gtractAnisotropyMap_AD.inputs.anisotropyType = "AD"

  gtractAnisotropyMap_RD = pe.Node(interface=gtractAnisotropyMap(), name="gtractAnisotropyMap_RD")
  gtractAnisotropyMap_RD.inputs.outputVolume = DWIAnalysisDir + "/" + ScanId + "_DWI_RD.nhdr"    #$# rdFile
  gtractAnisotropyMap_RD.inputs.anisotropyType = "RD"

  ### Extract B0 image - Used for skull stripping
  extractNrrVectorIndex_node = pe.Node(interface=extractNrrdVectorIndex(), name="extractNrrVectorIndex_node")
  extractNrrVectorIndex_node.inputs.outputVolume = DWIAnalysisDir + "/" + ScanId + "_DWI_B0.nii.gz"    #$# b0File
  extractNrrVectorIndex_node.inputs.vectorIndex = 0

  ### Skull Strip the B0 image
  DtiSkullStripB0_node = pe.Node(interface=DtiSkullStripB0(), name="DtiSkullStripB0_node")
  DtiSkullStripB0_node.inputs.ClippedB0File = DWIAnalysisDir + "/" + ScanId + "_DWI_B0_clipped.nii.gz"    #$# clippedB0File
  DtiSkullStripB0_node.inputs.Threshold = 100
  DtiSkullStripB0_node.inputs.ErodeSize = 1
  DtiSkullStripB0_node.inputs.DilateSize = 3

  ### Create the Skull Stripped Anatomical
  itkMaskImage_clippedT1 = pe.Node(interface=itkMaskImage(), name="itkMaskImage_clippedT1")
  itkMaskImage_clippedT1.inputs.fileMode = "Signed-16bit"
  itkMaskImage_clippedT1.inputs.outFilename = DWIAnalysisDir + "/" + ScanId + "_T1_clipped.nii.gz"    #$# clippedT1Filename

  ### Co-Register With Anatomical
  BRAINSFit_B0 = pe.Node(interface=BRAINSFit(), name="BRAINSFit_B0")
  BRAINSFit_B0.inputs.transformType = ["Rigid","ScaleVersor3D","ScaleSkewVersor3D","Affine","BSpline"]
  BRAINSFit_B0.inputs.outputTransform = DWIAnalysisDir + "/" + ScanId + "_Warp_ACPC_B0_BSpline.mat"    #$# B0Transform
  BRAINSFit_B0.inputs.numberOfSamples = 1000000
  BRAINSFit_B0.inputs.translationScale = 1000.0
  BRAINSFit_B0.inputs.numberOfIterations = [1500]
  BRAINSFit_B0.inputs.minimumStepLength = [0.00005,0.005,0.005,0.005,0.005]
  BRAINSFit_B0.inputs.failureExitCode = 1
  BRAINSFit_B0.inputs.outputVolume = DWIAnalysisDir + "/" + ScanId + "_Warp_ACPC_B0_Bspline.nii.gz"    #$# WarpedImageB0
  BRAINSFit_B0.inputs.outputVolumePixelType = "short"
  BRAINSFit_B0.inputs.fixedVolumeTimeIndex = 0
  BRAINSFit_B0.inputs.movingVolumeTimeIndex = 0
  BRAINSFit_B0.inputs.initializeTransformMode = "useCenterOfHeadAlign"
  BRAINSFit_B0.inputs.maskProcessingMode = "NOMASK"
  BRAINSFit_B0.inputs.reproportionScale = 1.0
  BRAINSFit_B0.inputs.skewScale = 1.0
  BRAINSFit_B0.inputs.splineGridSize = [28,20,24]    # NOTICE!!!!  This parameter was being passed but not used before!  UPDATE: According to Vince, there was a bug in the old pipeline; it *should* have been used.
  BRAINSFit_B0.inputs.numberOfHistogramBins = 50

  BRAINSResample_faFile = pe.Node(interface=BRAINSResample(), name="BRAINSResample_faFile")
  BRAINSResample_faFile.inputs.outputVolume = DWIAnalysisDir + "/" + ScanId + "_ACPC_FA.nii.gz"    #$# warpedFaFile
  BRAINSResample_faFile.inputs.pixelType = "float"
  BRAINSResample_faFile.inputs.interpolationMode = "Linear"
  BRAINSResample_faFile.inputs.defaultValue = 0.0

  BRAINSResample_adcFile = pe.Node(interface=BRAINSResample(), name="BRAINSResample_adcFile")
  BRAINSResample_adcFile.inputs.outputVolume = DWIAnalysisDir + "/" + ScanId + "_ACPC_ADC.nii.gz"    #$# warpedAdcFile
  BRAINSResample_adcFile.inputs.pixelType = "float"
  BRAINSResample_adcFile.inputs.interpolationMode = "Linear"
  BRAINSResample_adcFile.inputs.defaultValue = 0.0

  BRAINSResample_adFile = pe.Node(interface=BRAINSResample(), name="BRAINSResample_adFile")
  BRAINSResample_adFile.inputs.outputVolume = DWIAnalysisDir + "/" + ScanId + "_ACPC_AD.nii.gz"    #$# warpedAdFile
  BRAINSResample_adFile.inputs.pixelType = "float"
  BRAINSResample_adFile.inputs.interpolationMode = "Linear"
  BRAINSResample_adFile.inputs.defaultValue = 0.0

  BRAINSResample_rdFile = pe.Node(interface=BRAINSResample(), name="BRAINSResample_rdFile")
  BRAINSResample_rdFile.inputs.outputVolume = DWIAnalysisDir + "/" + ScanId + "_ACPC_RD.nii.gz"    #$# warpedRdFile
  BRAINSResample_rdFile.inputs.pixelType = "float"
  BRAINSResample_rdFile.inputs.interpolationMode = "Linear"
  BRAINSResample_rdFile.inputs.defaultValue = 0.0

  Merge_FA_ADC_AD_RD = pe.Node(interface=util.Merge(4), name='Merge_FA_ADC_AD_RD')

  ScalarTalairachMeasures_node = pe.Node(interface=ScalarTalairachMeasures(), name="ScalarTalairachMeasures_node")
  ScalarTalairachMeasures_node.inputs.PatientId = PatientId
  ScalarTalairachMeasures_node.inputs.ScanId = ScanId
  ScalarTalairachMeasures_node.inputs.ResultDir = DWIAnalysisDir

  ########### P I P E L I N E   C R E A T I O N #############

  print "**************"
  print ScanDir
  print "**************"

  pipeline = pe.Workflow(name="pipeline")
  pipeline.base_dir = ScanDir


  PickBloodPlugsFromMargin_node.inputs.VbPlugFile = "/raid0/homes/kpease/deleteme.txt"

  # Entries below are of the form:
  # (node1, node2, [(out_source1, out_dest1), (out_source2, out_dest2), ...])
  pipeline.connect([
                  (BRAINSConstellationDetectorT1Batch, T1T2ImageList, [('outputVolume', 'T1ImageList')]),
                  (BRAINSConstellationDetectorT2Batch, T1T2ImageList, [('outputResampledVolume', 'T2ImageList')])
  ])

  pipeline.run()

############################  MAIN
## ../../BRAINS4-buld/Library/Framework/Python.framework/Versions/2.6/bin/python BrainsAutoWorkup.py /hjohnson/NAMIC/ReferenceAtlas_20110511/ /hjohnson/NAMIC/ReferenceAtlas_20110511/template_t1.nii.gz /hjohnson/NAMIC/ReferenceAtlas_20110511/template_t2.nii.gz
OUTDIR=os.path.realpath(sys.argv[1])
T1s=[os.path.realpath(sys.argv[2]) ]
T2s=[os.path.realpath(sys.argv[3]) ]

WorkupT1T2(OUTDIR,T1s,T2s)
