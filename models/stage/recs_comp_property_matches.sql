select *  from 
{{ source("rf_temp", "recs_listing_clusters_pilr_v2") }} 
where cluster_id in
(select distinct trim(cid.value,'""') as cluster_id_1 
from {{ ref("recs_p1_candiates_matches")}} src,
lateral flatten(src.value:cluster_id_1) cid
)