#include "fizzbuzz.h"
#include <string>

using namespace std;

FizzBuzz::FizzBuzz(){}

inline bool detect(int nombre, int cas) {return nombre % cas == 0;}
inline bool detectFizz(int nombre) {return detect(nombre, FIZZ_NBRE);}
inline bool detectBuzz(int nombre) {return detect(nombre, BUZZ_NBRE);}

string FizzBuzz::direUnNombre(const int nombre)
{
    if (detectFizz(nombre))
        if (detectBuzz(nombre))
            return ATTENDU_FIZZBUZZ;
        else
            return ATTENDU_FIZZ;
    else
        if (detectBuzz(nombre))
            return ATTENDU_BUZZ;
    return to_string(nombre);
}
