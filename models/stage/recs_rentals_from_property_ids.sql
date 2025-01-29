with p_r_ids as
(select src.*,tgt.property_id_2
from {{ ref("recs_rental_id_property_id_map")}} src
join  {{ ref("recs_comp_property_matches")}} tgt
on src.property_id = tgt.property_id
)
select 
    pri.property_id_2 as property_id_2,
    pri.property_id as property_id,
    trim(rid.value,'""') as rental_id
from p_r_ids as pri,
lateral flatten(pri.rental_ids) rid