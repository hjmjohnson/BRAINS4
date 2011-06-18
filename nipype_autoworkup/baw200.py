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
"""Import necessary modules from nipype."""
from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec, File, Directory, traits, isdefined, BaseInterface
from nipype.interfaces.utility import Merge, Split, Function, Rename

import nipype.interfaces.io as nio           # Data i/o
import nipype.pipeline.engine as pe          # pypeline engine

from nipype.utils.misc import package_check
package_check('numpy', '1.3', 'tutorial1')
package_check('scipy', '0.7', 'tutorial1')
package_check('networkx', '1.0', 'tutorial1')
package_check('IPython', '0.10', 'tutorial1')

from BRAINSConstellationDetector import *
from BRAINSABC import *
from BRAINSDemonWarp import *
from BRAINSFit import *
from BRAINSMush import *
from BRAINSResample import *
from BRAINSROIAuto import *

import os, sys, string, shutil, glob, re

## HACK:  This should be more elegant, and should use a class
##        to encapsulate all this functionality into re-usable
##        components with better documentation.
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
  
def get_first_two(in_files):
  if len(in_files)<2:
    raise ValueError('Length of input list must be at least 2')
  return in_files[0], in_files[1]

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

def MakeAtlasNode(atlasDirectory):
    """Gererate an DataGrabber node that creates outputs for all the
    elements of the atlas.
    """
    #Generate by running a file system list "ls -1 $AtlasDir *.nii.gz *.xml"
    atlas_file_list="AtlasPVDefinition.xml ALLPVAIR.nii.gz ALLPVBASALTISSUE.nii.gz ALLPVCRBLGM.nii.gz ALLPVCRBLWM.nii.gz ALLPVCSF.nii.gz ALLPVNOTCSF.nii.gz ALLPVNOTGM.nii.gz ALLPVNOTVB.nii.gz ALLPVNOTWM.nii.gz ALLPVSURFGM.nii.gz ALLPVVB.nii.gz ALLPVWM.nii.gz avg_t1.nii.gz avg_t2.nii.gz tempNOTVBBOX.nii.gz template_ABC_lables.nii.gz template_WMPM2_labels.nii.gz template_WMPM2_labels.txt template_brain.nii.gz template_cerebellum.nii.gz template_class.nii.gz template_headregion.nii.gz template_leftHemisphere.nii.gz template_nac_lables.nii.gz template_nac_lables.txt template_rightHemisphere.nii.gz template_t1.nii.gz template_t1_clipped.nii.gz template_t2.nii.gz template_t2_clipped.nii.gz template_ventricles.nii.gz"
    atlas_file_names=atlas_file_list.split(' ')
    ## Remove filename extensions for images, but replace . with _ for other file types
    atlas_file_keys=[fn.replace('.nii.gz','').replace('.','_') for fn in atlas_file_names]
    
    BAtlas = pe.Node(interface=nio.DataGrabber(outfields=atlas_file_keys),
                                               name='BAtlas')
    BAtlas.inputs.base_directory = atlasDirectory
    BAtlas.inputs.template = '*'
    ## Prefix every filename with atlasDirectory
    atlas_search_paths=['{0}'.format(fn) for fn in atlas_file_names]
    BAtlas.inputs.field_template = dict(zip(atlas_file_keys,atlas_search_paths))
    ## Give 'atlasDirectory' as the substitution argument
    atlas_template_args_match=[ [[]] for i in atlas_file_keys ] ##build a list of proper lenght with repeated entries
    BAtlas.inputs.template_args = dict(zip(atlas_file_keys,atlas_template_args_match))
    return BAtlas
 
