#include <iostream>
#include "utestglob.h"
#include "fizzbuzz.h"
#include <string>

using namespace std;

#define ORIGINE (" ==> " + std::string(__PRETTY_FUNCTION__) + ", ligne = " + std::to_string(__LINE__) + " : \n")
#define TEST_CAS_SPECIAUX(NOMBRE, ATTENDU) (testCasSpeciaux(NOMBRE, ATTENDU,ORIGINE))

class T01_FizzBuzzDoit : public ::testing::Test {

 protected:

    T01_FizzBuzzDoit(){
    }

    virtual void SetUp() {
    }

    virtual void TearDown() {
    }

    void testCasSpeciaux(int cas, const string & attendu, const string & position){
        SCOPED_TRACE("\n Origine  : " + position );
        int random = rand() % 100 * cas;
        EXPECT_EQ(FizzBuzz::direUnNombre(cas), attendu);
        EXPECT_EQ(FizzBuzz::direUnNombre(cas*2), attendu);
        EXPECT_EQ(FizzBuzz::direUnNombre(random), attendu);
    }
};

TEST_F(T01_FizzBuzzDoit, retournerFizz)
{
    TEST_CAS_SPECIAUX(FIZZ_NBRE,"Fizz");
}

TEST_F(T01_FizzBuzzDoit, retournerBuzz)
{
    TEST_CAS_SPECIAUX(BUZZ_NBRE,"Buzz");
}

TEST_F(T01_FizzBuzzDoit, retournerFizzBuzz)
{
    TEST_CAS_SPECIAUX(FIZZ_NBRE*BUZZ_NBRE,"FizzBuzz");
}

TEST_F(T01_FizzBuzzDoit, retournerNombre)
{
    EXPECT_EQ(FizzBuzz::direUnNombre(1), "1");
    EXPECT_EQ(FizzBuzz::direUnNombre(71), "71");
}
