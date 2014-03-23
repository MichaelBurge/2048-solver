#undef __STRICT_ANSI__
#define BOOST_TEST_MAIN 1

// 'put_env' is not exported with strict ansi set
#include <cstdlib>
#include <iostream>
#include <stdint.h>

#include <boost/test/unit_test.hpp>
using namespace boost;
using namespace std;

#include "../solver.h"

BOOST_AUTO_TEST_CASE( test_free_squares ) {
    Bitset board[10];
    memset(board, 0, 10 * sizeof(Bitset));
    BOOST_REQUIRE_EQUAL(free_squares(board), 0xFFFF);
    board[0] = 1;
    BOOST_REQUIRE_EQUAL(free_squares(board), 0xFFFE);
}

BOOST_AUTO_TEST_CASE( test_new_game ) {
    uint16_t board[10];
    memset(board, 0, 10 * sizeof(Bitset));
    new_game(board);
    for (int i = 0; i < 10; i++)
    	cout << board[i] << endl;
}

BOOST_AUTO_TEST_CASE( test_nth_one ) {
    uint64_t a = 0xFFFFFFFFFFFFFFFF;
    BOOST_REQUIRE_EQUAL(nth_one(a, 0), 0);
    BOOST_REQUIRE_EQUAL(nth_one(a, 1), 1);
    BOOST_REQUIRE_EQUAL(nth_one(a, 2), 2);
    BOOST_REQUIRE_EQUAL(nth_one(a, 3), 3);
    BOOST_REQUIRE_EQUAL(nth_one(a, 4), 4);

    uint64_t x = 0x0000100000001001;
    BOOST_REQUIRE_EQUAL(nth_one(x, 0), 0);
    BOOST_REQUIRE_EQUAL(nth_one(x, 1), 12);
    BOOST_REQUIRE_EQUAL(nth_one(x, 2), 44);
}

