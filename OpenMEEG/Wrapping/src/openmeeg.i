%module(docstring="OpenMEEG bindings for python") openmeeg

%include <exception.i>
%exception {
    try {
        $action
    } catch (const std::exception& e) {
        SWIG_exception(SWIG_RuntimeError, e.what());
    }
}

#ifdef SWIGWIN
%include <windows.i>
#endif

%include <std_string.i>
%include <std_vector.i>

%typemap(memberin) PyObject * {
  Py_DecRef($1);
  $1 = $input;
  Py_IncRef($1);
}

%{
    #define SWIG_FILE_WITH_INIT
    #include <vect3.h>
    #include <vertex.h>
    #include <triangle.h>
    #include <linop.h>
    #include <vector.h>
    #include <matrix.h>
    #include <symmatrix.h>
    #include <sparse_matrix.h>
    #include <fast_sparse_matrix.h>
    #include <sensors.h>
    #include <geometry.h>
    #include <geometry_io.h>
    #include <mesh.h>
    #include <interface.h>
    #include <domain.h>
    #include <assemble.h>
    #include <gain.h>
    #include <forward.h>

    using namespace OpenMEEG;

    #ifdef SWIGPYTHON

        #define NPY_NO_DEPRECATED_API NPY_1_7_API_VERSION
        #include <numpy/arrayobject.h>

        static PyObject* asarray(OpenMEEG::Matrix* mat) {
            if (!mat) {
                PyErr_SetString(PyExc_RuntimeError, "Zero pointer passed instead of valid Matrix struct.");
                return(NULL);
            }

            /* array object */
            PyArrayObject* matarray = 0;

            /* Get the number of dimensions from the Matrix
             */
            const npy_intp ndims = 2;
            npy_intp ar_dim[] = { static_cast<npy_intp>(mat->nlin()), static_cast<npy_intp>(mat->ncol()) };

            /* create numpy array */
            matarray = (PyArrayObject*) PyArray_NewFromDescr(&PyArray_Type, PyArray_DescrFromType(NPY_DOUBLE), ndims, ar_dim, NULL, (void *) mat->data(),NPY_ARRAY_FARRAY,NULL);
            Py_IncRef((PyObject *)matarray);

            return PyArray_Return((PyArrayObject*) matarray);
        }

        class PyArrayObject2: public PyArrayObject {
            OpenMEEG::Vector vec;
        public:
            PyArrayObject2(const PyArrayObject2& copy): PyArrayObject(copy), vec(copy.vec) {
                std::cout << "copy constructor de PyArrayObject2" << std::endl;
            }
            void setO(OpenMEEG::Vector* vec) {
                std::cout << "Il est entre par ici" << std::endl;
                this->vec = OpenMEEG::Vector(*vec);
            }
        };
    
        static PyObject* asarray(OpenMEEG::Vector* vec) {
            if (!vec) {
                PyErr_SetString(PyExc_RuntimeError, "Zero pointer passed instead of valid Vector struct.");
                return(NULL);
            }

            // std::cerr << "asarray: vec = " << *vec << std::endl; /*TODO */
            //vec->value.pointee->addReference();
            /* Vector vec2(*vec); does not work */

            /* array object */
            // PyArrayObject2* matarray = 0;
            PyArrayObject* matarray = 0;

            /* Get the size of the Vector */
            const npy_intp ndims = 1;
            npy_intp ar_dim[] = { static_cast<npy_intp>(vec->size()) };

            /* create numpy array */
            // matarray = (PyArrayObject2*) PyArray_NewFromDescr(&PyArray_Type,PyArray_DescrFromType(NPY_DOUBLE),ndims,ar_dim,NULL,static_cast<void*>(vec->data()),NPY_ARRAY_FARRAY,NULL);
            // matarray->setO(vec);
            matarray = (PyArrayObject*) PyArray_NewFromDescr(&PyArray_Type,PyArray_DescrFromType(NPY_DOUBLE),ndims,ar_dim,NULL,static_cast<void*>(vec->data()),NPY_ARRAY_FARRAY,NULL);

            return PyArray_Return(matarray);
        }

        /* Create a Matrix from an array */
        static OpenMEEG::Matrix fromarray(PyObject* mat) {
            if (!mat) {
                PyErr_SetString(PyExc_RuntimeError, "Zero pointer passed instead of valid array.");
                return NULL;
            }
            PyArrayObject* matt = (PyArrayObject*) PyArray_FromObject(mat,NPY_DOUBLE,1,2);
            const size_t nl = PyArray_DIM(matt,0);
            const size_t nc = (PyArray_NDIM(matt)==2) ? PyArray_DIM(matt,1) : 1;
            OpenMEEG::Matrix omat(nl,nc);
            for (unsigned i=0;i<nl;++i)
                for (unsigned j=0;j<nc;++j)
                    omat(i,j) = *(static_cast<double*>(PyArray_GETPTR2(matt,i,j)));
            return omat;
        }
        
    #endif
%}

