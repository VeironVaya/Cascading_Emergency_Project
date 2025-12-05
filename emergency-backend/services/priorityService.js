// Haversine formula to compute nearest helper
export function getNearestHelper(userLocation, helpers) {
  function distance(a, b) {
    const R = 6371;
    const dLat = (b.lat - a.lat) * (Math.PI / 180);
    const dLon = (b.lng - a.lng) * (Math.PI / 180);

    const x =
      Math.sin(dLat / 2) ** 2 +
      Math.cos(a.lat * Math.PI / 180) *
      Math.cos(b.lat * Math.PI / 180) *
      Math.sin(dLon / 2) ** 2;

    return R * (2 * Math.atan2(Math.sqrt(x), Math.sqrt(1 - x)));
  }

  let best = null;
  let bestDist = Infinity;

  for (const h of helpers) {
    const d = distance(userLocation, h.location);
    if (d < bestDist) {
      bestDist = d;
      best = h;
    }
  }

  return best;
}
