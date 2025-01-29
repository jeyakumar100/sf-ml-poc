select 
    rentalid as rental_id,
    curatedRental:rfPropertyId::int as rf_property_id,
    curatedRental:countryCode::string as country_code,
    curatedRental:displayStateOrProvince::string as state_id,
    curatedRental:unitTypes as unit_types,
    unittypes.value:units as units,
    rfPropertyData:p_latitude::float as latitude,
    rfPropertyData:p_longitude::float as longitude,
    rfPropertyData:p_propertyTypeId::int as propety_type_id,
    rfPropertyData:p_propertyId::int as p_propertyId,
    creationtimeepochms as creation_time_epoch_ms,
    curatedrental,
    rentalhistory,
    rfpropertydata
from {{ source("rf_temp", "recs_rentals_events") }} src,
lateral flatten(src.curatedRental:unitTypes) unittypes