## ---
def WorkupT1T2(ScanDir, T1Images, T2Images, Version=110, InterpolationMode="Linear", Mode=10, DwiList=[]):
  """ This is the main function to call when processing a single subject worth of
  data.  ScanDir is the base of the directory to place results, T1Images & T2Images
  are the lists of images to be used in the auto-workup.
  """

  if len(T1Images) < 1:
    print "ERROR:  Length of T1 image list is 0,  at least one T1 image must be specified."
    sys.exit(-1)
  if len(T2Images) < 1:
    print "ERROR:  Length of T2 image list is 0,  at least one T2 image must be specified."
    sys.exit(-1)

  ########### PIPELINE INITIALIZATION #############
  baw200 = pe.Workflow(name="BAW_200_workflow")
  baw200.config['execution'] = {
                                   'plugin':'Linear',
                                   'stop_on_first_crash':'True',
                                   'stop_on_first_rerun': 'False',
                                   'hash_method': 'timestamp',
                                   'single_thread_matlab':'True',
                                   'remove_unnecessary_outputs':'False',
                                   'use_relative_paths':'False',
                                   'remove_node_directories':'False'
                                   }
  baw200.config['logging'] = {
    'workflow_level':'DEBUG',
    'filemanip_level':'DEBUG',
    'interface_level':'DEBUG'
  }
  baw200.base_dir = ScanDir

  T1NiftiImageList = T1Images
  T2NiftiImageList = T2Images

  T1Basename = ConstellationBasename(T1NiftiImageList[0])
  T2Basename = ConstellationBasename(T2NiftiImageList[0])

  ########################################################
  # Run ACPC Detect on first T1 Image - Base Image
  ########################################################
  #HACK:  Only one input allowed here
  T1_0 = pe.Node(interface=nio.DataGrabber( outfields=['T2_0_file','T1_0_file']) , name='T1T2_Raw_Inputs')
  T1_0.inputs.base_directory = os.path.dirname(T1NiftiImageList[0])
  T1_0.inputs.template = '*'
  T1_0.inputs.field_template = dict(T1_0_file=os.path.basename(T1NiftiImageList[0]),
                                    T2_0_file=os.path.basename(T2NiftiImageList[0]))
  T1_0.inputs.template_args =  dict(T1_0_file=[[]], T2_0_file=[[]]) #No template args to substitute

  ########################################################
  # Run ACPC Detect on First T1 Image
  ########################################################
  BCD_T1_0 = pe.Node(interface=BRAINSConstellationDetector(), name="BCD_T1_0")
  ##  Use program default BCD_T1_0.inputs.inputTemplateModel = T1ACPCModelFile
  BCD_T1_0.inputs.outputVolume =   T1Basename + "_ACPC_InPlace.nii.gz"                #$# T1AcpcImageList
  BCD_T1_0.inputs.outputTransform =  T1Basename + "_ACPC_transform.mat"
  BCD_T1_0.inputs.outputLandmarksInInputSpace = T1Basename + "_ACPC_Original.fcsv"
  BCD_T1_0.inputs.outputLandmarksInACPCAlignedSpace = T1Basename + "_ACPC_Landmarks.fcsv"
  BCD_T1_0.inputs.outputMRML = T1Basename + "_ACPC_Scene.mrml"
  BCD_T1_0.inputs.interpolationMode = InterpolationMode
  BCD_T1_0.inputs.houghEyeDetectorMode = 1
  BCD_T1_0.inputs.acLowerBound = 80
  
  #BCD_T1_0_ACPC=pe.Node(interface=Rename(format_string=Stage1ResultsDir + "/" + T1Basename + "_ACPC_InPlace.nii.gz"),name='BCD_T1_0_ACPC')
  #(BCD_T1_0,BCD_T1_0_ACPC, [('outputVolume', 'in_file')])
  
  # Entries below are of the form:
  # (node1, node2, [(out_source1, out_dest1), (out_source2, out_dest2), ...])
  baw200.connect([
                  (T1_0,BCD_T1_0, [('T1_0_file', 'inputVolume')]),
  ])


  ########################################################
  # Run BABC on Multi-modal images
  ########################################################
  
  MergeT1T2 = pe.Node(interface=Merge(2),name='MergeT1T2')
  
  baw200.connect([
    (BCD_T1_0,MergeT1T2,[('outputVolume','in1')]),
    (T1_0,MergeT1T2,[('T2_0_file','in2')])
  ])
  
  #AtlasNode='/scratch/johnsonhj/src/BRAINS4-build/bin/Atlas/Atlas_20110607'
  #HACK:  Needs to be a config file
  AtlasNode='/Users/johnsonhj/src/BRAINS4-build/bin/Atlas/Atlas_20110607'
  BAtlas = MakeAtlasNode(AtlasNode) ## Call function to create node
  
  BABC= pe.Node(interface=BRAINSABC(), name="BABC")
  BABC.inputs.debuglevel = 0
  BABC.inputs.maxIterations = 3
  BABC.inputs.maxBiasDegree = 4
  BABC.inputs.filterIteration = 3
  BABC.inputs.filterMethod = 'GradientAnisotropicDiffusion'
  BABC.inputs.gridSize = [28,20,24]
  BABC.inputs.outputFormat = "NIFTI"
  BABC.inputs.outputVolumes = ["t1_corrected.nii.gz","t2_corrected.nii.gz"]
  BABC.inputs.outputLabels = "labels.nii.gz"
  BABC.inputs.outputDirtyLabels = "DirtyLabels.nii.gz"
  BABC.inputs.posteriorTemplate = "POSTERIOR_%s.nii.gz"
  BABC.inputs.atlasToSubjectTransform = "atlas_to_subject.mat"
  
  BABC.inputs.resamplerInterpolatorType = InterpolationMode
  ##
  BABC.inputs.outputDir = 'BABC'
  BABC.inputs.inputVolumeTypes = ["T1","T2"]
  
  baw200.connect(BAtlas,'AtlasPVDefinition_xml',BABC,'atlasDefinition')
  baw200.connect([
    (MergeT1T2,BABC, [('out','inputVolumes')])
  ])

  """
  ##HACK: This can be one function with two returns.
  func = 'def split_outputs(listarg,index): return listarg[index]'
  
  firstArg=pe.Node(interface=Function(input_names=['listarg','index'], output_names=['value']),name="corrected_0")
  firstArg.inputs.function_str = func
  firstArg.inputs.index = 0
  secondArg=pe.Node(interface=Function(input_names=['listarg','index'], output_names=['value']),name="corrected_1")
  secondArg.inputs.function_str = func
  secondArg.inputs.index = 1
  """
  bfc_files = pe.Node(Function(input_names=['in_files'],    
                             output_names=['t1_corrected','t2_corrected'], 
                             function=get_first_two), 
                    name='bfc_files')
  
  baw200.connect(BABC,'outputVolumes',bfc_files,'in_files')
  
  """
  SplitT1T2Corrected=pe.Node(interface=Split(),name="SplitT1T2Corrected")
  SplitT1T2Corrected.inputs.splits = [ 1, 1 ]
 
  baw200.connect([
    (BABC,SplitT1T2Corrected,[('outputVolumes','inlist')])
  ])
  """
  ResampleAtlasNACLabels=pe.Node(interface=BRAINSResample(),name="ResampleAtlasNACLabels")
  ResampleAtlasNACLabels.inputs.interpolationMode = "NearestNeighbor"
  ResampleAtlasNACLabels.inputs.outputVolume = "atlasToSubjectNACLabels.nii.gz"
  
  baw200.connect(BABC,'atlasToSubjectTransform',ResampleAtlasNACLabels,'warpTransform')
  baw200.connect(bfc_files,'t1_corrected',ResampleAtlasNACLabels,'referenceVolume')
  baw200.connect(BAtlas,'template_nac_lables',ResampleAtlasNACLabels,'inputVolume')
  
  BMUSH=pe.Node(interface=BRAINSMush(),name="BMUSH")
  BMUSH.inputs.outputVolume = "MushImage.nii.gz"
  BMUSH.inputs.outputMask = "MushMask.nii.gz"
  BMUSH.inputs.lowerThresholdFactor = 1.2
  BMUSH.inputs.upperThresholdFactor = 0.55
  
  baw200.connect(bfc_files,'t1_corrected',BMUSH,'inputFirstVolume')
  baw200.connect(bfc_files,'t2_corrected',BMUSH,'inputSecondVolume')
  baw200.connect(BABC,'outputLabels',BMUSH,'inputMaskVolume')
  
  """
  baw200.connect([
    (SplitT1T2Corrected,BMUSH,[('out1','inputFirstVolume'),
                          ('out2','inputSecondVolume'),
                        ]
    ),
    (BABC,BMUSH, [('outputLabels','inputMaskVolume')])
  ])
  """
  
  
  baw200.run()
  baw200.write_graph()
  
if __name__ == "__main__":
    ############################  MAIN
    #OUTDIR=os.path.realpath(sys.argv[1])
    #T1s=[os.path.realpath(sys.argv[2]) ]
    #T2s=[os.path.realpath(sys.argv[3]) ]
    OUTDIR=os.path.realpath('/scratch/data')
    #ext='.nrrd'
    ext='.nii.gz'
    T1s=[OUTDIR+"/t1"+ext]
    T2s=[OUTDIR+"/t2"+ext]


    WorkupT1T2(OUTDIR,T1s,T2s)
    
