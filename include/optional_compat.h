#pragma once

// Compatibility shim for older compilers that only provide experimental optional.
#if __has_include(<optional>)
#include <optional>
#elif __has_include(<experimental/optional>)
#include <experimental/optional>
namespace std {
using experimental::make_optional;
using experimental::nullopt;
using experimental::nullopt_t;
using experimental::optional;
}
#else
#error "Neither <optional> nor <experimental/optional> is available"
#endif
