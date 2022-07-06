#include "fizzbuzz.h"
#include <string>

using namespace std;

FizzBuzz::FizzBuzz(){}

const string FizzBuzz::direUnNombre(const int nombre)
{
    string resultat = "";
    if (nombre % 3 == 0)
        resultat="fizz";
    if (nombre % 5 == 0)
        resultat+="Buzz";
    if (nombre % 3 != 0 && nombre % 5 != 0)
        resultat = to_string(nombre);
    return resultat;
}
