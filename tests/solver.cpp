#undef __STRICT_ANSI__

#define BOOST_TEST_MAIN 1

// 'put_env' is not exported with strict ansi set
#include <cstdlib>

#include <boost/test/unit_test.hpp>
using namespace boost;
using namespace std;

BOOST_AUTO_TEST_CASE( derp) {
    return;
} 
