#!/usr/bin/env python

import openmeeg as om
import os
from os import path as op
from optparse import OptionParser
import numpy as np

data_path = op.dirname(op.abspath(__file__))
parser = OptionParser()
parser.add_option("-p", "--path", dest="data_path",
                  help="path to data folder", metavar="FILE",
                  default=data_path)
options, args = parser.parse_args()
data_path = options.data_path

###############################################################################
# Load data
###############################################################################

subject = 'Head1'
cond_file = op.join(data_path, subject, subject + '.cond')
geom_file = op.join(data_path, subject, subject + '.geom')
source_mesh_file = op.join(data_path, subject, subject + '.tri')
dipole_file = op.join(data_path, subject, subject + '.dip')
squidsFile = op.join(data_path, subject,
                        subject + '.squids')
patches_file = op.join(data_path, subject,
                        subject + '.patches')

geom = om.Geometry()
geom.read(geom_file, cond_file)

mesh = om.Mesh()
mesh.load(source_mesh_file)

dipoles = om.Matrix()
dipoles.load(dipole_file)

sensors = om.Sensors()
sensors.load(squidsFile)

patches = om.Sensors()
patches.load(patches_file)

###############################################################################
# Compute forward problem (Build Gain Matrices)
###############################################################################

gauss_order = 3
use_adaptive_integration = True
dipole_in_cortex = True

hm = om.HeadMat(geom, gauss_order)
#hm.invert() # invert hm inplace (no copy)
#hminv = hm
hminv = hm.inverse()  # invert hm with a copy
ssm = om.SurfSourceMat(geom, mesh)
ss2mm = om.SurfSource2MEGMat(mesh, sensors)
dsm = om.DipSourceMat(geom, dipoles, gauss_order, use_adaptive_integration, "")
ds2mm = om.DipSource2MEGMat(dipoles, sensors)
h2mm = om.Head2MEGMat(geom, sensors)
h2em = om.Head2EEGMat(geom, patches)
gain_meg_surf = om.GainMEG(hminv, ssm, h2mm, ss2mm)
gain_eeg_surf = om.GainEEG(hminv, ssm, h2em)
gain_meg_dip = om.GainMEG(hminv, dsm, h2mm, ds2mm)
gain_adjoint_meg_dip = om.GainMEGadjoint(geom, dipoles, hm, h2mm, ds2mm)
gain_eeg_dip = om.GainEEG(hminv, dsm, h2em)
gain_adjoint_eeg_dip = om.GainEEGadjoint(geom, dipoles, hm, h2em)
gain_adjoint_eeg_meg_dip = om.GainEEGMEGadjoint(geom, dipoles,
                                                hm, h2em, h2mm, ds2mm)

print "hm                  : %d x %d" % (hm.nlin(), hm.ncol())
print "hminv               : %d x %d" % (hminv.nlin(), hminv.ncol())
print "ssm                 : %d x %d" % (ssm.nlin(), ssm.ncol())
print "ss2mm               : %d x %d" % (ss2mm.nlin(), ss2mm.ncol())
print "dsm                 : %d x %d" % (ssm.nlin(), ssm.ncol())
print "ds2mm               : %d x %d" % (ss2mm.nlin(), ss2mm.ncol())
print "h2mm                : %d x %d" % (h2mm.nlin(), h2mm.ncol())
print "h2em                : %d x %d" % (h2mm.nlin(), h2mm.ncol())
print "gain_meg_surf       : %d x %d" % (gain_meg_surf.nlin(),
                                         gain_meg_surf.ncol())
print "gain_eeg_surf       : %d x %d" % (gain_eeg_surf.nlin(),
                                         gain_eeg_surf.ncol())
print "gain_meg_dip        : %d x %d" % (gain_meg_dip.nlin(),
                                         gain_meg_dip.ncol())
print "gain_adjoint_meg_dip: %d x %d" % (gain_adjoint_meg_dip.nlin(),
                                         gain_adjoint_meg_dip.ncol())
print "gain_eeg_dip        : %d x %d" % (gain_eeg_dip.nlin(),
                                         gain_eeg_dip.ncol())
print "gain_adjoint_eeg_dip: %d x %d" % (gain_adjoint_eeg_dip.nlin(),
                                         gain_adjoint_eeg_dip.ncol())

# Leadfield MEG in one line :

gain_meg_surf_one_line = om.GainMEG(om.HeadMat(geom, gauss_order).inverse(),
                                    om.SurfSourceMat(geom, mesh, gauss_order),
                                    om.Head2MEGMat(geom, sensors),
                                    om.SurfSource2MEGMat(mesh, sensors))

print "gain_meg_surf_one_line : %d x %d" % (gain_meg_surf_one_line.nlin(),
                                            gain_meg_surf_one_line.ncol())

