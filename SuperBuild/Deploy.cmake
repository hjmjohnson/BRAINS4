#
# Build a directory whose contents can be deployed standalone as the installed version of
# BRAINS4

#
# standard place to deposit build stuff.
set(Deploy_DIR ${${CMAKE_PROJECT_NAME}_BINARY_DIR}/Deploy)

#
# first, create the Deployment directory
file(MAKE_DIRECTORY ${Deploy_DIR}/lib)
file(MAKE_DIRECTORY ${Deploy_DIR}/bin)

#
# delete junk
file(GLOB tclsh ${${CMAKE_PROJECT_NAME}_BINARY_DIR}/src/bin/tclsh*)
file(GLOB itkwish ${${CMAKE_PROJECT_NAME}_BINARY_DIR}/src/bin/itkwish*)
file(GLOB wish ${${CMAKE_PROJECT_NAME}_BINARY_DIR}/src/bin/wish*)
file(GLOB vtkjunk ${${CMAKE_PROJECT_NAME}_BINARY_DIR}/src/bin/vtk*)

foreach(cmtk_program cmtk_execs avg_adm congeal congeal_warp describe groupwise_rmi groupwise_init
groupwise_rmi_warp asegment average_affine average_edt average_grey average_images
average_labels concat_affine convert convertx convert_warp film filter
glm gregxform histogram imagemath jidb levelset make_initial_affine mat2dof
mip mk_analyze_hdr mk_nifti_hdr mk_phantom_3d mrbias overlap probe_xform
randompxls randomwarp reformatx registration registrationx regress
reorient runcheck sequence similarity split statistics sympl
symplx ttest unsplit volume_injection volume_reconstruction vtkxform
warp warpx warp2ps xform2dfield xform2itk xform2scalar mcaffine mcwarp
dcm2image)
  set(cmtk_junk ${cmtk_junk} "${${CMAKE_PROJECT_NAME}_BINARY_DIR}/src/bin/${cmtk_program}")
endforeach(cmtk_program)

set(dont_copy ${tclsh} ${itkwish} ${wish} ${vtkjunk} ${cmtk_junk} lproj)

#
# copy directories
foreach(dir_to_copy bin lib)
  file(GLOB file_list ${${CMAKE_PROJECT_NAME}_BINARY_DIR}/src/${dir_to_copy}/*)
  list(REMOVE_ITEM file_list ${dont_copy})
  foreach(file_to_copy ${file_list})
    get_filename_component(target_name ${file_to_copy} NAME)
    set(target ${Deploy_DIR}/${dir_to_copy}/${target_name})
    if(IS_DIRECTORY ${file_to_copy})
      message("  Copying directory ${file_to_copy}...")
      execute_process(COMMAND "${CMAKE_COMMAND}"
        -E copy_directory
        ${file_to_copy}
        ${target}
        )
    else(IS_DIRECTORY ${file_to_copy})
      message("  Copying ${file_to_copy}...")
      execute_process(COMMAND "${CMAKE_COMMAND}"
        -E copy_if_different "${file_to_copy}"
        "${target}"
        )
    endif(IS_DIRECTORY ${file_to_copy})
    message("    To ${target}")
  endforeach(file_to_copy)
endforeach(dir_to_copy)


#
# patch the setup scripts
foreach(setup_ext csh sh)
  message("Patching ${Deploy_DIR}/bin/${CMAKE_PROJECT_NAME}_setup.${setup_ext}")
  # execute_process(COMMAND sed
  #   -e "s@${CMAKE_INSTALL_PREFIX}@${CMAKE_INSTALL_PREFIX}@"
  #   INPUT_FILE "${Deploy_DIR}/bin/${CMAKE_PROJECT_NAME}_setup.${setup_ext}"
  #   OUTPUT_FILE "${Deploy_DIR}/bin/${CMAKE_PROJECT_NAME}_setup.tmp")
  # execute_process(COMMAND ${CMAKE_COMMAND} -E
  #   copy "${Deploy_DIR}/bin/${CMAKE_PROJECT_NAME}_setup.tmp"
  #   "${Deploy_DIR}/bin/${CMAKE_PROJECT_NAME}_setup.${setup_ext}"
  #   )
  # execute_process(COMMAND ${CMAKE_COMMAND} -E
  #   remove "${Deploy_DIR}/bin/${CMAKE_PROJECT_NAME}_setup.tmp")
  set(fixfile "${Deploy_DIR}/bin/${CMAKE_PROJECT_NAME}_setup.${setup_ext}")
  file(READ ${fixfile} fixed)
  string(REPLACE "${CMAKE_INSTALL_PREFIX}"
    "${CMAKE_INSTALL_PREFIX}" fixed "${fixed}")
  file(WRITE ${fixfile} "${fixed}")
endforeach(setup_ext)

#
# create a tar file for distribution
set(TAR_NAME 
"${Deploy_DIR}/BRAINS4-${DEPLOY_SYSTEM_NAME}.tar.gz")
message("Creating ${TAR_NAME}")

execute_process(COMMAND ${CMAKE_COMMAND} -E
  tar czf "${TAR_NAME}" bin lib
  WORKING_DIRECTORY ${Deploy_DIR}
)
