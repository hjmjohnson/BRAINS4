from nipype.interfaces.slicer import generate_classes as SEM
import glob
import os
import subprocess

if __name__ == "__main__":
    ## HACK:  Need arg_parse here for specifying paths.
    test_list="""    
BRAINSFit
BRAINSDemonWarp
BRAINSAlignMSP
BRAINSCleanMask
BRAINSClipInferior
BRAINSConstellationDetector
BRAINSConstellationModeler
BRAINSCut
BRAINSABC
BRAINSInitilizedControlPoints
BRAINSLinearModelerEPCA
BRAINSLmkTransform
BRAINSMultiModeSegment
BRAINSROIAuto
BRAINSResample
BRAINSTrimForegroundInDirection
DumpBinTrainingVectors
ESLR
GenerateBrainClippedImage
GenerateCsfClippedFromClassifiedImage
GenerateLabelMapFromProbabilityMap
GenerateSummedGradientImage
HistogramMatchingFilter
ImageRegionPlotter
JointHistogram
NeighborhoodConnectedImageFilter
ProcessShader
ShuffleVectorsModule
SimpleGaussian
SimpleGaussianFunctional
StandardizeMaskIntensity
VBRAINSDemonWarp
WriteFeaturesforROI
extractNrrdVectorIndex
fcsv_to_matlab_new
gtractAnisotropyMap
gtractAverageBvalues
gtractClipAnisotropy
gtractCoRegAnatomy
gtractConcatDwi
gtractCopyImageOrientation
gtractCoregBvalues
gtractImageConformity
gtractInvertBSplineTransform
gtractInvertDeformationField
gtractInvertRigidTransform
gtractResampleAnisotropy
gtractResampleB0
gtractResampleCodeImage
gtractResampleDWIInPlace
gtractTensor
gtractTransformToDeformationField
"""
    SEM_exe=list()
    exec_dir = '/scratch/src/BRAINS4-build/bin'
    for candidate_exe in test_list.split():
        test_command=exec_dir+"/"+candidate_exe+" --xml"
        xmlReturnValue = subprocess.Popen(test_command, stdout=subprocess.PIPE, shell=True).communicate()[0]
        isThisAnSEMExecutable = xmlReturnValue.find("<executable>")
        if isThisAnSEMExecutable != -1:
            SEM_exe.append(candidate_exe)

    print("SEM_PROGRAMS: {0}".format(SEM_exe))
    
    ## NOTE:  For now either the launcher needs to be found on the default path, or
    ##        every tool in the modules list must be found on the default path
    ##        AND calling the module with --xml must be supported and compliant.
    ##       modules_list = ['BRAINSConstellationDetector','BRAINSFit', 'BRAINSResample', 'BRAINSDemonWarp', 'BRAINSROIAuto']
    ## SlicerExecutionModel compliant tools that are usually statically built, and don't need the Slicer3 --launcher
    SEM.generate_all_classes(modules_list=SEM_exe,launcher=[])


### This uses the unsuppored "point" SEM type
### TransformFromFiducials
### This uses the unsupported "geometry" SEM type
### compareTractInclusion
### gtractCreateGuideFiber
### gtractFiberTracking
### gtractCostFastMarching
### gtractFastMarchingTracking
### gtractResampleFibers