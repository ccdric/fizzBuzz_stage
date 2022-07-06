#include <iostream>

using namespace std;

constexpr int FIZZ_NBRE(3);
constexpr int BUZZ_NBRE(5);
const std::string ATTENDU_FIZZ("Fizz");
const std::string ATTENDU_BUZZ("Buzz");
const std::string ATTENDU_FIZZBUZZ("FizzBuzz");

struct FizzBuzz {
    FizzBuzz();
    static string direUnNombre(const int nombre);
};

