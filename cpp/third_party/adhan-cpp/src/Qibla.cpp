#include "../include/adhan/Adhan.hpp"
#include <cmath>

namespace adhan {

class Qibla {
private:
    double direction;
    
public:
    Qibla(const Coordinates& coordinates) {
        // Kaaba coordinates
        double meccaLat = 21.4225;
        double meccaLon = 39.8262;
        
        double lat1 = coordinates.latitude * M_PI / 180.0;
        double lat2 = meccaLat * M_PI / 180.0;
        double deltaLon = (meccaLon - coordinates.longitude) * M_PI / 180.0;
        
        double y = sin(deltaLon) * cos(lat2);
        double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon);
        
        direction = atan2(y, x) * 180.0 / M_PI;
        direction = fmod(direction + 360.0, 360.0);
    }
    
    double getDirection() const {
        return direction;
    }
};

}