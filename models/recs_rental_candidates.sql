select  p1.rf_property_id as property_id,
    p1.rental_id as rental_id,
    p1.state_id as state_id,
    p1.unit_types as rental_features,
    p2.*
from {{ref("recs_rentals_events_expanded")}} p1
join (
select t1.property_id_2,
t1.rental_id as rental_id_1,
t1.property_id as property_id_1,
t1.state_id as state_id_1,
t2.login_ids as login_candidates,
t1.rental_features as rental_features_1,
from {{ref("recs_rental_features_from_rental_ids")}}   t1
join {{ref("recs_logins_for_rental1s")}} t2
on t1.rental_id = t2.rental_id
)p2
on p1.rf_property_id = p2.property_id_2