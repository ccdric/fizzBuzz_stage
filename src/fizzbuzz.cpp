#include "fizzbuzz.h"
#include <string>

using namespace std;

FizzBuzz::FizzBuzz(){}

const string FizzBuzz::direUnNombre(const int nombre)
{
    string resultat = "";
    if (nombre % FIZZ_NBRE == 0)
        resultat="fizz";
    if (nombre % BUZZ_NBRE == 0)
        resultat+="Buzz";
    if (nombre % FIZZ_NBRE != 0 && nombre % BUZZ_NBRE != 0)
        resultat = to_string(nombre);
    return resultat;
}
