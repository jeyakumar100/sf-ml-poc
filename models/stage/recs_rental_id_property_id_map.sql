select
    cast(r.property_id as BIGINT) as property_id,
    array_agg(distinct r.rental_id) as rental_ids
from
    {{ source("ods", "rentals") }} as r
    where r.property_id is not null
    group by r.property_id