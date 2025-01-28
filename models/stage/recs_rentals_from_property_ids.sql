with p_r_ids as
(select src.*
from {{ ref("recs_rental_id_property_id_map")}} src
join  {{ ref("recs_comp_property_matches")}} tgt
on src.property_id = tgt.property_id
)
select 
    src.property_id as property_id,
    trim(rid.value,'""') as rental_id
from p_r_ids as src,
lateral flatten(src.rental_ids) rid