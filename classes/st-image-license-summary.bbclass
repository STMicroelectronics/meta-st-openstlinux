inherit license_image

# To have tab on html file generated
LICENSE_IMAGE_CONTENT_WITH_TAB ?= "1"

# Configure on BSP side this var if you expect the summary to be generated
ENABLE_IMAGE_LICENSE_SUMMARY ??= "0"

# We can define one or more additional images built as additional partitions
# to the default rootfs one (${IMAGE_BASENAME}:/) thought IMAGE_SUMMARY_LIST var
# with format
#   IMAGE_SUMMARY_LIST = "<image_name_1>:<image_mountpoint_1>:<image_suffix_1>;${IMAGE_BASENAME}:/;<image_name_2>:<image_mountpoint_2:<image_suffix_1>"
IMAGE_SUMMARY_LIST ?= "${IMAGE_BASENAME}:/:rootfs"

LICENSE_SUMMARY_DEPLOYDIR ?= "${DEPLOY_DIR}/images/${MACHINE}"
LICENSE_SUMMARY_DIR ?= "${WORKDIR}/license-summary/"
LICENSE_SUMMARY_NAME ?= "${IMAGE_NAME}-license_content.html"
LICENSE_SUMMARY_LINK_NAME ?= "${IMAGE_LINK_NAME}-license_content.html"

