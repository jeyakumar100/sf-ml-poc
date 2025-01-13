    
select
    t1.login_id,
    t1.ip,
    t1.request_timestamp,
    is_app,
    is_mobile_web,
    is_mobile,
    t1.mobile_header,
    t1.mobile_type,
    t1.user_agent,
    t1.referrer,
    t1.referrer_domain_name,
    t1.rf_browser_id,
    --t1.ip_lat,
    --t1.ip_long,
    --t1.ip_zip,
    --t1.ip_acc_km,
    t1.property_id,
    p.property_type_id,
    cast(r.rental_id as string) as rental_id,
    rut.unit_type_id,
    ru.rent as rent_price,
    rut.min_rent,
    rut.max_rent,
    r.date_available,
    rut.units_available,
    r.status,
    rut.bedrooms as num_bedrooms,
    rut.full_baths as num_bathrooms,
    p.lot_sq_ft,
    p.total_sq_ft as approx_sq_ft,
    p.year_built,
    r.display_postal_code as zip,
    r.display_city as city,
    r.display_state_or_province as state,
    p.latitude,
    p.longitude,
    t1.from_corvair,
    bot_type,
    host,
    p.state_or_province_code as country_code,
    uri,
    p.postal_code,
    case when t1.is_bot then 1 else 0 end as is_bot,
                        -- see AML-1073: for activish listings we always show the sale, not the rental
                        -- activish (1: active, 2: contingent, 8: pre-market, 128: pending)
    case
    --when property_states.search_status_id in (1, 2, 8, 128) then false
    --when web_apartment_property_id is not null then true     
    --else rentals.property_id is not null end as is_rental
        when web_apartment_property_id is not null then true 
        when r.property_id is not null then true else false end as is_rental
    from (
        select
            login_id,
            ip,
            request_timestamp,
            is_bot,
            bot_type,
            case when web_property_id is null then true else false end as is_app,
            case when mobile_property_id is not null then true else false end as is_mobile,
            case when mobile_property_id is not null  and coalesce(web_property_id, web_apartment_property_id) is not null 
                    then true else false end as is_mobile_web,
            web_apartment_property_id,
            mobile_header,
            mobile_type,
            user_agent,
            referrer,
            referrer_domain_name,
            rf_browser_id,
            --ip_lat,
            --ip_long,
            --ip_zip,
            --ip_acc_km,
            cast(coalesce(web_property_id, mobile_property_id, web_apartment_property_id,0) as BIGINT) as property_id,
            host,
            uri,
            from_corvair
            from   (
                select *
                    ,try_cast(regexp_substr(uri, 'propertyId=([^&]+)', 1, 1, 'e', 1) as bigint)  as mobile_property_id
                    ,try_cast(split_part(regexp_substr(uri,'(/home/)([0-9]+)'),'/',-1) as bigint) as web_property_id
                    ,try_cast(split_part(regexp_substr(uri,'(/apartment/)([0-9]+)'),'/',-1) as bigint) as web_apartment_property_id
                    from rdw_prod.timeseries.weblogs_202501_01
                    where day = '2025-01-01'
                    and (uri not like '%.ashx%')  
                        and (uri not like '%.js%')  
                        and (uri not like '%.css%')
                        and (
                            (uri like '/stingray/mobile/api/v_/home/details/belowTheFold%' and uri not like '%homeGrouping=1%') or
                            (uri like '/corv/%' and length(split(uri,'/')[2]) = 2) or
                            length(split(uri,'/')[1]) = 2
                            )
                    ) weblogs 
        )t1
    inner join {{ source("ods", "properties") }} as p on t1.property_id = p.property_id
    inner join {{ source("ods", "rentals") }} r on t1.property_id = cast(r.property_id as BIGINT)
    left outer join {{ source("ods", "rental_unit_types") }}  as rut on r.rental_id = rut.rental_id
    left outer join {{ source("ods", "rental_units") }}  ru on ru.unit_type_id = rut.unit_type_id