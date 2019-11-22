#include <iostream>
#include "../Person.h"

int main(int argc, char** argv) {
    Person a;
    Person b(a);
    Person c = a;

    try {
      a.set(Vars::_NONE, 0);
      a.set(Vars::_NONE, 1.0);
      a.get(Vars::_NONE);
      a.test(Vars::_NONE);
    } catch(fem_exception e) {
      std::cerr << e.what() << std::endl;
    }

    std::cout << "No seg faults? You're good, for now." << std::endl;
}
