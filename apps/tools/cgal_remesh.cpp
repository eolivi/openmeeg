/*
Project Name : OpenMEEG

© INRIA and ENPC (contributors: Geoffray ADDE, Maureen CLERC, Alexandre
GRAMFORT, Renaud KERIVEN, Jan KYBIC, Perrine LANDREAU, Théodore PAPADOPOULO,
Emmanuel OLIVI
Maureen.Clerc.AT.inria.fr, keriven.AT.certis.enpc.fr,
kybic.AT.fel.cvut.cz, papadop.AT.inria.fr)

The OpenMEEG software is a C++ package for solving the forward/inverse
problems of electroencephalography and magnetoencephalography.

This software is governed by the CeCILL-B license under French law and
abiding by the rules of distribution of free software.  You can  use,
modify and/ or redistribute the software under the terms of the CeCILL-B
license as circulated by CEA, CNRS and INRIA at the following URL
"http://www.cecill.info".

As a counterpart to the access to the source code and  rights to copy,
modify and redistribute granted by the license, users are provided only
with a limited warranty  and the software's authors,  the holders of the
economic rights,  and the successive licensors  have only  limited
liability.

In this respect, the user's attention is drawn to the risks associated
with loading,  using,  modifying and/or developing or reproducing the
software by the user in light of its specific status of free software,
that may mean  that it is complicated to manipulate,  and  that  also
therefore means  that it is reserved for developers  and  experienced
professionals having in-depth computer knowledge. Users are therefore
encouraged to load and test the software's suitability as regards their
requirements in conditions enabling the security of their systems and/or
data to be ensured and,  more generally, to use and operate it in the
same conditions as regards security.

The fact that you are presently reading this means that you have had
knowledge of the CeCILL-B license and that you accept its terms.
*/

#include <cgal_lib.h>
#include <mesh.h>
#include <options.h>

using namespace OpenMEEG;

int main(int argc, char **argv) {
  command_usage("Re-mesh a mesh:");
  const char *input_filename =
      command_option("-i", (const char *)NULL, "Input image or mesh");
  const double radius_bound =
      command_option("-fs", 1e-1, "facet radius bound of elements");
  const double distance_bound =
      command_option("-fd", 1e-1, "facet distance bound to the input surface");
  const char *output_filename =
      command_option("-o", (const char *)NULL, "Output Mesh");
  const char *sizing_field = command_option(
      "-field", (const char *)NULL,
      "(OPTIONAL) definition of the space to be refined 3 times finer (a "
      "matrix file: with either: \"x y z nx ny nz\" per line to define planes "
      "(by intersection of domains), or \"x y z r\" to define spheres (by "
      "union of domains).)");

  if (command_option("-h", (const char *)0, 0)) {
    return 0;
  }
  if (output_filename == NULL) {
    std::cerr << "Set an output filename" << std::endl;
    return 0;
  }

  // Mesh input
  Mesh m_in(input_filename, false);
  std::cout << "Input surface:\n nb of points: " << m_in.nb_vertices()
            << "\t nb of triangles:\t" << m_in.nb_triangles() << std::endl;

  Mesh m_out = cgal_refine(m_in, radius_bound, distance_bound, sizing_field);
  m_out.save(output_filename);
  m_out.info();
  return 0;
}
