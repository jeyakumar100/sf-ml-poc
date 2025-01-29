select t1.*,t2.property_id_2  from 
{{ source("rf_temp", "recs_listing_clusters_pilr_v2") }} t1
join 
(select distinct src.property_id_2, trim(cid.value,'""') as cluster_id_1 
from {{ ref("recs_p1_candiates_matches")}} src,
lateral flatten(src.value:cluster_id_1) cid
)t2
on t1.cluster_id = t2.cluster_id_1