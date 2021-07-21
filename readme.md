# Word-to-DITA

Version: 1.0.0RC28

The input to this plugin is Word DOCX files. If you have DOC files you can use
the Microsoft-provided Office Migration Planning Manager (OMPM) to produce DOCX files
from DOC files (http://technet.microsoft.com/en-us/library/cc179179.aspx#section1)

NOTE: This project uses the DITA Community plugin org.dita-community.common.xslt as a git
submodule. 

## Documentation

See the main DITA for Publishers documentation at http://www.dita4publishers.org/d4p-users-guide/ in Part III.

## Installation

### DITA Open Toolkit 2.x+

1. Unzip the `dita4publishers-word2dita-plugins-n.n.nRCnn-ot-n.n.n.zip` to the Open Toolkit's `plugins` directory so that each plugin's directory is a direct child of `plugins`
1. Run the commmand `dita install` to install the new plugins

If the plugins were previously installed you may need to uninstall them first using `dita uninstall {pluginname}`

### DITA Open Toolkit 1.8.5

1. Unzip this so that the `org.dita4publishers.word2dita` directory 
is a child of the DITA-OT `plugins` directory (e.g. `C:\DITA-OT\plugins\`), and you should be ready to go. 
2. Run `ant -f integrator.xml` command from the DITA OT directory to integrate the plug-ins.