%pythoncode {
def loadmat(fname):
    try:
        from scipy import io
        io.loadmat(fname)['linop']
    except:
        import h5py
        return h5py.File(fname)['linop'].value.T

}

%include "numpy.i"

%init %{
import_array();
//import_array1(NULL); For future python 3.x
%}

%exception {
    try {
        $action
    }
    catch (std::exception& e) {
        PyErr_SetString(PyExc_RuntimeError,e.what());
        return NULL;
    }
}

/* DLL Exports handling on Windows */
#define OPENMEEGMATHS_EXPORT
#define OPENMEEG_EXPORT

#ifdef DOCSTRINGS
%include <docstrings.i>
#endif

namespace std {
    %template(vector_int) vector<int>;
    %template(vector_unsigned) vector<unsigned int>;
    %template(vector_double) vector<double>;
    %template(vector_vertex) vector<OpenMEEG::Vertex>;
    %template(vector_pvertex) vector<OpenMEEG::Vertex *>;
    %template(vector_triangle) vector<OpenMEEG::Triangle>;
    %template(vector_mesh) vector<OpenMEEG::Mesh>;
    %template(vector_domain) vector<OpenMEEG::Domain>;
    %template(vector_string) vector<std::string>;
    %template(vector_interface) vector<OpenMEEG::Interface>;
}

%typemap(out) OpenMEEG::Matrix &
{
    if(result) { /* suppress unused warning */ }
    Py_INCREF($self);
    $result = $self;
}
namespace OpenMEEG {
//    %typedef std::vector<OpenMEEG::Vertex> Vertices;
//    %typedef std::vector<OpenMEEG::Vertex *> PVertices;
//    %typedef std::vector<OpenMEEG::Triangle> Triangles;
//    %typedef std::vector<OpenMEEG::Mesh> Meshes;
//    %typedef std::vector<OpenMEEG::Domain> Domains;

    // %ignore Vector::~Vector; /* // ignoring C++ destructor */ ne fonctionne pas...
    // %nodefaultdtor Vector;   /* // don't generate a destructor */
    // %feature("ref")   RCObject "$this->addReference();"
    // %feature("unref") RCObject "$this->removeReference();"
    %refobject   RCObject "$this->addReference();"
    %unrefobject RCObject "$this->removeReference();"
}

// TODO ici
%feature("ref")   RCObject "$this->addReference();"
%feature("unref") RCObject "$this->removeReference();"
//%feature("ref")   OpenMEEG::RCObject "$this->addReference();"
//%feature("unref") OpenMEEG::RCObject "$this->removeReference();"

//
// using the %refobject/%unrefobject directives you can activate the
// reference counting for RCObj and all its descendents at once
//

// %refobject   RCObject "$this->addReference();"
// %unrefobject RCObject "$this->removeReference();"

%include <RC.H>

// #if defined(SWIGPYTHON)
// %extend_smart_pointer(utils::RCPtr<A>);
// %template(RCPtr_A) utils::RCPtr<A>;
// #endif


