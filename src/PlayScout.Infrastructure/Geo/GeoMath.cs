namespace PlayScout.Infrastructure.Geo;

public static class GeoMath
{
    /// <summary>WGS-84 great-circle distance in meters (Haversine).</summary>
    public static double HaversineMeters(double lat1, double lon1, double lat2, double lon2)
    {
        const double earthRadiusM = 6_371_000d;
        static double ToRad(double deg) => deg * (Math.PI / 180d);

        var dLat = ToRad(lat2 - lat1);
        var dLon = ToRad(lon2 - lon1);
        var a =
            Math.Sin(dLat / 2) * Math.Sin(dLat / 2) +
            Math.Cos(ToRad(lat1)) * Math.Cos(ToRad(lat2)) *
            Math.Sin(dLon / 2) * Math.Sin(dLon / 2);
        var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
        return earthRadiusM * c;
    }

    /// <summary>Approximate axis-aligned bounding box in degrees for a radius in meters.</summary>
    public static (double MinLat, double MaxLat, double MinLon, double MaxLon) BoundingBoxDegrees(
        double latitude,
        double longitude,
        double radiusMeters)
    {
        var latDelta = radiusMeters / 111_320d;
        var cosLat = Math.Cos(latitude * Math.PI / 180d);
        var lonDelta = cosLat > 1e-6 ? radiusMeters / (111_320d * cosLat) : 180d;

        return (
            latitude - latDelta,
            latitude + latDelta,
            longitude - lonDelta,
            longitude + lonDelta);
    }
}
