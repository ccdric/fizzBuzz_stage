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
};

TEST_F(T01_FizzBuzzDoit, retournerFizz)
{
    int random = rand() % 100 * 3;
    const string attendu= "fizz";
    EXPECT_EQ(FizzBuzz::direUnNombre(3), attendu);
    EXPECT_EQ(FizzBuzz::direUnNombre(6), attendu);
    EXPECT_EQ(FizzBuzz::direUnNombre(random), attendu);
}

TEST_F(T01_FizzBuzzDoit, retournerBuzz)
{
    int random = rand() % 100 * 5;
    const string attendu= "Buzz";
    EXPECT_EQ(FizzBuzz::direUnNombre(5), attendu);
    EXPECT_EQ(FizzBuzz::direUnNombre(10), attendu);
    EXPECT_EQ(FizzBuzz::direUnNombre(random), attendu);
}

TEST_F(T01_FizzBuzzDoit, retournerFizzBuzz)
{
    int random = rand() % 100 * 15;
    const string attendu= "fizzBuzz";
    EXPECT_EQ(FizzBuzz::direUnNombre(15), attendu);
    EXPECT_EQ(FizzBuzz::direUnNombre(random), attendu);
}

TEST_F(T01_FizzBuzzDoit, retournerNombre)
{
    EXPECT_EQ(FizzBuzz::direUnNombre(1), "1");
    EXPECT_EQ(FizzBuzz::direUnNombre(71), "71");
}
