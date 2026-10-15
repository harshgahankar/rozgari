const List<String> kTrades = [
  'Electrician',
  'Plumber',
  'Carpenter',
  'Painter',
  'Mason',
  'Helper',
  'Sweeper',
  'Cook',
  'Driver',
  'Gardener',
  'Welder',
  'Construction Worker',
];

const List<String> kAreas = [
  'Kothrud, Pune',
  'Hadapsar, Pune',
  'Baner, Pune',
  'Wakad, Pune',
  'Katraj, Pune',
  'Pimpri, Pune',
  'Shivajinagar, Pune',
  'Kondhwa, Pune',
  'Vashi, Mumbai',
  'Andheri, Mumbai',
  'Bandra, Mumbai',
  'Thane West',
];

const Map<String, String> kAreaCity = {
  'Kothrud, Pune': 'Pune',
  'Hadapsar, Pune': 'Pune',
  'Baner, Pune': 'Pune',
  'Wakad, Pune': 'Pune',
  'Katraj, Pune': 'Pune',
  'Pimpri, Pune': 'Pune',
  'Shivajinagar, Pune': 'Pune',
  'Kondhwa, Pune': 'Pune',
  'Vashi, Mumbai': 'Mumbai',
  'Andheri, Mumbai': 'Mumbai',
  'Bandra, Mumbai': 'Mumbai',
  'Thane West': 'Mumbai',
};

// Approx lat/lng for distance demo (not live GPS).
const Map<String, List<double>> kAreaCoords = {
  'Kothrud, Pune': [18.5074, 73.8077],
  'Hadapsar, Pune': [18.5080, 73.9260],
  'Baner, Pune': [18.5590, 73.7868],
  'Wakad, Pune': [18.5986, 73.7746],
  'Katraj, Pune': [18.4575, 73.8674],
  'Pimpri, Pune': [18.6298, 73.7997],
  'Shivajinagar, Pune': [18.5304, 73.8507],
  'Kondhwa, Pune': [18.4748, 73.8939],
  'Vashi, Mumbai': [19.0770, 72.9986],
  'Andheri, Mumbai': [19.1136, 72.8697],
  'Bandra, Mumbai': [19.0596, 72.8295],
  'Thane West': [19.2011, 72.9560],
};
