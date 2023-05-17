public class skedTravelTimeService extends skedTravelTimeServiceBase {
    private final Integer VELOCITY = 30;
    private final Decimal MI_TO_M = 1609.34;
    private final Integer ONE_HOUR_IN_SECOND = 3600;

    public override void initialize(List<skedBaseModels.geometry> origins, List<skedBaseModels.geometry> destinations) {
        this.mapJourney = new Map<String, skedBaseModels.journeyModel>();

        Integer velocity = 30; //30 miles/hour
        for (skedBaseModels.geometry origin : origins) {
            for (skedBaseModels.geometry destination : destinations) {
                skedBaseModels.journeyModel journey = new skedBaseModels.journeyModel();
                journey.originGeometry = origin;
                journey.destinationGeometry = destination;
                
                Location originGeoLocation = Location.newInstance(origin.lat, origin.lng);
                Location destinationGeoLocation = Location.newInstance(destination.lat, destination.lng);
                journey.distanceInMiles = originGeoLocation.getDistance(destinationGeoLocation, 'mi');
                journey.distance = journey.distanceInMiles * MI_TO_M; //metre
                journey.travelTime = Integer.valueOf((journey.distanceInMiles / VELOCITY) * ONE_HOUR_IN_SECOND); //seconds

                String originKey = origin.lat + ',' + origin.lng;
                String destinationKey = destination.lat + ',' + destination.lng;
                this.mapJourney.put(originKey + '|' + destinationKey, journey);
            }
        }
    }
}