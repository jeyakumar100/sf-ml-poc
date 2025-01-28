select src.*
from {{ ref('recs_rental_property_features') }} src
join {{ ref('recs_rentals_from_property_ids') }} tgt
on src.property_id = tgt.property_id
and src.rental_id = tgt.rental_id