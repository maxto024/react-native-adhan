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

#include "tz.h"
#include <cassert>
#include <chrono>
#include <istream>
#include <string>
#include <vector>

namespace date
{

namespace detail
{

struct zone_info
{
    std::string name;
    std::vector<sys_info> transitions;
};

}  // namespace detail

sys_info::sys_info(std::chrono::system_clock::time_point begin,
                   std::chrono::system_clock::time_point end,
                   std::chrono::seconds offset, std::chrono::minutes save,
                   const std::string& abbrev)
    : begin_(begin)
    , end_(end)
    , offset_(offset)
    , save_(save)
    , abbrev_(abbrev)
{}

local_info::local_info(int result, const sys_info& first, const sys_info& second)
    : result_(result)
    , first_(first)
    , second_(second)
{}

time_zone::time_zone(const std::string& s)
    : pimpl_(new detail::zone_info{s, {}})
{}

time_zone::time_zone(const time_zone& other)
    : pimpl_(new detail::zone_info(*other.pimpl_))
{}

time_zone&
time_zone::operator=(const time_zone& other)
{
    if (this != &other)
        *pimpl_ = *other.pimpl_;
    return *this;
}

time_zone::time_zone(time_zone&& other) noexcept
    : pimpl_(std::move(other.pimpl_))
{}

time_zone&
time_zone::operator=(time_zone&& other) noexcept
{
    pimpl_ = std::move(other.pimpl_);
    return *this;
}

time_zone::~time_zone() = default;

const std::string&
time_zone::name() const noexcept
{
    return pimpl_->name;
}

template<class Duration>
sys_info
time_zone::get_info(std::chrono::time_point<std::chrono::system_clock, Duration> st) const
{
    // This is a dummy implementation. A real implementation would
    // use the IANA database to find the correct sys_info.
    return sys_info{std::chrono::system_clock::time_point::min(),
                    std::chrono::system_clock::time_point::max(),
                    std::chrono::seconds{0}, std::chrono::minutes{0}, "UTC"};
}

template<class Duration>
local_info
time_zone::get_info(std::chrono::time_point<std::chrono::local_t, Duration> tp) const
{
    // This is a dummy implementation.
    return local_info{local_info::unique,
                      sys_info{std::chrono::system_clock::time_point::min(),
                               std::chrono::system_clock::time_point::max(),
                               std::chrono::seconds{0}, std::chrono::minutes{0}, "UTC"},
                      sys_info{}};
}

template<class Duration>
std::chrono::time_point<std::chrono::local_t, Duration>
time_zone::to_local(std::chrono::time_point<std::chrono::system_clock, Duration> st) const
{
    auto i = get_info(st);
    return std::chrono::time_point<std::chrono::local_t, Duration>{(st + i.offset()).time_since_epoch()};
}

template<class Duration>
std::chrono::time_point<std::chrono::system_clock, Duration>
time_zone::to_sys(std::chrono::time_point<std::chrono::local_t, Duration> tp) const
{
    auto i = get_info(tp);
    if (i.result() == local_info::unique)
        return std::chrono::time_point<std::chrono::system_clock, Duration>{(tp - i.first().offset()).time_since_epoch()};
    // In a real implementation, you would handle nonexistent and ambiguous cases.
    // For this example, we'll just return the first possibility.
    return std::chrono::time_point<std::chrono::system_clock, Duration>{(tp - i.first().offset()).time_since_epoch()};
}

template<class Duration>
std::chrono::time_point<std::chrono::system_clock, Duration>
time_zone::to_sys(std::chrono::time_point<std::chrono::local_t, Duration> tp, choose z) const
{
    auto i = get_info(tp);
    if (i.result() == local_info::unique)
        return std::chrono::time_point<std::chrono::system_clock, Duration>{(tp - i.first().offset()).time_since_epoch()};
    if (z == choose::latest)
        return std::chrono::time_point<std::chrono::system_clock, Duration>{(tp - i.second().offset()).time_since_epoch()};
    return std::chrono::time_point<std::chrono::system_clock, Duration>{(tp - i.first().offset()).time_since_epoch()};
}

bool operator==(const time_zone& x, const time_zone& y) noexcept
{
    return x.name() == y.name();
}

bool operator<(const time_zone& x, const time_zone& y) noexcept
{
    return x.name() < y.name();
}

std::ostream& operator<<(std::ostream& os, const time_zone& z)
{
    return os << z.name();
}

const time_zone*
locate_zone(const std::string& tz_name)
{
    // This is a dummy implementation. A real implementation would
    // load the IANA database and find the correct time_zone.
    static time_zone utc("UTC");
    if (tz_name == "UTC")
        return &utc;
    // For other timezones, you would need a real implementation.
    // For now, we'll just return a new time_zone object.
    // This will leak memory, but it's just for demonstration.
    return new time_zone(tz_name);
}

const time_zone*
current_zone()
{
    // This is a dummy implementation.
    return locate_zone("UTC");
}

void
reload_tzdb()
{
    // This is a dummy implementation.
}

template<class Duration>
zoned_time<Duration>::zoned_time()
    : zone_(current_zone())
{}

template<class Duration>
zoned_time<Duration>::zoned_time(const std::string& name)
    : zone_(locate_zone(name))
{}

template<class Duration>
zoned_time<Duration>::zoned_time(const time_zone* z)
    : zone_(z)
{}

template<class Duration>
zoned_time<Duration>::zoned_time(const std::string& name, const std::chrono::time_point<std::chrono::system_clock, Duration>& st)
    : zone_(locate_zone(name))
    , tp_(st)
{}

template<class Duration>
zoned_time<Duration>::zoned_time(const time_zone* z, const std::chrono::time_point<std::chrono::system_clock, Duration>& st)
    : zone_(z)
    , tp_(st)
{}

template<class Duration>
zoned_time<Duration>::zoned_time(const std::string& name, const std::chrono::time_point<std::chrono::local_t, Duration>& tp)
    : zone_(locate_zone(name))
    , tp_(zone_->to_sys(tp))
{}

template<class Duration>
zoned_time<Duration>::zoned_time(const time_zone* z, const std::chrono::time_point<std::chrono::local_t, Duration>& tp)
    : zone_(z)
    , tp_(zone_->to_sys(tp))
{}

template<class Duration>
zoned_time<Duration>::zoned_time(const std::string& name, const std::chrono::time_point<std::chrono::local_t, Duration>& tp, choose z)
    : zone_(locate_zone(name))
    , tp_(zone_->to_sys(tp, z))
{}

template<class Duration>
zoned_time<Duration>::zoned_time(const time_zone* z, const std::chrono::time_point<std::chrono::local_t, Duration>& tp, choose z)
    : zone_(z)
    , tp_(zone_->to_sys(tp, z))
{}

template <class Duration>
template <class Duration2>
zoned_time<Duration>::zoned_time(const zoned_time<Duration2>& zt)
    : zone_(zt.get_time_zone())
    , tp_(zt.get_sys_time())
{}

template<class Duration>
zoned_time<Duration>&
zoned_time<Duration>::operator=(const std::chrono::time_point<std::chrono::system_clock, Duration>& st)
{
    tp_ = st;
    return *this;
}

template<class Duration>
zoned_time<Duration>&
zoned_time<Duration>::operator=(const std::chrono::time_point<std::chrono::local_t, Duration>& tp)
{
    tp_ = zone_->to_sys(tp);
    return *this;
}

template<class Duration>
zoned_time<Duration>::operator std::chrono::time_point<std::chrono::system_clock, Duration>() const
{
    return tp_;
}

template<class Duration>
zoned_time<Duration>::operator std::chrono::time_point<std::chrono::local_t, Duration>() const
{
    return zone_->to_local(tp_);
}

template<class Duration>
const time_zone*
zoned_time<Duration>::get_time_zone() const
{
    return zone_;
}

template<class Duration>
local_info
zoned_time<Duration>::get_info() const
{
    return zone_->get_info(get_local_time());
}

template<class Duration>
std::chrono::time_point<std::chrono::system_clock, Duration>
zoned_time<Duration>::get_sys_time() const
{
    return tp_;
}

template<class Duration>
std::chrono::time_point<std::chrono::local_t, Duration>
zoned_time<Duration>::get_local_time() const
{
    return zone_->to_local(tp_);
}

template<class CharT, class Traits, class Duration>
std::basic_ostream<CharT, Traits>&
operator<<(std::basic_ostream<CharT, Traits>& os, const zoned_time<Duration>& t)
{
    return os << t.get_local_time() << ' ' << t.get_time_zone()->name();
}

}  // namespace date
#endif  // TZ_H