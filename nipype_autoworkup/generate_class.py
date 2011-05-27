#!/usr/bin/python

from nipype.interfaces.base import CommandLine
import subprocess as sub
import xml.dom.minidom
import enthought.traits.api as traits
import sys, os

def generate_all_classes():
    init_imports = ""
    program_path = sys.argv[1]
    module = os.path.basename(program_path)
    code = generate_class(module,program_path)
    f = open("%s.py"%module, "w")
    f.write(code)
    f.close()


def generate_class(module,program_path):
    dom = grab_xml(program_path)
    inputTraits = []
    outputTraits = []
    outputs_filenames = {}

    #self._outputs_nodes = []

    for paramGroup in dom.getElementsByTagName("parameters"):
        for param in paramGroup.childNodes:
            if param.nodeName in ['label', 'description', '#text', '#comment']:
                continue
            traitsParams = {}

            name = param.getElementsByTagName('name')[0].firstChild.nodeValue

            longFlagNode = param.getElementsByTagName('longflag')
            if longFlagNode:
                traitsParams["argstr"] = "--" + longFlagNode[0].firstChild.nodeValue + " "
            else:
                traitsParams["argstr"] = "--" + name + " "


            argsDict = {'file': '%s', 'integer': "%d", 'double': "%f", 'float': "%f", 'image': "%s", 'transform': "%s", 'boolean': '', 'string-enumeration': '%s', 'string': "%s", 'integer-enumeration' : '%s', 'geometry': '%s', 'directory': '%s'}

            if param.nodeName.endswith('-vector'):
                traitsParams["argstr"] += argsDict[param.nodeName[:-7]]
            else:
                traitsParams["argstr"] += argsDict[param.nodeName]

            index = param.getElementsByTagName('index')
            if index:
                traitsParams["position"] = index[0].firstChild.nodeValue

            desc = param.getElementsByTagName('description')
            if index:
                traitsParams["desc"] = desc[0].firstChild.nodeValue

            name = param.getElementsByTagName('name')[0].firstChild.nodeValue

            typesDict = {'integer': "traits.Int", 'double': "traits.Float", 'float': "traits.Float", 'image': "File", 'transform': "File", 'boolean': "traits.Bool", 'string': "traits.Str", 'file':"File", 'geometry':"traits.Str", 'directory': 'Directory'}

            if param.nodeName.endswith('-enumeration'):
                type = "traits.Enum"
                values = [el.firstChild.nodeValue for el in param.getElementsByTagName('element')]
            elif param.nodeName.endswith('-vector'):
                type = "traits.List"
                values = [typesDict[param.nodeName[:-7]]]
                traitsParams["sep"] = ','
            else:
                values = []
                type = typesDict[param.nodeName]

            if param.nodeName in ['file', 'directory', 'image', 'transform'] and param.getElementsByTagName('channel')[0].firstChild.nodeValue == 'output':
                inputTraits.append("%s = traits.Either(traits.Bool, File, %s)"%(name, parse_params(traitsParams)))
                outputTraits.append("%s = File(exists=True, %s)"%(name, parse_params(traitsParams)))

                outputs_filenames[name] = gen_filename_from_param(param)
            else:
                if param.nodeName in ['file', 'directory', 'image', 'transform']:
                    traitsParams["exists"] = True
                inputTraits.append("%s = %s(%s %s)"%(name, type, parse_values(values), parse_params(traitsParams)))

    input_spec_code = "class " + module + "InputSpec(CommandLineInputSpec):\n"
    for trait in inputTraits:
        input_spec_code += "\t" + trait + "\n"

    output_spec_code = "class " + module + "OutputSpec(TraitedSpec):\n"
    for trait in outputTraits:
        output_spec_code += "\t" + trait + "\n"

    output_filenames_code = "_outputs_filenames = {"
    output_filenames_code += ",".join(["'%s':'%s'"%(key,value) for key,value in outputs_filenames.iteritems()])
    output_filenames_code += "}"


    input_spec_code += "\n\n"
    output_spec_code += "\n\n"

    imports = """from nipype.interfaces.base import CommandLine, CommandLineInputSpec, TraitedSpec
import enthought.traits.api as traits
import os
from nipype.interfaces.base import File
from nipype.interfaces.base import Directory
\n\n"""

    template = """class %name%(CommandLine):

    input_spec = %name%InputSpec
    output_spec = %name%OutputSpec
    _cmd = "%program_path% "
    %output_filenames_code%

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
        return super(%name%, self)._format_arg(name, spec, value)\n\n"""

    main_class = template.replace("%name%", module).replace("%output_filenames_code%", output_filenames_code).replace("%program_path%",os.path.realpath(program_path))

    return imports + input_spec_code + output_spec_code + main_class

def grab_xml(module):
        xmlString=""
        if module.find(".xml") != -1:
            f = open(module,'rb')
            xmlString = f.read()
            f.close()
            return xml.dom.minidom.parseString(xmlString)
        else:
            p = sub.Popen([module,"--xml"],stdout=sub.PIPE,stderr=sub.PIPE)
            output, errors = p.communicate()
            xmlString = output
            #print xmlString
            return xml.dom.minidom.parseString(xmlString)

def parse_params(params):
    list = []
    for key, value in params.iteritems():
        list.append('%s = "%s"'%(key, value))

    return ",".join(list)

def parse_values(values):
    values = ['"%s"'%value for value in values]
    if len(values) > 0:
        retstr = ",".join(values) + ","
    else:
        retstr = ""
    return retstr

def gen_filename_from_param(param):
    base = param.getElementsByTagName('name')[0].firstChild.nodeValue
    fileExtensions = param.getAttribute("fileExtensions")
    if fileExtensions:
        ext = fileExtensions
    else:
        ext = {'image': '.nii', 'transform': '.txt', 'file': '', 'directory': ''}[param.nodeName]
    return base + ext

if len(sys.argv) != 2:
  print "This program takes one argument (the program whose xml is to be parsed."
  sys.exit(1)

if __name__ == "__main__":
    generate_all_classes()
