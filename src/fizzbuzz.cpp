#include "fizzbuzz.h"
#include <string>

using namespace std;

FizzBuzz::FizzBuzz(){}

inline bool detect(int nombre, int cas) {return nombre % cas == 0;}
inline bool detectFizz(int nombre) {return detect(nombre, FIZZ_NBRE);}
inline bool detectBuzz(int nombre) {return detect(nombre, BUZZ_NBRE);}

const string FizzBuzz::direUnNombre(const int nombre)
{
    string resultat = "";
    if (detectFizz(nombre))
        resultat="fizz";
    if (detectBuzz(nombre))
        resultat+="Buzz";
    if ( ! detectFizz(nombre) && ! detectBuzz(nombre))
        resultat = to_string(nombre);
    return resultat;
}
