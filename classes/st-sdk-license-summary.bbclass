# Configure on BSP side this var if you expect the summary to be generated
ENABLE_IMAGE_LICENSE_SUMMARY ?= "0"

python do_write_sdk_license_create_summary() {
    if d.getVar('ENABLE_IMAGE_LICENSE_SUMMARY') == "1":
        license_sdk_create_summary(d)
    else:
        bb.warn("IMG LIC SUM: Please set ENABLE_IMAGE_LICENSE_SUMMARY to '1' to enable licence summary")
}

def license_sdk_create_summary(d):
    import re
    tab =  d.expand("${LICENSE_IMAGE_CONTENT_WITH_TAB}")
    ref_sdk_name_full = d.expand("${TOOLCHAIN_OUTPUTNAME}")
    temp_deploy_sdk_dir = d.expand("${SDKDEPLOYDIR}")
    pkgdata_dir = d.expand("${TMPDIR}/pkgdata/${MACHINE}")
    pkgdata_host_dir = d.expand("${TMPDIR}/pkgdata/${SDK_SYS}")

    image_list_arrray = []
    # host manifest
    image_list_arrray.append([ "List of packages / tools used on host part",
            "host", ref_sdk_name_full + ".host.manifest" ])
    # target manifest
    image_list_arrray.append([ "List of packages associated to package present on image",
            "target", ref_sdk_name_full + ".target.manifest" ])
    if tab.startswith("1"):
        with_tab = 1
    else:
        with_tab = None

    def private_open(filename):
        result = None
        if os.path.exists(filename):
            try:
                with open(filename, "r") as lic:
                    result = lic.readlines()
            except IOError:
                bb.warn("SDK LIC SUM: Cannot open file %s" % (filename))
                result = ""
            except:
                bb.warn("SDK LIC SUM: Error with file %s" % (filename))
                result = ""
        else:
            bb.warn("SDK LIC SUM: File does not exist with open file %s" % (filename))

            result = ""
        return result

    class HTMLSummaryfile():
        ''' format definition '''
        bold = "font-weight: bold; background-color: #cccccc;"
        red = "background-color: #ff0000;"
        center_format = "align: center;"
        border_format = "border: 1;"
        wrap_format = ""
        wrap_red_format = "background-color: #ff0000;"

        opened_file = None

        def openfile(self, file_name):
            self.opened_file = open(file_name, 'w')
        def closefile(self):
            self.opened_file.close()
        def startTable(self, style=None):
            if style:
                self.opened_file.write("<TABLE STYLE='%s'>\n" % style)
            else:
                self.opened_file.write("<TABLE border=1>\n")
        def stopTable(self):
            self.opened_file.write("</TABLE>\n")
        def startRow(self, style=None):
            self.opened_file.write("<TR>\n")
        def stopRow(self, style=None):
            self.opened_file.write("</TR>\n")
        def startColumn(self, style=None):
            if style:
                self.opened_file.write("<TD STYLE='%s'>\n")
            else:
                self.opened_file.write("<TD>\n")
        def stopColumn(self, style=None):
            self.opened_file.write("</TR>\n")
        def addColumnHeaderContent(self, content, style=None):
            if style:
                self.opened_file.write("<TH STYLE='%s'>%s</TH>\n" % (style, content))
            else:
                self.opened_file.write("<TH><B>%s</B></TH>\n" % content)
        def addColumnContent(self, content, style=None):
            if style:
                self.opened_file.write("<TD STYLE='%s'>%s</TD>\n" % (style, content))
            else:
                self.opened_file.write("<TD>%s</TD>\n" % content)
        def addColumnURLOUTContent(self, content, url, style=None):
            if style:
                self.opened_file.write("<TD STYLE='%s'><A HREF='%s' TARGET='_blank'>%s</A></TD>\n" % (style, url, content))
            else:
                self.opened_file.write("<TD><A HREF='%s' TARGET='_blank'>%s</A></TD>\n" % (url, content))
        def addColumnEmptyContent(self, style=None):
            if style:
                self.opened_file.write("<TD STYLE='%s'><BR/></TD>\n" % style)
            else:
                self.opened_file.write("<TD><BR/></TD>\n")
        def addNewLine(self):
            self.opened_file.write("<BR/>\n")
        def addContent(self, content):
            self.opened_file.write(content)
        def addURLContent(self, content, url):
            self.opened_file.write("<A HREF='%s'>%s</A>\n" %(url, content))
        def startBlock(self):
            self.opened_file.write("<UL>\n")
        def stopBlock(self):
            self.opened_file.write("</UL>\n")
        def addAnchor(self, anchor):
            self.opened_file.write("<A name='%s'/>\n" % anchor)
        def startDiv(self, anchor, title, style=None):
            self.opened_file.write("<div id='%s' class='tabcontent'>\n" % anchor)
            self.opened_file.write("<H1>%s</H1>\n" % title)

        def stopDiv(self):
            self.opened_file.write("</div>\n")
        def beginHtml(self):
            self.opened_file.write("<HTML>\n")
            self.opened_file.write('<HEAD>\n')
            self.opened_file.write("   <STYLE TYPE='text/css'>\n")
            self.opened_file.write("/* Style the tab buttons */\n")
            self.opened_file.write(".tablink {\n")
            self.opened_file.write("    background-color: #555;\n")
            self.opened_file.write("    color: white;\n")
            self.opened_file.write("    float: left;\n")
            self.opened_file.write("    border: none;\n")
            self.opened_file.write("    outline: none;\n")
            self.opened_file.write("    cursor: pointer;\n")
            self.opened_file.write("    padding: 14px 16px;\n")
            self.opened_file.write("    font-size: 17px;\n")
            self.opened_file.write("    width: 25%;\n")
            self.opened_file.write("}\n")
            self.opened_file.write("\n")
            self.opened_file.write("/* Change background color of buttons on hover */\n")
            self.opened_file.write(".tablink:hover {\n")
            self.opened_file.write("    background-color: #777;\n")
            self.opened_file.write("}\n")
            self.opened_file.write("\n")
            self.opened_file.write("/* Set default styles for tab content */\n")
            self.opened_file.write(".tabcontent {\n")
            self.opened_file.write("    color: black;\n")
            self.opened_file.write("    display: none;\n")
            self.opened_file.write("    padding: 50px;\n")
            self.opened_file.write("    text-align: left;\n")
            self.opened_file.write("}\n")
            self.opened_file.write("\n")
            self.opened_file.write("/* Style each tab content individually */\n")
            self.opened_file.write("#introduction {background-color: white;}\n")
            self.opened_file.write("#image_content {background-color: white;}\n")
            self.opened_file.write("#OE_SPDX_LICENSE {background-color: white;}\n")
            self.opened_file.write("   </STYLE>\n")
            self.opened_file.write("</HEAD>\n")
        def endHtml(self):
            self.opened_file.write("</HTML>\n")
        def beginBody(self, tab=None):
            self.opened_file.write("<BODY>\n")
            if tab:
                self.opened_file.write('   <button class="tablink" onclick="openTab(\'introduction\', this)" id="defaultOpen">Main</button>\n')
                self.opened_file.write('   <button class="tablink" onclick="openTab(\'sdk_content\', this)">Contents of Images</button>\n')
                self.opened_file.write('   <button class="tablink" onclick="openTab(\'OE_SPDX_LICENSE\', this)">SPDX License</button>\n')
            self.opened_file.write("\n")
        def endBody(self, tab=None):
            if tab:
                self.opened_file.write('<SCRIPT TYPE="text/javascript">\n')
                self.opened_file.write('function openTab(Name, elmnt) {\n')
                self.opened_file.write('    // Hide all elements with class="tabcontent" by default */\n')
                self.opened_file.write('    var i, tabcontent, tablinks;\n')
                self.opened_file.write('    tabcontent = document.getElementsByClassName("tabcontent");\n')
                self.opened_file.write('    for (i = 0; i < tabcontent.length; i++) {\n')
                self.opened_file.write('        tabcontent[i].style.display = "none";\n')
                self.opened_file.write('    }\n')
                self.opened_file.write('\n')
                self.opened_file.write('    // Remove the background color of all tablinks/buttons\n')
                self.opened_file.write('    tablinks = document.getElementsByClassName("tablink");\n')
                self.opened_file.write('    for (i = 0; i < tablinks.length; i++) {\n')
                self.opened_file.write('        tablinks[i].style.backgroundColor = "";\n')
                self.opened_file.write('    }\n')
                self.opened_file.write('\n')
                self.opened_file.write('    // Show the specific tab content\n')
                self.opened_file.write('    document.getElementById(Name).style.display = "block";\n')
                self.opened_file.write('\n')
                self.opened_file.write('    // Add the specific color to the button used to open the tab content\n')
                self.opened_file.write('    elmnt.style.backgroundColor = \'white\';\n')
                self.opened_file.write('    elmnt.style.color = "black";\n')
                self.opened_file.write('}\n')
                self.opened_file.write('\n')
                self.opened_file.write('// Get the element with id="defaultOpen" and click on it\n')
                self.opened_file.write('document.getElementById("defaultOpen").click();\n')
                self.opened_file.write('</SCRIPT>\n')
            else:
                self.opened_file.write('<SCRIPT TYPE="text/javascript">\n')
                self.opened_file.write('    // display all elements with class="tabcontent" by default */\n')
                self.opened_file.write('    var i, tabcontent, tablinks;\n')
                self.opened_file.write('    tabcontent = document.getElementsByClassName("tabcontent");\n')
                self.opened_file.write('    for (i = 0; i < tabcontent.length; i++) {\n')
                self.opened_file.write('        tabcontent[i].style.display = "block";\n')
                self.opened_file.write('    }\n')
                self.opened_file.write('\n')
                self.opened_file.write('</SCRIPT>\n')

            self.opened_file.write("</BODY>\n")

    def findWholeWord(w):
        return re.compile(r'\b({0})\b'.format(w), flags=re.IGNORECASE).search

    def generate_spdx_license_sheet(html):
        SRC_DISTRIBUTE_LICENSES = ""
        SRC_DISTRIBUTE_LICENSES += "AAL Adobe AFL-1.2 AFL-2.0 AFL-2.1 AFL-3.0"
        SRC_DISTRIBUTE_LICENSES += " AGPL-3.0 ANTLR-PD Apache-1.0 Apache-1.1 Apache-2.0"
        SRC_DISTRIBUTE_LICENSES += " APL-1.0 APSL-1.0 APSL-1.1 APSL-1.2 APSL-2.0"
        SRC_DISTRIBUTE_LICENSES += " Artistic-1.0 Artistic-2.0 BitstreamVera BSD"
        SRC_DISTRIBUTE_LICENSES += " BSD-2-Clause BSD-3-Clause BSD-4-Clause BSL-1.0"
        SRC_DISTRIBUTE_LICENSES += " CATOSL-1.1 CC0-1.0 CC-BY-1.0 CC-BY-2.0 CC-BY-2.5"
        SRC_DISTRIBUTE_LICENSES += " CC-BY-3.0 CC-BY-NC-1.0 CC-BY-NC-2.0 CC-BY-NC-2.5"
        SRC_DISTRIBUTE_LICENSES += " CC-BY-NC-3.0 CC-BY-NC-ND-1.0 CC-BY-NC-ND-2.0"
        SRC_DISTRIBUTE_LICENSES += " CC-BY-NC-ND-2.5 CC-BY-NC-ND-3.0 CC-BY-NC-SA-1.0"
        SRC_DISTRIBUTE_LICENSES += " CC-BY-NC-SA-2.0 CC-BY-NC-SA-2.5 CC-BY-NC-SA-3.0"
        SRC_DISTRIBUTE_LICENSES += " CC-BY-ND-1.0 CC-BY-ND-2.0 CC-BY-ND-2.5 CC-BY-ND-3.0"
        SRC_DISTRIBUTE_LICENSES += " CC-BY-SA-1.0 CC-BY-SA-2.0 CC-BY-SA-2.5 CC-BY-SA-3.0"
        SRC_DISTRIBUTE_LICENSES += " CDDL-1.0 CECILL-1.0 CECILL-2.0 CECILL-B CECILL-C"
        SRC_DISTRIBUTE_LICENSES += " ClArtistic CPAL-1.0 CPL-1.0 CUA-OPL-1.0 DSSSL"
        SRC_DISTRIBUTE_LICENSES += " ECL-1.0 ECL-2.0 eCos-2.0 EDL-1.0 EFL-1.0 EFL-2.0"
        SRC_DISTRIBUTE_LICENSES += " Elfutils-Exception Entessa EPL-1.0 ErlPL-1.1"
        SRC_DISTRIBUTE_LICENSES += " EUDatagrid EUPL-1.0 EUPL-1.1 Fair Frameworx-1.0"
        SRC_DISTRIBUTE_LICENSES += " FreeType GFDL-1.1 GFDL-1.2 GFDL-1.3 GPL-1.0"
        SRC_DISTRIBUTE_LICENSES += " GPL-2.0 GPL-2.0-with-autoconf-exception"
        SRC_DISTRIBUTE_LICENSES += " GPL-2.0-with-classpath-exception"
        SRC_DISTRIBUTE_LICENSES += " GPL-2.0-with-font-exception"
        SRC_DISTRIBUTE_LICENSES += " GPL-2.0-with-GCC-exception"
        SRC_DISTRIBUTE_LICENSES += " GPL-2-with-bison-exception GPL-3.0"
        SRC_DISTRIBUTE_LICENSES += " GPL-3.0-with-autoconf-exception"
        SRC_DISTRIBUTE_LICENSES += " GPL-3.0-with-GCC-exception"
        SRC_DISTRIBUTE_LICENSES += " gSOAP-1 gSOAP-1.3b HPND IPA IPL-1.0 ISC LGPL-2.0"
        SRC_DISTRIBUTE_LICENSES += " LGPL-2.1 LGPL-3.0 Libpng LPL-1.02 LPPL-1.0 LPPL-1.1"
        SRC_DISTRIBUTE_LICENSES += " LPPL-1.2 LPPL-1.3c MirOS MIT Motosoto MPL-1.0"
        SRC_DISTRIBUTE_LICENSES += " MPL-1.1 MS-PL MS-RL Multics NASA-1.3 Nauman NCSA"
        SRC_DISTRIBUTE_LICENSES += " NGPL Nokia NPOSL-3.0 NTP OASIS OCLC-2.0 ODbL-1.0"
        SRC_DISTRIBUTE_LICENSES += " OFL-1.1 OGTSL OLDAP-2.8 OpenSSL OSL-1.0 OSL-2.0"
        SRC_DISTRIBUTE_LICENSES += " OSL-3.0 PD PHP-3.0 PostgreSQL Proprietary"
        SRC_DISTRIBUTE_LICENSES += " Python-2.0 QPL-1.0 RHeCos-1 RHeCos-1.1 RPL-1.5"
        SRC_DISTRIBUTE_LICENSES += " RPSL-1.0 RSCPL Ruby SAX-PD SGI-1 Simple-2.0 Sleepycat"
        SRC_DISTRIBUTE_LICENSES += " SPL-1.0 SugarCRM-1 SugarCRM-1.1.3 UCB VSL-1.0 W3C"
        SRC_DISTRIBUTE_LICENSES += " Watcom-1.0 WXwindows XFree86-1.0 XFree86-1.1 Xnet XSL YPL-1.1"
        SRC_DISTRIBUTE_LICENSES += " Zimbra-1.3 Zlib ZPL-1.1 ZPL-2.0 ZPL-2.1"

        ''' AGPL variations '''
        SPDXLICENSEMAP = [
            ["AGPL-3.0", ['AGPL-3', 'AGPLv3', 'AGPLv3.0'] ],
            # GPL variations
            ["GPL-1.0", ['GPL-1', 'GPLv1', 'GPLv1.0'] ],
            ["GPL-2.0", ['GPL-2', 'GPLv2', 'GPLv2.0'] ],
            ["GPL-3.0", ['GPL-3', 'GPLv3', 'GPLv3.0'] ],
            # LGPL variations
            ["LGPL-2.0", ['LGPLv2', 'LGPLv2.0'] ],
            ["LGPL-2.1", ['LGPL2.1', 'LGPLv2.1'] ],
            ["LGPL-3.0", ['LGPLv3']],
            # MPL variations
            ["MPL-1.0", ['MPL-1', 'MPLv1'] ],
            ["MPL-1.1", ['MPLv1.1'] ],
            ["MPL-2.0", ['MPLv2'] ],
            # MIT variations
            ["MIT", ['MIT-X', 'MIT-style'] ],
            # Openssl variations
            ["OpenSSL", ['openssl'] ],
            # Python variations
            ["Python-2.0", ['PSF', 'PSFv2', 'Python-2'] ],
            # Apache variations
            ["Apache-2.0", ['Apachev2', 'Apache-2'] ],
            # Artistic variations
            ["Artistic-1.0", ['Artisticv1', 'Artistic-1'] ],
            # Academic variations
            ["AFL-2.0", ['AFL-2', 'AFLv2'] ],
            ["AFL-1.2", ['AFL-1', 'AFLv1'] ],
            # Other variations
            ["EPL-1.0", ['EPLv1.0'] ],
            # Silicon Graphics variations
            ["SGI-1", ['SGIv1'] ]
        ];

        html.startDiv("OE_SPDX_LICENSE", "OE SPDX LICENSE")
        html.addAnchor("OE_SPDX_LICENSE")

        html.addContent("Openembedded validate the License with the SPDX license list. ")
        html.addNewLine()
        html.addContent("How Openembedded validate an License indicated on a package:")
        html.addNewLine()
        html.startBlock()
        html.addContent(" - remove all information after the last + on license( ex.: LGPLv2.1+ become GPLv2.1)")
        html.addNewLine()
        html.addContent(" - translate license with SPDX table: (LGPLV2.1 become LGPL-2.1)")
        html.addNewLine()
        html.addContent(" - verification with official list of license")
        html.addNewLine()
        html.stopBlock()

        html.startTable()
        html.startRow()
        html.addColumnHeaderContent("Official licenses used by Openembedded", html.bold)
        html.addColumnHeaderContent("Link to text of license", html.bold)
        html.stopRow()
        for lic in SRC_DISTRIBUTE_LICENSES.split(' '):
            html.startRow()
            html.addColumnContent(lic)
            html.addColumnURLOUTContent('['+lic+']', "http://git.openembedded.org/openembedded-core/tree/meta/files/common-licenses/" + lic )
            html.stopRow()
        html.stopTable()

        html.addNewLine()

        html.startTable()
        html.startRow()
        html.addColumnHeaderContent("License name", html.bold)
        html.addColumnHeaderContent("Authorized variations names", html.bold)
        html.stopRow()
        for lic in SPDXLICENSEMAP:
            html.startRow()
            html.addColumnContent(lic[0])
            html.startColumn()
            html.startTable("border: 0;")
            for auth_lic in lic[1]:
                html.startRow()
                html.addColumnContent(auth_lic)
                html.stopRow()
            html.stopTable()
            html.stopColumn()
            html.stopRow()
        html.stopTable()

        html.addNewLine()
        html.addNewLine()
        html.addNewLine()

        html.addContent("Information extracted from:")
        html.addNewLine()
        html.addURLContent("http://git.openembedded.org/openembedded-core/tree/meta/conf/licenses.conf", "http://git.openembedded.org/openembedded-core/tree/meta/conf/licenses.conf")
        html.addNewLine()
        html.addContent("All Text of License are available:")
        html.addNewLine()
        html.addURLContent("http://git.openembedded.org/openembedded-core/tree/meta/files/common-licenses", "http://git.openembedded.org/openembedded-core/tree/meta/files/common-licenses")
        html.addNewLine()
        html.stopDiv()

    def generate_introduction_sheet(html):
        general_MACHINE = d.getVar("MACHINE")
        general_DISTRO = d.getVar("DISTRO")
        general_DISTRO_VERSION = d.getVar("DISTRO_VERSION")
        general_DISTRO_CODENAME = d.getVar("DISTRO_CODENAME")

        html.startDiv("introduction", "")
        html.addAnchor("introduction")

        html.startTable()
        # Machine
        html.startRow()
        html.addColumnContent("MACHINE", html.bold)
        html.addColumnContent(general_MACHINE)
        html.stopRow()
        # Image
        html.startRow()
        html.addColumnContent("SDK", html.bold)
        html.addColumnContent(ref_sdk_name_full)
        html.stopRow()
        # DISTRO
        html.startRow()
        html.addColumnContent("DISTRO", html.bold)
        html.addColumnContent(general_DISTRO)
        html.stopRow()
        # DISTRO VERSION
        html.startRow()
        html.addColumnContent("VERSION", html.bold)
        html.addColumnContent(general_DISTRO_VERSION)
        html.stopRow()
        # DISTRO CODENAME
        html.startRow()
        html.addColumnContent("OE branch", html.bold)
        html.addColumnContent(general_DISTRO_CODENAME)
        html.stopRow()
        html.stopTable()

        html.addNewLine()
        html.addNewLine()

        license_file_to_read = os.path.join(temp_deploy_sdk_dir, "%s.license" % ref_sdk_name_full)
        contents = private_open(license_file_to_read)

        html.startTable()
        html.startRow()
        html.addColumnHeaderContent("License", html.bold)
        html.stopRow()
        html.startRow()
        html.startColumn()
        for l in contents:
            if len(l.rstrip('\n')) > 0:
                html.addContent(l.rstrip('\n'))
                html.addNewLine()
            else:
                html.addNewLine()
        html.stopColumn()
        html.stopRow()
        html.stopTable()

        html.stopDiv()

    def generate_image_content_sheet(html):
        html.startDiv("sdk_content", "SDK content")
        html.addAnchor("sdk_content")

        # boot binaries
        for img in image_list_arrray:
            _info_text = img[0]
            _info_type = img[1]
            _info_file = img[2]

            html.startTable()
            html.startRow()
            html.addColumnHeaderContent("SDK name (%s part):" % _info_type, html.bold)
            html.addColumnHeaderContent(ref_sdk_name_full)
            html.stopRow()
            html.stopTable()

            html.addNewLine()
            html.addContent(_info_text)
            html.addNewLine()

            file_to_read = temp_deploy_sdk_dir + "/" + _info_file
            contents = private_open(file_to_read)

            html.addAnchor("%s_binaries"% _info_type)
            html.startTable()
            html.startRow()
            html.addColumnHeaderContent("Recipe Name", html.bold)
            html.addColumnHeaderContent("Package Name", html.bold)
            html.addColumnHeaderContent("Version", html.bold)
            html.addColumnHeaderContent("License", html.bold)
            html.addColumnHeaderContent("Description", html.bold)
            html.stopRow()
            for p in contents:
                package_license = ""
                package_recipe = None
                package_name = p.split('\n')[0].split(' ')[0]
                package_version = None
                package_description = None
                package_summary = None
                if _info_type.startswith("host"):
                    package_file = pkgdata_host_dir + "/runtime-reverse/" + package_name
                else:
                    package_file = pkgdata_dir + "/runtime-reverse/" + package_name
                package_file_content = private_open(package_file)
                if len(package_file_content) == 0:
                    package_file = pkgdata_dir + "/runtime-reverse/" + package_name
                    package_file_content = private_open(package_file)
                r = re.compile("([^:]+):\s*(.*)")
                for line in package_file_content:
                    m = r.match(line)
                    if m:
                        if m.group(1) == "PN":
                            package_recipe =  m.group(2)
                        elif m.group(1).startswith("LICENSE"):
                            package_license = m.group(2)
                        elif m.group(1) == "PV":
                            package_version = m.group(2)
                        elif m.group(1).startswith("DESCRIPTION"):
                            package_description = m.group(2)
                        elif m.group(1).startswith("SUMMARY"):
                            package_summary = m.group(2)
                if findWholeWord("GPLv3")(package_license):
                    style = html.red
                    style_wrapped = html.wrap_red_format
                else:
                    style = None
                    style_wrapped = None
                html.startRow(style)
                if package_recipe:
                    html.addColumnContent(package_recipe, style)
                else:
                    html.addColumnContent("", style)
                if package_name:
                    html.addColumnContent(package_name, style)
                else:
                    html.addColumnContent("", style)
                if package_version:
                    html.addColumnContent(package_version, style)
                else:
                    html.addColumnContent("", style)
                if package_license:
                    html.addColumnContent(package_license, style)
                else:
                    html.addColumnContent("", style)
                if package_summary:
                    html.addColumnContent(package_summary, style_wrapped)
                else:
                    if package_description:
                        html.addColumnContent(package_description, style_wrapped)
                    else:
                        html.addColumnContent("", style)
                html.stopRow()
                package_license = None
                package_parent = None
                package_name = None
                package_version = None
                package_description = None
                package_summary = None

            html.stopTable()
            html.addNewLine()
            html.addNewLine()

        html.stopDiv()

    summary_file = os.path.join(temp_deploy_sdk_dir, "%s-license_content.html" % ref_sdk_name_full)
    # bb.warn("file generated %s" % (summary_file))
    html = HTMLSummaryfile()
    html.openfile(summary_file)
    html.beginHtml()
    html.beginBody(with_tab)

    ''' generate first page: general information + license text '''
    generate_introduction_sheet(html)
    ''' generate image content '''
    generate_image_content_sheet(html)
    ''' generate license spdx reference '''
    generate_spdx_license_sheet(html)

    html.endBody(with_tab)
    html.endHtml()
    html.closefile()

SDK_POSTPROCESS_COMMAND_append = "do_write_sdk_license_create_summary;"
