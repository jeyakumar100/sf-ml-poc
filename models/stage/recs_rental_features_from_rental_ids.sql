select tgt.property_id_2,src.*,
trim(parse_json(src.rental_features):display_state_or_province,'"') as state_id
from {{ ref('recs_rental_property_features') }} src
join {{ ref('recs_rentals_from_property_ids') }} tgt
on src.property_id = tgt.property_id
and src.rental_id = tgt.rental_id