%include <vect3.h>
%include <vertex.h>
%include <triangle.h>
%include <linop.h>
%include <vector.h>
%include <matrix.h>
%include <symmatrix.h>
%include <sparse_matrix.h>
%include <fast_sparse_matrix.h>
%include <geometry.h>
%include <geometry_io.h>
%include <sensors.h>
%include <mesh.h>
%include <interface.h>
%include <domain.h>
%include <assemble.h>
%include <gain.h>
%include <forward.h>

// nothing works
// %newobject OpenMEEG::Matrix::getcol(size_t i);
// %newobject OpenMEEG::Vector::Vector();
// %newobject OpenMEEG::Vector::asarray();
// %newobject OpenMEEG::Matrix::asarray(OpenMEEG::Matrix* mat);

%extend OpenMEEG::Vertex {
    // TODO almost.. if I do: v.index() I get:
    // <Swig Object of type 'unsigned int *' at 0x22129f0>
    // I want simply an unsigned. workaround:
    unsigned int getindex() {
        return ($self)->index();
    }
}

%extend OpenMEEG::Triangle {
    // TODO almost.. if I do: t.index() I get:
    // <Swig Object of type 'unsigned int *' at 0x22129f0>
    // I want simply an unsigned. workaround:
    unsigned int getindex() {
        return ($self)->index();
    }
}

%extend OpenMEEG::Vector {
    // TODO almost.. v(2)=0. does not work, workaround:
    void setvalue(unsigned int i, double d) {
        (*($self))(i)=d;
    }
    /* essai d extension mais ce nest pas satisfaisant:
     >W=(m.getcol(0)+v+v).asarray()
     asarray: vec = 13 13 13 13 13 13 13 13 13 13
     >W
     array([  4.64148468e-310,   4.64148465e-310,   6.92064265e-310,
         6.92064265e-310,   6.92065376e-310,   6.92065376e-310,
         6.92065376e-310,   6.92064220e-310,   6.92064220e-310,
         6.92064220e-310])
     */
    PyObject* asarray() {
         /*std::cerr << "asarray: vec = " << *($self) << std::endl;TODO */
        // only this works
        /* ($self)->value.pointee->addReference(); */
        /* Vector vec2(*vec); does not work */

        /* array object */
        PyArrayObject* matarray = 0;

        /* Get the size of the Vector */
        const npy_intp ndims = 1;
        npy_intp ar_dim[] = { static_cast<npy_intp>(($self)->size()) };

        /* create numpy array */
        matarray = (PyArrayObject*) PyArray_NewFromDescr(&PyArray_Type,PyArray_DescrFromType(NPY_DOUBLE),ndims,ar_dim,NULL,static_cast<void*>(($self)->data()),NPY_ARRAY_FARRAY,NULL);

        return PyArray_Return(matarray);
    }
}

%extend OpenMEEG::Matrix {
    void setvalue(unsigned int i, unsigned int j, double d) {
        (*($self))(i,j)=d;
    }
}

%extend OpenMEEG::Mesh {
    // TODO almost.. if I do: m.name() I get:
    // <Swig Object of type 'std::string *' at 0x2c92ea0>
    std::string __str__() {
        return ($self)->name().c_str();
    }
}
/* TODO
%include <cpointer.i>
%pointer_class(Interface ,InterfaceP)
We would like to have an Interface when asking for
i=geom.outermost_interface()
instead we have a pointer to it:
<Swig Object of type 'Interface *' at 0xa1e1590>
*/

static PyObject* asarray(OpenMEEG::Matrix* _mat);
static PyObject* asarray(OpenMEEG::Vector* _vec);
static OpenMEEG::Matrix fromarray(PyObject* _mat);
// %newobject asarray(OpenMEEG::Vector* _vec);

%pythoncode{
import numpy as np
class ND(np.ndarray):
    def __init__(self, a):
        print "ici"
        np.ndarray(a)
        self.vec = om.Vector()
    def setO(self,vec):
        print "la"
        self.vec = om.Vector(vec)
}
