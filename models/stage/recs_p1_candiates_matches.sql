select t1.* from 
{{ source("rf_temp", "recs_listing_cluster_matches") }} t1
join {{ ref ("recs_rentals_events_expanded") }}  t2
on t1.property_id_2 = t2.curatedRental:rfPropertyId::int