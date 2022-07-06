#include <iostream>
#include "utestglob.h"
#include "fizzbuzz.h"
#include <string>

using namespace std;

class T01_FizzBuzzDoit : public ::testing::Test {

 protected:

    T01_FizzBuzzDoit(){
    }

    virtual void SetUp() {
    }

    virtual void TearDown() {
    }

    void testCasSpeciaux(int cas, const string & attendu, const string & position=""){
        int random = rand() % 100 * cas;
        EXPECT_EQ(FizzBuzz::direUnNombre(cas), attendu);
        EXPECT_EQ(FizzBuzz::direUnNombre(cas*2), attendu);
        EXPECT_EQ(FizzBuzz::direUnNombre(random), attendu);
    }
};

TEST_F(T01_FizzBuzzDoit, retournerFizz)
{
    testCasSpeciaux(FIZZ_NBRE,"Fizz");
}

TEST_F(T01_FizzBuzzDoit, retournerBuzz)
{
    testCasSpeciaux(BUZZ_NBRE,"Buzz");
}

TEST_F(T01_FizzBuzzDoit, retournerFizzBuzz)
{
    testCasSpeciaux(FIZZ_NBRE*BUZZ_NBRE,"FizzBuzz");
}

TEST_F(T01_FizzBuzzDoit, retournerNombre)
{
    EXPECT_EQ(FizzBuzz::direUnNombre(1), "1");
    EXPECT_EQ(FizzBuzz::direUnNombre(71), "71");
}
