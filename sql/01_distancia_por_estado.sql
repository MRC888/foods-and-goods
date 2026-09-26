select
    h.hub_state as estado,
    count(d.delivery_distance_meters) as entregas_com_distancia,
    round((avg(d.delivery_distance_meters) / 1000.0)::numeric, 2) as distancia_media_km
from "Foods and Goods".deliveries as d
join "Foods and Goods".orders as o
    on d.delivery_order_id = o.order_id
join "Foods and Goods".stores as s
    on o.store_id = s.store_id
join "Foods and Goods".hubs as h
    on s.hub_id = h.hub_id
join "Foods and Goods".drivers as dr
    on d.driver_id = dr.driver_id
where d.delivery_status = 'DELIVERED'
  and dr.driver_modal = 'MOTOBOY'
group by h.hub_state
order by distancia_media_km desc;
