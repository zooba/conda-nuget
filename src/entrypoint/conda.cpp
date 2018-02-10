#include <Python.h>

int
wmain(int argc, wchar_t **argv)
{
    const wchar_t **new_argv = new const wchar_t*[argc + 2];
    new_argv[0] = argv[0];
    new_argv[1] = L"-m";
    new_argv[2] = L"conda";
    for (int i = 1; i < argc; ++i) {
        new_argv[i + 2] = argv[i];
    }
    int res = Py_Main(argc + 2, (wchar_t **)new_argv);
    delete[] new_argv;
    return res;
}
