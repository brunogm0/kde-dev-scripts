cmake_minimum_required(VERSION 2.8.12)
project(kde-dev-scripts)

find_package(ECM 1.3.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR})

include(FeatureSummary)
include(KDEInstallDirs)

find_package(KF5 COMPONENTS DocTools)

# Note that all of these files should be *scripts* that do not require
# compilation, therefore we simply install them. We split out Bourne shell
# programs explicitly but it's not guaranteed that the Perl/Python/Ruby/etc.
# ones behave well on Mac or Windows just because we don't elide those too.

########### install files ###############
if(UNIX)
#shell program

if(KF5DocTools_FOUND)
  add_subdirectory(doc)
endif()

install(PROGRAMS
  adddebug
  build-progress.sh
  cheatmake
  c++-rename-class-and-file
  c++-copy-class-and-file
  create_cvsignore
  create_makefiles
  create_svnignore
  cvsaddcurrentdir
  cvsbackport
  cvsforwardport
  cvslastlog
  cvsrevertlast
  cvsversion
  findmissingcrystal
  fix-include.sh
  kdedoc
  krazy-licensecheck
  optimizegraphics
  nonsvnlist
  pruneemptydirs
  qtdoc
  svnbackport
  svnforwardport
  svnchangesince
  svngettags
  svnlastlog
  svnrevertlast
  uncrustify-kf5
  wcgrep
  draw_lib_dependencies
  DESTINATION ${KDE_INSTALL_BINDIR})

install(FILES
  uncrustify-kf5.cfg
  uncrustify-qt.cfg
  DESTINATION ${KDE_INSTALL_DATADIR}/uncrustify)

endif()

install(PROGRAMS
  create_makefile
  makeobj
  cvscheck
  cvslastchange
  noncvslist
  cvs-clean
  cvsblame
  colorsvn
  svn-clean
  svnlastchange
  svnversions
  extractrc
  extractattr
  zonetab2pot.py
  fixkdeincludes
  fixuifiles
  includemocs
  cxxmetric
  extend_dmalloc
  kdekillall
  kdelnk2desktop.py
  package_crystalsvg
  png2mng.pl
  kdemangen.pl
  svnintegrate
  kde_generate_export_header
  kde-systemsettings-tree.py
  reviewboard-am
  grantlee_strings_extractor.py
  DESTINATION ${KDE_INSTALL_BINDIR})

# SKIP_PO_INSTALL

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
