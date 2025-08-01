#ifndef TZ_H
#define TZ_H

// The MIT License (MIT)
//
// Copyright (c) 2015, 2016, 2017 Howard Hinnant
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// Howard Hinnant
// For more information, see http://howardhinnant.github.io/date/tz.html
//
// Asia-Pacific Regional Meeting, 2015-11-12
// http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2015/p0083r0.pdf

#include "date/date.h"
#include <memory>
#include <string>
#include <vector>

namespace date
{

enum class choose {earliest, latest};

class time_zone;
class zoned_time;

namespace detail
{
    struct zone_info;
}

class sys_info
{
    std::chrono::system_clock::time_point begin_;
    std::chrono::system_clock::time_point end_;
    std::chrono::seconds                  offset_;
    std::chrono::minutes                  save_;
    std::string                           abbrev_;

public:
    sys_info() = default;
    sys_info(std::chrono::system_clock::time_point begin,
             std::chrono::system_clock::time_point end,
             std::chrono::seconds offset, std::chrono::minutes save,
             const std::string& abbrev);

    std::chrono::system_clock::time_point
    begin() const noexcept {return begin_;}

    std::chrono::system_clock::time_point
    end() const noexcept {return end_;}

    std::chrono::seconds
    offset() const noexcept {return offset_;}

    std::chrono::minutes
    save() const noexcept {return save_;}

    std::string
    abbrev() const {return abbrev_;}
};

class local_info
{
    enum {unique, nonexistent, ambiguous};

    int          result_;
    sys_info     first_;
    sys_info     second_;

public:
    local_info() = default;
    local_info(int result, const sys_info& first, const sys_info& second);

    int result() const {return result_;}

    const sys_info& first() const {return first_;}
    const sys_info& second() const {return second_;}
};

class time_zone
{
    std::unique_ptr<detail::zone_info> pimpl_;

public:
    time_zone(const time_zone&);
    time_zone& operator=(const time_zone&);
    time_zone(time_zone&&) noexcept;
    time_zone& operator=(time_zone&&) noexcept;
    ~time_zone();

    explicit time_zone(const std::string& s);

    const std::string& name() const noexcept;

    template<class Duration>
        sys_info   get_info(std::chrono::time_point<std::chrono::system_clock, Duration> st) const;
    template<class Duration>
        local_info get_info(std::chrono::time_point<std::chrono::local_t, Duration> tp) const;

    template<class Duration>
    std::chrono::time_point<std::chrono::local_t, Duration>
    to_local(std::chrono::time_point<std::chrono::system_clock, Duration> st) const;

    template<class Duration>
    std::chrono::time_point<std::chrono::system_clock, Duration>
    to_sys(std::chrono::time_point<std::chrono::local_t, Duration> tp) const;

    template<class Duration>
    std::chrono::time_point<std::chrono::system_clock, Duration>
    to_sys(std::chrono::time_point<std::chrono::local_t, Duration> tp, choose z) const;

    friend bool operator==(const time_zone& x, const time_zone& y) noexcept;
    friend bool operator< (const time_zone& x, const time_zone& y) noexcept;
    friend std::ostream& operator<<(std::ostream& os, const time_zone& z);
};

inline bool operator!=(const time_zone& x, const time_zone& y) noexcept {return !(x == y);}
inline bool operator> (const time_zone& x, const time_zone& y) noexcept {return y < x;}
inline bool operator<=(const time_zone& x, const time_zone& y) noexcept {return !(y < x);}
inline bool operator>=(const time_zone& x, const time_zone& y) noexcept {return !(x < y);}

const time_zone* locate_zone(const std::string& tz_name);
const time_zone* current_zone();
void reload_tzdb();

template<class T>
struct zoned_traits;

template<class Duration>
class zoned_time<Duration>
{
    time_zone const* zone_ = nullptr;
    std::chrono::time_point<std::chrono::system_clock, Duration> tp_{};

public:
    zoned_time();
    zoned_time(const zoned_time&) = default;
    zoned_time& operator=(const zoned_time&) = default;
    zoned_time(zoned_time&&) = default;
    zoned_time& operator=(zoned_time&&) = default;

    zoned_time(const std::string& name);
    zoned_time(const time_zone* z);
    zoned_time(const std::string& name, const std::chrono::time_point<std::chrono::system_clock, Duration>& st);
    zoned_time(const time_zone* z, const std::chrono::time_point<std::chrono::system_clock, Duration>& st);
    zoned_time(const std::string& name, const std::chrono::time_point<std::chrono::local_t, Duration>& tp);
    zoned_time(const time_zone* z, const std::chrono::time_point<std::chrono::local_t, Duration>& tp);
    zoned_time(const std::string& name, const std::chrono::time_point<std::chrono::local_t, Duration>& tp, choose z);
    zoned_time(const time_zone* z, const std::chrono::time_point<std::chrono::local_t, Duration>& tp, choose z);

    template <class Duration2>
        zoned_time(const zoned_time<Duration2>& zt);

    zoned_time& operator=(const std::chrono::time_point<std::chrono::system_clock, Duration>& st);
    zoned_time& operator=(const std::chrono::time_point<std::chrono::local_t, Duration>& tp);

    explicit operator std::chrono::time_point<std::chrono::system_clock, Duration>() const;
    explicit operator std::chrono::time_point<std::chrono::local_t, Duration>() const;

    const time_zone* get_time_zone() const;
    local_info get_info() const;
    std::chrono::time_point<std::chrono::system_clock, Duration> get_sys_time() const;
    std::chrono::time_point<std::chrono::local_t, Duration> get_local_time() const;

    friend bool operator==(const zoned_time& x, const zoned_time& y)
    {
        return x.zone_ == y.zone_ && x.tp_ == y.tp_;
    }

    friend bool operator!=(const zoned_time& x, const zoned_time& y)
    {
        return !(x == y);
    }
};

using zoned_seconds = zoned_time<std::chrono::seconds>;
using zoned_days = zoned_time<days>;

template<class CharT, class Traits, class Duration>
std::basic_ostream<CharT, Traits>&
operator<<(std::basic_ostream<CharT, Traits>& os, const zoned_time<Duration>& t);

template<class Duration1, class Duration2>
bool
operator==(const zoned_time<Duration1>& x, const zoned_time<Duration2>& y)
{
    return x.get_sys_time() == y.get_sys_time();
}

template<class Duration1, class Duration2>
bool
operator!=(const zoned_time<Duration1>& x, const zoned_time<Duration2>& y)
{
    return !(x == y);
}

template<class Duration1, class Duration2>
bool
operator<(const zoned_time<Duration1>& x, const zoned_time<Duration2>& y)
{
    return x.get_sys_time() < y.get_sys_time();
}

template<class Duration1, class Duration2>
bool
operator>(const zoned_time<Duration1>& x, const zoned_time<Duration2>& y)
{
    return y < x;
}

template<class Duration1, class Duration2>
bool
operator<=(const zoned_time<Duration1>& x, const zoned_time<Duration2>& y)
{
    return !(y < x);
}

template<class Duration1, class Duration2>
bool
operator>=(const zoned_time<Duration1>& x, const zoned_time<Duration2>& y)
{
    return !(x < y);
}

}  // namespace date

#endif  // TZ_H