def license_create_summary(d):
    import re
    tab =  d.expand("${LICENSE_IMAGE_CONTENT_WITH_TAB}")
    ref_image_name =  d.expand("${IMAGE_LINK_NAME}")
    deploy_image_dir = d.expand("${DEPLOY_DIR_IMAGE}")
    temp_deploy_image_dir = d.expand("${IMGDEPLOYDIR}")
    license_deploy_dir = d.expand("${DEPLOY_DIR}/licenses")
    pkgdata_dir = d.expand("${TMPDIR}/pkgdata/${MACHINE}")
    machine = d.expand("${MACHINE}")
    machine_underscore = machine.replace("-", "_")

    license_summary_deploydir = d.getVar('LICENSE_SUMMARY_DIR')
    license_summary_name = d.getVar('LICENSE_SUMMARY_NAME')
    license_summary_link = d.getVar('LICENSE_SUMMARY_LINK_NAME')

    image_list_arrray = []
    # Process IMAGE_SUMMARY_LIST to feed image_list_arrray
    image_summary_list = (d.getVar('IMAGE_SUMMARY_LIST') or "").split(';')
    mount_list = []
    for img in image_summary_list:
        if img.strip() == "":
            continue
        img_name = img.split(':')[0].strip()
        img_mount = img.split(':')[1].strip()
        img_suffix = img.split(':')[2].strip()
        # Remove DISTRO from image name to avoid long name
        img_name = re.sub(r'-%s$' % d.getVar('DISTRO'), '', img_name)
        # Configure target folder to search for image file
        if img_mount == '/':
            filter = True
            target_deploydir = temp_deploy_image_dir
        else:
            filter = False
            target_deploydir = deploy_image_dir
            mount_list.append(img_mount)
        for fi in os.listdir(target_deploydir):
            if fi.startswith(img_name) and fi.endswith(".ext4"):
                r = re.compile(r"(.*)-(\d\d\d\d+)")
                mi = r.match(os.path.basename(fi))
                if mi:
                    image_list_arrray.append([mi.group(1), mi.group(2), img_name, img_mount, img_suffix, filter])
    # Append any INITRD image to image_list_arrray
    initrd_img = d.getVar('INITRD_IMAGE_ALL') or d.getVar('INITRD_IMAGE') or ""
    for img_name in initrd_img.split():
        img_ext = d.getVar('INITRAMFS_FSTYPES') or ""
        img_mount = '/'
        img_suffix = 'rootfs'
        filter = False
        for fi in os.listdir(deploy_image_dir):
            if fi.startswith(img_name) and fi.endswith(img_ext):
                r = re.compile(r"(.*)-(\d\d\d\d+)")
                mi = r.match(os.path.basename(fi))
                if mi:
                    image_list_arrray.append([mi.group(1), mi.group(2), img_name, img_mount, img_suffix, filter])

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
                bb.warn("IMG LIC SUM: Cannot open file %s" % (filename))
                result = ""
            except:
                bb.warn("IMG LIC SUM: Error with file %s" % (filename))
                result = ""
        else:
            bb.warn("IMG LIC SUM: File does not exist with open file %s" % (filename))

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

        blue = "background-color: #0000ff;"
        green = "background-color: #00ff00;"

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
                self.opened_file.write('   <button class="tablink" onclick="openTab(\'image_content\', this)">Contents of Images</button>\n')
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

        SRC_DISTRIBUTE_LICENSES += "0BSD "
        SRC_DISTRIBUTE_LICENSES += "AAL Abstyles Adobe Adobe-2006 Adobe-Glyph ADSL "
        SRC_DISTRIBUTE_LICENSES += "AFL-1.1 AFL-1.2 AFL-2.0 AFL-2.1 AFL-3.0 "
        SRC_DISTRIBUTE_LICENSES += "Afmparse AGPL-1.0-only AGPL-1.0-or-later AGPL-3.0-only "
        SRC_DISTRIBUTE_LICENSES += "AGPL-3.0-or-later Aladdin AMDPLPA AML AMPAS ANTLR-PD "
        SRC_DISTRIBUTE_LICENSES += "ANTLR-PD-fallback Apache-1.0 Apache-1.1 Apache-2.0 "
        SRC_DISTRIBUTE_LICENSES += "Apache-2.0-with-LLVM-exception APAFML APL-1.0 APSL-1.0 "
        SRC_DISTRIBUTE_LICENSES += "APSL-1.1 APSL-1.2 APSL-2.0 "
        SRC_DISTRIBUTE_LICENSES += "Artistic-1.0 Artistic-1.0-cl8 Artistic-1.0-Perl Artistic-2.0 "
        SRC_DISTRIBUTE_LICENSES += "Bahyph Barr Beerware BitstreamVera BitTorrent-1.0 BitTorrent-1.1 "
        SRC_DISTRIBUTE_LICENSES += "blessing BlueOak-1.0.0 Borceux BSD-1-Clause BSD-2-Clause "
        SRC_DISTRIBUTE_LICENSES += "BSD-2-Clause-Patent BSD-2-Clause-Views BSD-3-Clause "
        SRC_DISTRIBUTE_LICENSES += "BSD-3-Clause-Attribution BSD-3-Clause-Clear BSD-3-Clause-LBNL "
        SRC_DISTRIBUTE_LICENSES += "BSD-3-Clause-Modification BSD-3-Clause-No-Military-License "
        SRC_DISTRIBUTE_LICENSES += "BSD-3-Clause-No-Nuclear-License BSD-3-Clause-No-Nuclear-License-2014 "
        SRC_DISTRIBUTE_LICENSES += "BSD-3-Clause-No-Nuclear-Warranty BSD-3-Clause-Open-MPI "
        SRC_DISTRIBUTE_LICENSES += "BSD-4-Clause BSD-4-Clause-Shortened BSD-4-Clause-UC "
        SRC_DISTRIBUTE_LICENSES += "BSD-Protection BSD-Source-Code "
        SRC_DISTRIBUTE_LICENSES += "BSL-1.0 BUSL-1.1 bzip2-1.0.4 bzip2-1.0.5 bzip2-1.0.6 "
        SRC_DISTRIBUTE_LICENSES += "CAL-1.0 CAL-1.0-Combined-Work-Exception Caldera CATOSL-1.1 "
        SRC_DISTRIBUTE_LICENSES += "CC0-1.0 CC-BY-1.0 CC-BY-2.0 CC-BY-2.5 CC-BY-2.5-AU CC-BY-3.0 "
        SRC_DISTRIBUTE_LICENSES += "CC-BY-3.0-AT CC-BY-3.0-DE CC-BY-3.0-NL CC-BY-3.0-US CC-BY-4.0 "
        SRC_DISTRIBUTE_LICENSES += "CC-BY-NC-1.0 CC-BY-NC-2.0 CC-BY-NC-2.5 CC-BY-NC-3.0 "
        SRC_DISTRIBUTE_LICENSES += "CC-BY-NC-3.0-DE CC-BY-NC-4.0 CC-BY-NC-ND-1.0 CC-BY-NC-ND-2.0 "
        SRC_DISTRIBUTE_LICENSES += "CC-BY-NC-ND-2.5 CC-BY-NC-ND-3.0 CC-BY-NC-ND-3.0-DE "
        SRC_DISTRIBUTE_LICENSES += "CC-BY-NC-ND-3.0-IGO CC-BY-NC-ND-4.0 CC-BY-NC-SA-1.0 "
        SRC_DISTRIBUTE_LICENSES += "CC-BY-NC-SA-2.0 CC-BY-NC-SA-2.0-FR CC-BY-NC-SA-2.0-UK "
        SRC_DISTRIBUTE_LICENSES += "CC-BY-NC-SA-2.5 CC-BY-NC-SA-3.0 CC-BY-NC-SA-3.0-DE "
        SRC_DISTRIBUTE_LICENSES += "CC-BY-NC-SA-3.0-IGO CC-BY-NC-SA-4.0 CC-BY-ND-1.0 "
        SRC_DISTRIBUTE_LICENSES += "CC-BY-ND-2.0 CC-BY-ND-2.5 CC-BY-ND-3.0 CC-BY-ND-3.0-DE "
        SRC_DISTRIBUTE_LICENSES += "CC-BY-ND-4.0 CC-BY-SA-1.0 CC-BY-SA-2.0 CC-BY-SA-2.0-UK "
        SRC_DISTRIBUTE_LICENSES += "CC-BY-SA-2.1-JP CC-BY-SA-2.5 CC-BY-SA-3.0 CC-BY-SA-3.0-AT "
        SRC_DISTRIBUTE_LICENSES += "CC-BY-SA-3.0-DE CC-BY-SA-4.0 CC-PDDC CDDL-1.0 CDDL-1.1 "
        SRC_DISTRIBUTE_LICENSES += "CDL-1.0 CDLA-Permissive-1.0 CDLA-Permissive-2.0 CDLA-Sharing-1.0 "
        SRC_DISTRIBUTE_LICENSES += "CECILL-1.0 CECILL-1.1 CECILL-2.0 CECILL-2.1 CECILL-B CECILL-C "
        SRC_DISTRIBUTE_LICENSES += "CERN-OHL-1.1 CERN-OHL-1.2 CERN-OHL-P-2.0 CERN-OHL-S-2.0 CERN-OHL-W-2.0 "
        SRC_DISTRIBUTE_LICENSES += "ClArtistic CNRI-Jython CNRI-Python CNRI-Python-GPL-Compatible "
        SRC_DISTRIBUTE_LICENSES += "Condor-1.1 copyleft-next-0.3.0 copyleft-next-0.3.1 CPAL-1.0 "
        SRC_DISTRIBUTE_LICENSES += "CPL-1.0 CPOL-1.02 Crossword CrystalStacker CUA-OPL-1.0 Cube "
        SRC_DISTRIBUTE_LICENSES += "C-UDA-1.0 curl D-FSL-1.0 diffmark DOC Dotseqn DRL-1.0 DSDP "
        SRC_DISTRIBUTE_LICENSES += "DSSSL dvipdfm ECL-1.0 ECL-2.0 eCos-2.0 EDL-1.0 EFL-1.0 "
        SRC_DISTRIBUTE_LICENSES += "EFL-2.0 eGenix Entessa EPICS EPL-1.0 EPL-2.0 ErlPL-1.1 etalab-2.0 "
        SRC_DISTRIBUTE_LICENSES += "EUDatagrid EUPL-1.0 EUPL-1.1 EUPL-1.2 urosym Fair Frameworx-1.0 "
        SRC_DISTRIBUTE_LICENSES += "FreeBSD-DOC FreeImage FSFAP FSFUL FSFULLR FSF-Unlimited "
        SRC_DISTRIBUTE_LICENSES += "FTL GD GFDL-1.1 GFDL-1.1-invariants-only GFDL-1.1-invariants-or-later "
        SRC_DISTRIBUTE_LICENSES += "GFDL-1.1-no-invariants-only GFDL-1.1-no-invariants-or-later "
        SRC_DISTRIBUTE_LICENSES += "GFDL-1.1-only GFDL-1.1-or-later GFDL-1.2 GFDL-1.2-invariants-only "
        SRC_DISTRIBUTE_LICENSES += "GFDL-1.2-invariants-or-later GFDL-1.2-no-invariants-only "
        SRC_DISTRIBUTE_LICENSES += "GFDL-1.2-no-invariants-or-later GFDL-1.2-only GFDL-1.2-or-later "
        SRC_DISTRIBUTE_LICENSES += "GFDL-1.3 GFDL-1.3-invariants-only GFDL-1.3-invariants-or-later "
        SRC_DISTRIBUTE_LICENSES += "GFDL-1.3-no-invariants-only GFDL-1.3-no-invariants-or-later "
        SRC_DISTRIBUTE_LICENSES += "GFDL-1.3-only GFDL-1.3-or-later Giftware GL2PS Glide Glulxe "
        SRC_DISTRIBUTE_LICENSES += "GLWTPL gnuplot GPL-1.0-only GPL-1.0-or-later GPL-2.0-only "
        SRC_DISTRIBUTE_LICENSES += "GPL-2.0-or-later GPL-2.0-with-autoconf-exception "
        SRC_DISTRIBUTE_LICENSES += "GPL-2.0-with-classpath-exception GPL-2.0-with-font-exception "
        SRC_DISTRIBUTE_LICENSES += "GPL-2.0-with-GCC-exception GPL-2.0-with-OpenSSL-exception "
        SRC_DISTRIBUTE_LICENSES += "GPL-2-with-bison-exception GPL-3.0-only GPL-3.0-or-later  "
        SRC_DISTRIBUTE_LICENSES += "GPL-3.0-with-autoconf-exception GPL-3.0-with-GCC-exception "
        SRC_DISTRIBUTE_LICENSES += "GPL-3-with-bison-exception gSOAP-1 gSOAP-1.3b HaskellReport "
        SRC_DISTRIBUTE_LICENSES += "Hippocratic-2.1 HPND HPND-sell-variant HTMLTIDY IBM-pibs "
        SRC_DISTRIBUTE_LICENSES += "ICU IJG ImageMagick iMatix Imlib2 Info-ZIP Intel Intel-ACPI "
        SRC_DISTRIBUTE_LICENSES += "Interbase-1.0 IPA IPL-1.0 ISC JasPer-2.0 JPNIC JSON "
        SRC_DISTRIBUTE_LICENSES += "LAL-1.2 LAL-1.3 Latex2e Leptonica LGPL-2.0-only "
        SRC_DISTRIBUTE_LICENSES += "LGPL-2.0-or-later LGPL-2.1-only LGPL-2.1-or-later LGPL-3.0-only "
        SRC_DISTRIBUTE_LICENSES += "LGPL-3.0-or-later LGPLLR Libpng libpng-2.0 libselinux-1.0 libtiff "
        SRC_DISTRIBUTE_LICENSES += "LiLiQ-P-1.1 LiLiQ-R-1.1 LiLiQ-Rplus-1.1 Linux-OpenIB "
        SRC_DISTRIBUTE_LICENSES += "LPL-1.0 LPL-1.02 LPPL-1.0 LPPL-1.1 LPPL-1.2 LPPL-1.3a LPPL-1.3c "
        SRC_DISTRIBUTE_LICENSES += "MakeIndex MirOS MIT MIT-0 MIT-advertising MIT-CMU MIT-enna "
        SRC_DISTRIBUTE_LICENSES += "MIT-feh MIT-Modern-Variant MITNFA MIT-open-group Motosoto "
        SRC_DISTRIBUTE_LICENSES += "mpich2 MPL-1.0 MPL-1.1 MPL-2.0 MPL-2.0-no-copyleft-exception "
        SRC_DISTRIBUTE_LICENSES += "MS-PL MS-RL MTLL MulanPSL-1.0 MulanPSL-2.0 Multics Mup "
        SRC_DISTRIBUTE_LICENSES += "NAIST-2003 NASA-1.3 Naumen NBPL-1.0 NCGL-UK-2.0 NCSA NetCDF "
        SRC_DISTRIBUTE_LICENSES += "Net-SNMP Newsletr NGPL NIST-PD NIST-PD-fallback NLOD-1.0 "
        SRC_DISTRIBUTE_LICENSES += "NLOD-2.0 NLPL Nokia NOSL Noweb NPL-1.0 NPL-1.1 NPOSL-3.0 "
        SRC_DISTRIBUTE_LICENSES += "NRL NTP NTP-0 OASIS OCCT-PL OCLC-2.0 ODbL-1.0 ODC-By-1.0 "
        SRC_DISTRIBUTE_LICENSES += "OFL-1.0 OFL-1.0-no-RFN OFL-1.0-RFN OFL-1.1 OFL-1.1-no-RFN "
        SRC_DISTRIBUTE_LICENSES += "OFL-1.1-RFN OGC-1.0 OGDL-Taiwan-1.0 OGL-Canada-2.0 OGL-UK-1.0 "
        SRC_DISTRIBUTE_LICENSES += "OGL-UK-2.0 OGL-UK-3.0 OGTSL OLDAP-1.1 OLDAP-1.2 OLDAP-1.3 "
        SRC_DISTRIBUTE_LICENSES += "OLDAP-1.4 OLDAP-2.0 OLDAP-2.0.1 OLDAP-2.1 OLDAP-2.2 OLDAP-2.2.1 "
        SRC_DISTRIBUTE_LICENSES += "OLDAP-2.2.2 OLDAP-2.3 OLDAP-2.4 OLDAP-2.5 OLDAP-2.6 OLDAP-2.7 "
        SRC_DISTRIBUTE_LICENSES += "OLDAP-2.8 OML OpenSSL OPL-1.0 OPUBL-1.0 OSET-PL-2.1 OSL-1.0 "
        SRC_DISTRIBUTE_LICENSES += "OSL-1.1 OSL-2.0 OSL-2.1 OSL-3.0 O-UDA-1.0 ParaTypeFFL-1.3 "
        SRC_DISTRIBUTE_LICENSES += "Parity-6.0.0 Parity-7.0.0 PD PDDL-1.0 PHP-3.0 PHP-3.01 pkgconf "
        SRC_DISTRIBUTE_LICENSES += "Plexus PolyForm-Noncommercial-1.0.0 PolyForm-Small-Business-1.0.0 "
        SRC_DISTRIBUTE_LICENSES += "PostgreSQL Proprietary PSF-2.0 psfrag psutils Python-2.0 "
        SRC_DISTRIBUTE_LICENSES += "Qhull QPL-1.0 Rdisc RHeCos-1 RHeCos-1.1 RPL-1.1 RPL-1.5 "
        SRC_DISTRIBUTE_LICENSES += "RPSL-1.0 RSA-MD RSCPL Ruby Saxpath SAX-PD SCEA Sendmail "
        SRC_DISTRIBUTE_LICENSES += "Sendmail-8.23 SGI-1 SGI-B-1.0 SGI-B-1.1 SGI-B-2.0 SHL-0.5 "
        SRC_DISTRIBUTE_LICENSES += "SHL-0.51 SimPL-2.0 Simple-2.0 SISSL SISSL-1.2 Sleepycat "
        SRC_DISTRIBUTE_LICENSES += "SMAIL_GPL SMLNJ SMPPL SNIA Spencer-86 Spencer-94 Spencer-99 "
        SRC_DISTRIBUTE_LICENSES += "SPL-1.0 SSH-OpenSSH SSH-short SSPL-1.0 SugarCRM-1 SugarCRM-1.1.3 "
        SRC_DISTRIBUTE_LICENSES += "SWL TAPR-OHL-1.0 TCL TCP-wrappers TMate TORQUE-1.1 TOSL "
        SRC_DISTRIBUTE_LICENSES += "TU-Berlin-1.0 TU-Berlin-2.0 UCB UCL-1.0 unfs3 Unicode-DFS-2015 "
        SRC_DISTRIBUTE_LICENSES += "Unicode-DFS-2016 Unicode-TOU Unlicense UPL-1.0  Vim VOSTROM "
        SRC_DISTRIBUTE_LICENSES += "VSL-1.0 W3C W3C-19980720 W3C-20150513 Watcom-1.0 Wsuipa "
        SRC_DISTRIBUTE_LICENSES += "WTFPL WXwindows X11 Xerox XFree86-1.0 Free86-1.1 xinetd "
        SRC_DISTRIBUTE_LICENSES += "Xnet xpp XSkat XSL YPL-1.0 YPL-1.1 Zed Zend-2.0 Zimbra-1.3 "
        SRC_DISTRIBUTE_LICENSES += "Zimbra-1.4 Zlib zlib-acknowledgement ZPL-1.1 ZPL-2.0 ZPL-2.1 "

        OTHER_LICENSES_NAME = "SLA0044"

        OTHER_LICENSES_URL = "https://www.st.com/SLA0044"

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

        for lic, url in zip(OTHER_LICENSES_NAME.split(' '), OTHER_LICENSES_URL.split(' ')):
            html.startRow()
            html.addColumnContent(lic)
            html.addColumnURLOUTContent('['+lic+']', url )
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
        # Make sure to remove any DISTRO append to IMAGE_BASENAME for short display
        general_IMAGE = re.sub(r'-%s$' % d.getVar('DISTRO'), '', d.getVar("IMAGE_BASENAME"))
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
        html.addColumnContent("IMAGE", html.bold)
        html.addColumnContent(general_IMAGE)
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

        license_file_to_read = os.path.join(deploy_image_dir, "%s.license" % ref_image_name)
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
        html.startDiv("image_content", "Image content")
        html.addAnchor("image_content")

        # partition schema
        html.addContent("Schema of partitions:")
        html.startTable()
        html.startRow()
        html.startColumn("width: 10%; text-align: center;")
        html.addURLContent("Boot binaries", "#boot_binaries")
        for img in image_list_arrray:
            _image_prefix = img[0]
            _image_date = img[1]
            _image_name = img[2]
            _image_mount_point = img[3]

            if _image_mount_point == '/':
                html.startColumn("width: 30%; text-align: center;")
            else:
                html.startColumn("width: 20%; text-align: center;")
            html.addURLContent(_image_name, "#%s" % _image_name)
        html.stopColumn()
        html.stopRow()
        html.stopTable()

        html.addNewLine()
        html.addNewLine()

        boot_file_to_read = None
        # boot binaries
        for img in image_list_arrray:
            _image_prefix = img[0]
            _image_date = img[1]
            _image_suffix = img[4]

            if _image_prefix == ref_image_name:
                _image_package = "image_license.manifest"
                boot_file_to_read = license_deploy_dir + "/" + machine_underscore + "/" + _image_prefix +  "-" + _image_date + "/" + _image_package

        if boot_file_to_read:
            contents = private_open(boot_file_to_read)
        else:
            contents = ""

        html.addContent("List of packages used during the different boot phases:")
        html.addAnchor("boot_binaries")
        html.startTable()
        html.startRow()
        html.addColumnHeaderContent("Recipe Name", html.bold)
        html.addColumnHeaderContent("Version", html.bold)
        html.addColumnHeaderContent("License", html.bold)
        html.stopRow()

        r = re.compile(r"(^.+?):\s+(.*)")
        new_boot = 0
        boot_recipe = None
        boot_license = None
        boot_version = None
        for l in contents:
            m = r.match(l)
            if m:
                if m.group(1) == "RECIPE NAME":
                    boot_recipe =  m.group(2)
                elif m.group(1) == "LICENSE":
                    boot_license = m.group(2)
                elif m.group(1) == "VERSION":
                    boot_version = m.group(2)
                elif m.group(1) == "FILES":
                    new_boot = 1
                if new_boot == 1:
                    boot_license = boot_license.replace('&', 'AND')
                    boot_license = boot_license.replace('|', 'OR')
                    if findWholeWord("GPLv3")(boot_license):
                        html.startRow(red)
                        # Recipe Name
                        html.addColumnContent(boot_recipe, red)
                        # Version
                        html.addColumnContent(boot_version, red)
                        # License
                        html.addColumnContent(boot_license, red)
                        html.stopRow()
                    else:
                        html.startRow()
                        # Recipe Name
                        html.addColumnContent(boot_recipe)
                        # Version
                        html.addColumnContent(boot_version)
                        # License
                        html.addColumnContent(boot_license)
                        html.stopRow()
                    boot_recipe = ""
                    boot_license = ""
                    boot_version = ""
                    new_boot = 0
        html.stopTable()

        # image content list
        package_processed_list = []
        for img in image_list_arrray:
            _image_prefix = img[0]
            _image_date = img[1]
            _image_name = img[2]
            _image_mount_point = img[3]
            _image_suffix = img[4]
            _image_filter = img[5]

            html.addNewLine()
            html.addNewLine()

            html.addContent("List of packages present on image")
            html.addAnchor(_image_name)
            html.startTable()
            html.startRow()
            html.addColumnHeaderContent("Image", html.bold)
            html.addColumnHeaderContent(_image_prefix)
            html.stopRow()
            html.stopTable()

            _image_package="package.manifest"
            file_to_read = license_deploy_dir + "/" + machine_underscore + "/" + _image_prefix + "-" + _image_date + "/" + _image_package
            contents = private_open(file_to_read)
            #print("Process for %s" % _image_prefix)

            html.startTable()
            html.startRow()
            html.addColumnHeaderContent("Recipe Name", html.bold)
            html.addColumnHeaderContent("Package Name", html.bold)
            html.addColumnHeaderContent("Version", html.bold)
            html.addColumnHeaderContent("License", html.bold)
            html.addColumnHeaderContent("Description", html.bold)
            html.stopRow()
            for p in contents:
                package_license = None
                package_recipe = None
                package_name = p.split('\n')[0]
                package_version = None
                package_description = None
                package_summary = None
                package_file = pkgdata_dir + "/runtime-reverse/" + package_name
                package_file_content = private_open(package_file)
                file_info = None
                r = re.compile(r"(^.+?):\s+(.*)")
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
                        elif m.group(1).startswith("FILES_INFO"):
                            file_info = m.group(2)
                if package_license and findWholeWord("GPLv3")(package_license):
                    style = html.red
                    style_wrapped = html.wrap_red_format
                else:
                    style = None
                    style_wrapped = None

                # Filter partition in case of a package is already in another partition
                if _image_filter:
                    to_filter = False
                    for other_mount in mount_list:
                        if file_info.find(other_mount+'/') >= 0:
                            to_filter = True
                            break

                    if to_filter:
                        bb.note("Package %s is found in both %s and %s. Don't add it in %s" %
                             (package_name, other_mount,_image_mount_point, _image_name))
                        continue

                # remove package which are dependency of installed package but
                # not present on this mount point
                if file_info.find(_image_mount_point) < 0:
                    continue;
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
                    package_license = package_license.replace("&", "AND")
                    package_license = package_license.replace("|", "OR")
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
                # display file installed
                #if file_info:
                #    b = re.compile("{(.*)}")
                #    b_info = b.match(file_info)
                #    data_file = ""
                #    for t in b_info.group(1).split(','):
                #        if t.find(_image_mount_point) > -1:
                #            data_file += t.split(':')[0].replace('\"', '') + " <br/>"
                #    html.addColumnContent(data_file, style)
                #else:
                #   html.addColumnContent("", style)

                html.stopRow()
                package_license = None
                package_parent = None
                package_name = None
                package_version = None
                package_description = None
                package_summary = None

            html.stopTable()

        html.stopDiv()

    # Create license summary file
    license_summary_name_path = os.path.join(license_summary_deploydir, license_summary_name)
    html = HTMLSummaryfile()
    html.openfile(license_summary_name_path)
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

    # Create link
    license_summary_link_path = os.path.join(license_summary_deploydir, license_summary_link)
    if os.path.exists(license_summary_name_path):
        bb.note("Creating symlink: %s -> %s" % (license_summary_link_path, license_summary_name))
        if os.path.islink(license_summary_link_path):
            os.remove(license_summary_link_path)
        os.symlink(license_summary_name, license_summary_link_path)
    else:
        bb.note("Skipping symlink, source does not exist: %s -> %s" % (license_summary_link_path, license_summary_name))


python do_st_write_license_create_summary() {
    if d.getVar('ENABLE_IMAGE_LICENSE_SUMMARY') == "1":
        license_create_summary(d)
    else:
        return
}
addtask st_write_license_create_summary before do_build after do_image_complete
do_st_write_license_create_summary[recrdeptask] += "do_populate_lic_deploy"
do_st_write_license_create_summary[dirs] = "${LICENSE_SUMMARY_DIR} ${IMGDEPLOYDIR}"

SSTATETASKS += "do_st_write_license_create_summary"
do_st_write_license_create_summary[cleandirs] = "${LICENSE_SUMMARY_DIR}"
do_st_write_license_create_summary[sstate-inputdirs] = "${LICENSE_SUMMARY_DIR}"
do_st_write_license_create_summary[sstate-outputdirs] = "${LICENSE_SUMMARY_DEPLOYDIR}/"

python do_st_write_license_create_summary_setscene () {
    sstate_setscene(d)
}
addtask do_st_write_license_create_summary_setscene
