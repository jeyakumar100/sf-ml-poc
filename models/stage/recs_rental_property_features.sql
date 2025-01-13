select
    property_id,
    rental_id,
    rental_features
from
    (
    select
        cast(r.property_id as BIGINT) as property_id,
        r.rental_id as rental_id,
        to_json(object_construct(
                'full_street_address', r.full_street_address,
                'display_postal_code', r.display_postal_code,
                'display_city', r.display_city,
                'display_state_or_province', r.display_state_or_province,
                'rcountry_code', r.country_code,
                'status', r.status,
                --'standardized_amenities', from_json(r.standardized_amenities, 'array<string>'),
                'standardized_amenities', r.standardized_amenities, 
                'rental_available_photos', r.rental_available_photos,
                --'pet_policies', from_json(r.pet_policies, 'array<map<string,string>>'),
                'pet_policies', r.pet_policies,
                'parking', r.parking,
                'admin_fee', r.admin_fee,
                'admin_fee_currency', r.admin_fee_currency,
                'application_fee', r.application_fee,
                'application_fee_currency', r.application_fee_currency,
                    -- rental_units columns
                'ru_unit_id', ru.unit_id,
                'ru_unit_name', ru.unit_name,
                'ru_status', ru.status,
                'ru_deposit', ru.deposit,
                'ru_deposit_currency', ru.deposit_currency,
                    --'ru_floor', ru.floor,
                    'ru_sqft', ru.sqft,
                    'ru_rent', ru.rent,
                    'ru_rent_currency', ru.rent_currency,
                    -- rental_unit_types columns
                    'rut_unit_type_id', rut.unit_type_id,
                    'rut_unit_type_name', rut.unit_type_name,
                    'rut_unit_type_available_photos', rut.unit_type_available_photos,
                    'rut_bedrooms', rut.bedrooms,
                    'rut_full_baths', rut.full_baths,
                    'rut_half_baths', rut.half_baths,
                    'rut_available_lease_terms', rut.available_lease_terms,
                    'rut_units_available', rut.units_available,
                    'rut_deposit', rut.deposit,
                    'rut_deposit_currency', rut.deposit_currency,
                    'rut_min_rent', rut.min_rent,
                    'rut_max_rent', rut.max_rent,
                    'rut_rent_currency', rut.rent_currency,
                    'rut_min_sqft', rut.min_sqft,
                    'rut_max_sqft', rut.max_sqft,
                    'rut_status', rut.status,
                    'rut_style', rut.style,
                    -- property columns
                    'p_property_type_id', p.property_type_id,
                    'p_num_stories', p.num_stories,
                    'p_sq_ft_unfinished', p.sq_ft_unfinished,
                    'p_year_renovated', p.year_renovated,
                    'p_total_sq_ft', p.total_sq_ft,
                    'p_num_bedrooms', p.num_bedrooms,
                    'p_num_bathrooms', p.num_bathrooms,
                    'p_year_built', p.year_built,
                    'p_sq_ft_finished', p.sq_ft_finished,
                    'p_zoning', p.zoning,
                    'p_num_full_bathrooms', p.num_full_bathrooms,
                    'p_num_partial_bathrooms', p.num_partial_bathrooms,
                    'p_num_stories_precise', p.num_stories_precise,
                    'p_lot_sq_ft', p.lot_sq_ft,
                    'p_latitude', p.latitude,
                    'p_longitude', p.longitude
                )) as rental_features,
                row_number() over (partition by r.property_id, r.rental_id order by r.edw_insert_dttm desc) as rn
    from
        {{ source("ods", "rentals") }} as r
        left outer join {{ source("ods", "properties") }} as p on r.property_id = p.property_id
        left outer join {{ source("ods", "rental_units") }}  as ru on r.rental_id = ru.rental_id
        left outer join {{ source("ods", "rental_unit_types") }}  as rut on r.rental_id = rut.rental_id
        where r.property_id is not null
        )s
    where rn = 1

