select src.rental_id, array_agg(tgt.login_id) as login_ids
from {{ ref("recs_rental_features_from_rental_ids") }}   src
join {{ ref("recs_login_rental_interaction_profile") }} tgt
on src.rental_id = tgt.rental_id
group by 1
having count(login_id) > 1
