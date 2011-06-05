# emacs: -*- mode: python; py-indent-offset: 4; indent-tabs-mode: nil -*-
# vi: set ft=python sts=4 ts=4 sw=4 et:

#raise RuntimeWarning, 'SEM not fully implmented'
from BRAINSFit import *
from BRAINSResample import *
from BRAINSConstellationDetector import *
from BRAINSABC import *

"""Import necessary modules from nipype."""

import nipype.interfaces.io as nio           # Data i/o
import nipype.interfaces.utility as util     # utility
import nipype.pipeline.engine as pe          # pypeline engine
import os                                    # system T1IMGtions

"""

Preliminaries
-------------

Confirm package dependencies are installed.  (This is only for the
tutorial, rarely would you put this in your own code.)
"""
from nipype.utils.misc import package_check

package_check('numpy', '1.3', 'tutorial1')
package_check('scipy', '0.7', 'tutorial1')
package_check('networkx', '1.0', 'tutorial1')
package_check('IPython', '0.10', 'tutorial1')

# Specify the location of the data.

BASE_SCANID_DIR=[ '/scratch/data/NAMIC_PHD/10021/100026' ]
#ANONRAWDIR=BASE_SCANID_DIR+"/ANONRAW"
#SUBJID='10021'
#SCANID='100026'

infosource = pe.Node(interface=util.IdentityInterface(fields=['scan_dir']) , name="infosource")
infosource.iterables = [('scan_dir', BASE_SCANID_DIR )]

"""
Preprocessing pipeline nodes
----------------------------

Now we create a :class:`nipype.interfaces.io.DataSource` object and
fill in the information from above about the layout of our data.  The
:class:`nipype.pipeline.NodeWrapper` module wraps the interface object
and provides additional housekeeping and pipeline specific
T1IMGtionality.
"""
datasource = pe.Node(interface=nio.DataGrabber(infields=['scan_dir'],
                                               outfields=['T1IMG', 'T2IMG']),
                                               name = 'datasource')
datasource.inputs.base_directory = "/"
datasource.inputs.template = '*'
datasource.inputs.field_template = dict(T1IMG='%s/ANONRAW/*_T1_30.nrrd',T2IMG='%s/ANONRAW/*_T2_30.nrrd')
datasource.inputs.template_args  = dict(T1IMG=[['scan_dir']],T2IMG=[['scan_dir']])


BRAINSConstellationDetectorT1 = pe.Node(interface=BRAINSConstellationDetector(),name="BCD_T1")
BRAINSConstellationDetectorT1.inputs.outputResampledVolume = True
BRAINSConstellationDetectorT1.inputs.outputTransform = True
BRAINSConstellationDetectorT1.inputs.houghEyeDetectorMode = 1
BRAINSConstellationDetectorT1.inputs.acLowerBound = 80

coregister = pe.Node(interface=BRAINSFit(), name="coregister")
coregister.inputs.outputTransform = True
coregister.inputs.outputVolume = True
coregister.inputs.transformType = ["Rigid","Affine"]

reslice = pe.Node(interface=BRAINSResample(), name="reslice")
reslice.inputs.outputVolume = True

reslice_sink = pe.Node(interface=nio.DataSink(),name='reslice_sink')
reslice_sink.inputs.base_directory = os.path.abspath('slicer_tutorial/final_data')



pipeline = pe.Workflow(name="pipeline")
pipeline.base_dir = BASE_SCANID_DIR[0]+"/10_AUTO_20110604"


pipeline.connect([(infosource, datasource, [('scan_dir', 'scan_dir')]),
                  (datasource,coregister,[('T1IMG','movingVolume')]),
                  (datasource,coregister,[('T2IMG','fixedVolume')]),
                  (coregister,reslice,[('outputTransform', 'warpTransform')]),
                  (datasource,reslice,[('T1IMG','inputVolume')]),
                  (datasource,reslice,[('T2IMG','referenceVolume')])
                  ])
pipeline.connect([( datasource,BRAINSConstellationDetectorT1,[('T2IMG','inputVolume')]) ] )
                    
pipeline.connect(reslice, 'outputVolume', reslice_sink,'reslice_outputVolume')

pipeline.run()
pipeline.write_graph()
pipeline.write_hierarchical_dotfile()
