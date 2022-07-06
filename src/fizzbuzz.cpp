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
            return "FizzBuzz";
        else
            return "Fizz";
    else
        if (detectBuzz(nombre))
            return "Buzz";
    return to_string(nombre);
}
