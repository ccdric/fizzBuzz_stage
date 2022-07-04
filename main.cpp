#include <iostream>
#include "fizzbuzz.h"

using namespace std;

int main()
{
    int nombre;
    cout << "Entrer un nombre : ";
    cin >> nombre;
    cout << endl << FizzBuzz::direUnNombre(nombre) << endl << endl;
}