###############################################################################
# Compute forward data =
###############################################################################

srcFile = op.join(data_path, subject, subject + '.srcdip')
sources = om.Matrix(srcFile)

noise_level = 0.0
est_meg = om.Forward(gain_meg_dip, sources, noise_level)
print "est_meg    : %d x %d" % (est_meg.nlin(), est_meg.ncol())

est_meg_adjoint = om.Forward(gain_adjoint_meg_dip, sources, noise_level)
print "est_meg_adjoint    : %d x %d" % (est_meg_adjoint.nlin(),
                                       est_meg_adjoint.ncol())

est_eeg = om.Forward(gain_eeg_dip, sources, noise_level)
print "est_eeg    : %d x %d" % (est_eeg.nlin(), est_eeg.ncol())

est_eeg_adjoint = om.Forward(gain_adjoint_eeg_dip, sources, noise_level)
print "est_eeg_adjoint    : %d x %d" % (est_eeg_adjoint.nlin(),
                                       est_eeg_adjoint.ncol())

###############################################################################
# Example of basic manipulations
###############################################################################

v1 = om.Vertex(1., 0., 0., 0)
v2 = om.Vertex(0., 1., 0., 1)
v3 = om.Vertex(0., 0., 1., 2)

#print v1.norm()
#print (v1 + v2).norm()

normal = om.Vect3(1., 0., 0.)
t = om.Triangle(v1, v2, v3)

hm_file = subject + '.hm'
hm.save(hm_file)

ssm_file = subject + '.ssm'
ssm.save(ssm_file)

m1 = om.SymMatrix()
m1.load(hm_file)
#print m1(0, 0)
#print m1.nlin()
#print m1.ncol()

m2 = om.Matrix()
m2.load(ssm_file)
#m2.setvalue(2,3,-0.2) # m2(2,3)=-0.2
#print m2(2,3)
#print m2(0, 0)
#print m2.nlin()
#print m2.ncol()

###############################################################################
# Numpy interface
###############################################################################

# For a Vector
v=hm(1,10,1,1).getcol(0)
vec = om.asarray(v)
m = om.fromarray(vec)
assert((v-m.getcol(0)).norm() < 1e-15)

# For a Matrix
mat = om.asarray(m2)
assert((m2-om.fromarray(mat)).frobenius_norm() < 1e-15)
#print mat.shape
#print mat.sum()
#mat[0:2, 1:3] = 0
#print mat[0:5, 0:5]

###############################################################################
# test correct increase/decrease ref counter (temporary objects)
###############################################################################
print("test ref count/ incr./decr.")

m=om.Matrix(10,1)
m.set(6.)
m.info()
M=om.asarray(m)
M1=om.asarray(m.getcol(0))







# Consider the following code:

v=hm(1,10,1,1).getcol(0)
vec = om.asarray(v)
print(vec)

# This works correctly. But the "equivalent" code:

m = hm(1,10,1,1)
print(om.asarray(m.getcol(0)))

# assert(np.linalg.norm(vec-om.asarray(m.getcol(0))) < 1e-15) #ERROR









###### en affichant les constructor destructor:
# sur ipython
#%reset

print('    ## 1 etrange ')
m=om.Matrix(10,1)
#constructor called 0x55f199c0afc0
m=3
#desturctor called 0x55f199c0afc0
# OK ! c'est bien.
# en revanche :
m=om.Matrix(10,1)
#constructor called 0x55f199c0e4a0
m
#<openmeeg.Matrix; proxy of <Swig Object of type 'OpenMEEG::Matrix *' at 0x7f2939d7ad20> >
m=3
# RIEN ! pas d'appel au destructor... etrange... en fait des que l'on execute
# simplement 'm', il retourne (a python) l'objet lui meme et enleve a m sa
# responsabilite

print('    ## 2 OK all perfect ')
m=om.Matrix(10,10)
#Linop constructor 0x5599b0d11790
#  Matrix constructor 0x5599b0d11790
m1=m
# destructor called 0x5599b0c0ebc0 (because m1 existed already)
m=1
# no destructor called
m1=4
#  Matrix destructor 0x5599b0d11790
#destructor called 0x5599b0d11790
# OK all perfect

print('        ## 3 ')
m=om.Matrix(10,10)
M=om.asarray(m)
m.set(4)
m=2 # destructor of m called.. thus M ... failed


print('        ## 4 ')
m=om.Matrix(10,10)
mm=om.asarray(m)
#mm= 0., 0., ...
m.set(9.);
#mm= 9., 9., ...

v=m.getcol(0)
vv=om.asarray(v)
v.set(4.);
v.info();

w=om.asarray(m.getcol(0)+v)
print w


###############################################################################
# remove useless files
###############################################################################
os.remove(hm_file)
os.remove(ssm_file)
