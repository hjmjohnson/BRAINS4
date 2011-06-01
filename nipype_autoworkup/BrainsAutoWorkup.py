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

#import nipype.interfaces.matlab as mlab      # how to run matlab
#import nipype.interfaces.fsl as fsl          # fsl
#import nipype.interfaces.utility as util     # utility
#import nipype.algorithms.rapidart as ra      # artifact detection
#import nipype.algorithms.modelgen as model   # model specification
import enthought.traits.api as traits
import nipype.pipeline.engine as pe          # pypeline engine

import nipype.pipeline.plugins

from nipype.interfaces.base import BaseInterface, TraitedSpec

import brains

BRAINSConstellationDetector=brains.BRAINS4CommandLine(module="/scratch/johnsonhj/src/BRAINS4-build/bin/BRAINSConstellationDetector")
BRAINSFit=brains.BRAINS4CommandLine(module="/scratch/johnsonhj/src/BRAINS4-build/bin/BRAINSFit")

import os, sys, string
#import shutil, glob, re

def WorkupT1T2(ScanDir, T1Images, T2Images, Version=110, InterpolationMode="Linear", Mode=10, DwiList=[]):

  ########################################################
  # Run ACPC Detect on T1 Images
  ########################################################
  BRAINSFitAlignT2T1 = pe.Node(interface=brains.BRAINS4CommandLine(
    module="/scratch/johnsonhj/src/BRAINS4-build/bin/BRAINSFit"), name='BRAINSFitAlignT2T1')
  BRAINSFitAlignT2T1.inputs.fixedVolume = "/scratch/data/t1.nrrd"
  BRAINSFitAlignT2T1.inputs.movingVolume = "/scratch/data/t2.nrrd"
  BRAINSFitAlignT2T1.inputs.outputVolume = "/tmp/BRAINSFit.nrrd"
  BRAINSFitAlignT2T1.inputs.transformType = ["Rigid","Affine"]
  #BRAINSFitAlignT2T1.inputs.outputTransform = True
  BRAINSFitAlignT2T1.interface.inputs.fixedVolume="/scratch/data/t1.nrrd"
  print("="*80)
  print BRAINSFitAlignT2T1.interface.cmdline
  print("^"*80)
  #newret = BRAINSFitAlignT2T1.run()
  
  ResampleAlignT2T1 = pe.Node(interface=brains.BRAINS4CommandLine(module="/scratch/johnsonhj/src/BRAINS4-build/bin/BRAINSResample"), name='ResampleAlignT2T1')
  ResampleAlignT2T1.inputs.referenceVolume = "/scratch/data/t1.nrrd"
  ResampleAlignT2T1.inputs.inputVolume = "/scratch/data/t2.nrrd"
  #ResampleAlignT2T1.inputs.warpTransform = "/tmp/test22.mat"
  ResampleAlignT2T1.inputs.outputVolume = "/tmp/BRAINSResample.nrrd"
  print("="*80)
  print ResampleAlignT2T1.interface.cmdline
  print("^"*80)
  #newret = ResampleAlignT2T1.run()
  
  workflow = pe.Workflow(name = 'ResampleTesting')
  workflow.base_dir = "/tmp"
  workflow.add_nodes([BRAINSFitAlignT2T1])
  
  #workflow.add_nodes([BRAINSFitAlignT2T1,ResampleAlignT2T1])
  #workflow.connect( [
  #(BRAINSFitAlignT2T1,ResampleAlignT2T1, [('outputTransform','warpTransform')])
  #    ])

#  workflow.write_graph()
  workflow.run()
  
  print "**************"
  print ScanDir
  print "**************"
"""
  AWWorkflow = pe.Workflow(name="AW_TEST")
  AWWorkflow.base_dir = ScanDir


  # Entries below are of the form:
  # (node1, node2, [(out_source1, out_dest1), (out_source2, out_dest2), ...])
  AWWorkflow.connect(
BRAINSConstellationDetectorT1Batch, '', [('outputVolume', 'T1ImageList')])
  ])

  AWWorkflow.run()
"""

############################  MAIN
## ../../BRAINS4-build/Library/Framework/Python.framework/Versions/2.6/bin/python BrainsAutoWorkup.py /hjohnson/NAMIC/ReferenceAtlas_20110511/ /hjohnson/NAMIC/ReferenceAtlas_20110511/template_t1.nii.gz /hjohnson/NAMIC/ReferenceAtlas_20110511/template_t2.nii.gz
"""
OUTDIR=os.path.realpath(sys.argv[1])
T1s=[os.path.realpath(sys.argv[2]) ]
T2s=[os.path.realpath(sys.argv[3]) ]
"""
OUTDIR=""
T1s=[""]
T2s=[""]


WorkupT1T2(OUTDIR,T1s,T2s)

##  ../../BRAINS4-build/Library/Framework/Python.framework/Versions/2.6/bin/python BrainsAutoWorkup.py /hjohnson/NAMIC/ReferenceAtlas_20110511/ /hjohnson/NAMIC/ReferenceAtlas_20110511/template_t1.nii.gz /hjohnson/NAMIC/ReferenceAtlas_20110511/template_t2.nii.gz
